// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title HissedarAssetToken
 * @notice ERC-1155 token representing fractional ownership of real-world assets
 * @dev Each tokenId represents a unique asset (property, art, etc.)
 *      - Only the platform (owner) can mint and burn tokens
 *      - User-to-user transfers are disabled (secondary market not yet active)
 *      - Only KYC-approved (whitelisted) addresses can hold tokens
 */
contract HissedarAssetToken is ERC1155, Ownable, Pausable {

    // ──────────────────────────────────────────────
    //  Structs
    // ──────────────────────────────────────────────

    struct Asset {
        string name;           // e.g. "Kadıköy Residence #1"
        uint256 totalSupply;   // Maximum tokens for this asset
        uint256 minted;        // Currently minted amount
        uint256 pricePerToken; // Price in wei (or stablecoin smallest unit)
        bool active;           // Can be minted/traded
        string metadataURI;    // IPFS or API URI for asset details
    }

    // ──────────────────────────────────────────────
    //  State
    // ──────────────────────────────────────────────

    /// @notice Asset registry: tokenId => Asset
    mapping(uint256 => Asset) public assets;

    /// @notice KYC whitelist: address => approved
    mapping(address => bool) public whitelisted;

    /// @notice Track all registered asset IDs
    uint256[] public assetIds;

    /// @notice Platform treasury address (receives payments)
    address public treasury;

    // ──────────────────────────────────────────────
    //  Events
    // ──────────────────────────────────────────────

    event AssetCreated(uint256 indexed tokenId, string name, uint256 totalSupply, uint256 pricePerToken);
    event AssetUpdated(uint256 indexed tokenId, uint256 newPrice, bool active);
    event TokensMinted(uint256 indexed tokenId, address indexed to, uint256 amount);
    event TokensBurned(uint256 indexed tokenId, address indexed from, uint256 amount);
    event AddressWhitelisted(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    // ──────────────────────────────────────────────
    //  Errors
    // ──────────────────────────────────────────────

    error NotWhitelisted(address account);
    error AssetNotFound(uint256 tokenId);
    error AssetNotActive(uint256 tokenId);
    error AssetAlreadyExists(uint256 tokenId);
    error ExceedsMaxSupply(uint256 tokenId, uint256 requested, uint256 available);
    error InsufficientBalance(uint256 tokenId, uint256 requested, uint256 available);
    error TransferDisabled();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidTotalSupply();

    // ──────────────────────────────────────────────
    //  Modifiers
    // ──────────────────────────────────────────────

    modifier onlyWhitelisted(address account) {
        if (!whitelisted[account]) revert NotWhitelisted(account);
        _;
    }

    modifier assetExists(uint256 tokenId) {
        if (assets[tokenId].totalSupply == 0) revert AssetNotFound(tokenId);
        _;
    }

    modifier assetIsActive(uint256 tokenId) {
        if (!assets[tokenId].active) revert AssetNotActive(tokenId);
        _;
    }

    // ──────────────────────────────────────────────
    //  Constructor
    // ──────────────────────────────────────────────

    /**
     * @param _baseURI Base metadata URI (e.g. "https://api.hissedar.com/metadata/")
     * @param _treasury Platform treasury address
     */
    constructor(
        string memory _baseURI,
        address _treasury
    ) ERC1155(_baseURI) Ownable(msg.sender) {
        if (_treasury == address(0)) revert InvalidAddress();
        treasury = _treasury;
    }

    // ──────────────────────────────────────────────
    //  Asset Management (Owner Only)
    // ──────────────────────────────────────────────

    /**
     * @notice Register a new asset (property, art, etc.)
     * @param tokenId Unique identifier for this asset
     * @param name Human-readable asset name
     * @param totalSupply Maximum number of tokens for this asset
     * @param pricePerToken Price per token in wei
     * @param metadataURI IPFS/API URI for asset details
     */
    function createAsset(
        uint256 tokenId,
        string calldata name,
        uint256 totalSupply,
        uint256 pricePerToken,
        string calldata metadataURI
    ) external onlyOwner {
        if (assets[tokenId].totalSupply != 0) revert AssetAlreadyExists(tokenId);
        if (totalSupply == 0) revert InvalidTotalSupply();

        assets[tokenId] = Asset({
            name: name,
            totalSupply: totalSupply,
            minted: 0,
            pricePerToken: pricePerToken,
            active: true,
            metadataURI: metadataURI
        });

        assetIds.push(tokenId);

        emit AssetCreated(tokenId, name, totalSupply, pricePerToken);
    }

    /**
     * @notice Update asset price and/or active status
     */
    function updateAsset(
        uint256 tokenId,
        uint256 newPrice,
        bool active
    ) external onlyOwner assetExists(tokenId) {
        assets[tokenId].pricePerToken = newPrice;
        assets[tokenId].active = active;

        emit AssetUpdated(tokenId, newPrice, active);
    }

    // ──────────────────────────────────────────────
    //  Mint & Burn (Owner Only)
    // ──────────────────────────────────────────────

    /**
     * @notice Mint tokens to a whitelisted address
     * @dev Called by backend after successful payment verification
     * @param to Recipient address (must be whitelisted)
     * @param tokenId Asset token ID
     * @param amount Number of tokens to mint
     */
    function mintTokens(
        address to,
        uint256 tokenId,
        uint256 amount
    )
        external
        onlyOwner
        whenNotPaused
        assetExists(tokenId)
        assetIsActive(tokenId)
        onlyWhitelisted(to)
    {
        if (amount == 0) revert InvalidAmount();

        Asset storage asset = assets[tokenId];
        uint256 available = asset.totalSupply - asset.minted;

        if (amount > available) {
            revert ExceedsMaxSupply(tokenId, amount, available);
        }

        asset.minted += amount;
        _mint(to, tokenId, amount, "");

        emit TokensMinted(tokenId, to, amount);
    }

    /**
     * @notice Burn tokens from an address (buyback / exit)
     * @param from Token holder address
     * @param tokenId Asset token ID
     * @param amount Number of tokens to burn
     */
    function burnTokens(
        address from,
        uint256 tokenId,
        uint256 amount
    )
        external
        onlyOwner
        whenNotPaused
        assetExists(tokenId)
    {
        if (amount == 0) revert InvalidAmount();

        uint256 holderBalance = balanceOf(from, tokenId);
        if (amount > holderBalance) {
            revert InsufficientBalance(tokenId, amount, holderBalance);
        }

        assets[tokenId].minted -= amount;
        _burn(from, tokenId, amount);

        emit TokensBurned(tokenId, from, amount);
    }

    // ──────────────────────────────────────────────
    //  KYC Whitelist (Owner Only)
    // ──────────────────────────────────────────────

    /**
     * @notice Add address to KYC whitelist
     */
    function addToWhitelist(address account) external onlyOwner {
        if (account == address(0)) revert InvalidAddress();
        whitelisted[account] = true;
        emit AddressWhitelisted(account);
    }

    /**
     * @notice Batch add addresses to whitelist
     */
    function batchAddToWhitelist(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (accounts[i] == address(0)) revert InvalidAddress();
            whitelisted[accounts[i]] = true;
            emit AddressWhitelisted(accounts[i]);
        }
    }

    /**
     * @notice Remove address from whitelist
     */
    function removeFromWhitelist(address account) external onlyOwner {
        whitelisted[account] = false;
        emit AddressRemovedFromWhitelist(account);
    }

    // ──────────────────────────────────────────────
    //  Transfer Restriction (MVP: Disabled)
    // ──────────────────────────────────────────────

    /**
     * @dev Override to block all user-to-user transfers
     *      Only mint (from=0x0) and burn (to=0x0) are allowed
     *      Secondary market will unlock this in future
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override whenNotPaused {
        // Allow mint (from == 0) and burn (to == 0)
        // Block everything else (user-to-user transfer)
        bool isMint = from == address(0);
        bool isBurn = to == address(0);

        if (!isMint && !isBurn) {
            revert TransferDisabled();
        }

        super._update(from, to, ids, values);
    }

    // ──────────────────────────────────────────────
    //  Pause (Emergency)
    // ──────────────────────────────────────────────

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // ──────────────────────────────────────────────
    //  Treasury
    // ──────────────────────────────────────────────

    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert InvalidAddress();
        address oldTreasury = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    // ──────────────────────────────────────────────
    //  View Functions
    // ──────────────────────────────────────────────

    /**
     * @notice Get asset details
     */
    function getAsset(uint256 tokenId) external view returns (Asset memory) {
        return assets[tokenId];
    }

    /**
     * @notice Get remaining mintable tokens for an asset
     */
    function getAvailableSupply(uint256 tokenId) external view assetExists(tokenId) returns (uint256) {
        return assets[tokenId].totalSupply - assets[tokenId].minted;
    }

    /**
     * @notice Get total number of registered assets
     */
    function getAssetCount() external view returns (uint256) {
        return assetIds.length;
    }

    /**
     * @notice Override URI to return per-asset metadata
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory assetURI = assets[tokenId].metadataURI;

        if (bytes(assetURI).length > 0) {
            return assetURI;
        }

        return super.uri(tokenId);
    }
}
