// supabase/functions/blockchain-mint/index.ts
//
// HissedarAssetToken (ERC-1155) ile çalışan blockchain mint servisi
// Tek kontrat, her asset bir tokenId
//
// Actions:
//   - (default) process pending blockchain_transactions
//   - create_wallet: Kullanıcıya custodial wallet oluştur
//   - process_single: Tek transaction işle
//
// Deploy: supabase functions deploy blockchain-mint

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { ethers } from "npm:ethers@6";

// ─────────────────────────────────────────────
//  Config
// ─────────────────────────────────────────────

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const NOTIFY_URL = `${Deno.env.get("SUPABASE_URL")}/functions/v1/notify-user`;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const POLYGON_RPC_URL = Deno.env.get("POLYGON_AMOY_RPC_URL")!;
const DEPLOYER_PRIVATE_KEY = Deno.env.get("DEPLOYER_PRIVATE_KEY")!;
const CONTRACT_ADDRESS = Deno.env.get("HISSEDAR_CONTRACT_ADDRESS")!;

// HissedarAssetToken ERC-1155 ABI
const CONTRACT_ABI = [
  "function mintTokens(address to, uint256 tokenId, uint256 amount) external",
  "function burnTokens(address from, uint256 tokenId, uint256 amount) external",
  "function addToWhitelist(address account) external",
  "function batchAddToWhitelist(address[] accounts) external",
  "function whitelisted(address account) external view returns (bool)",
  "function balanceOf(address account, uint256 id) external view returns (uint256)",
  "function getAsset(uint256 tokenId) external view returns (tuple(string name, uint256 totalSupply, uint256 minted, uint256 pricePerToken, bool active, string metadataURI))",
  "function getAvailableSupply(uint256 tokenId) external view returns (uint256)",
];

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────

function getContract() {
  const provider = new ethers.JsonRpcProvider(POLYGON_RPC_URL);
  const wallet = new ethers.Wallet(DEPLOYER_PRIVATE_KEY, provider);
  return new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, wallet);
}

async function sendNotification(
  userId: string,
  type: string,
  title: string,
  body: string,
  extra?: { propertyId?: string; amount?: number }
): Promise<void> {
  try {
    await fetch(NOTIFY_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${SERVICE_KEY}`,
      },
      body: JSON.stringify({
        userId,
        notification: { type, title, body, ...extra },
      }),
    });
  } catch (err) {
    console.error("Bildirim gönderilemedi:", err);
  }
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// Asset adını DB'den çek
async function getAssetName(assetType: string, assetId: string): Promise<string> {
  const { data } = await supabase
    .from(assetType === "property" ? "properties" : assetType === "art" ? "arts" : "nfts")
    .select("title")
    .eq("id", assetId)
    .single();
  return data?.title ?? "Varlık";
}

// ─────────────────────────────────────────────
//  Wallet Oluşturma (Custodial)
// ─────────────────────────────────────────────

async function createWalletForUser(userId: string): Promise<string> {
  // Mevcut wallet var mı kontrol et
  const { data: existing } = await supabase
    .from("user_wallets")
    .select("wallet_address")
    .eq("user_id", userId)
    .single();

  if (existing?.wallet_address) {
    return existing.wallet_address;
  }

  // Deterministik wallet oluştur (user_id'den türetilmiş)
  // Production'da AWS KMS / HashiCorp Vault kullanılmalı
  const seed = ethers.solidityPackedKeccak256(
    ["string", "string"],
    [DEPLOYER_PRIVATE_KEY, userId]
  );
  const wallet = new ethers.Wallet(seed);
  const walletAddress = wallet.address;

  // DB'ye kaydet
  const { error } = await supabase.from("user_wallets").insert({
    user_id: userId,
    wallet_address: walletAddress,
    is_whitelisted: false,
  });

  if (error) {
    // Race condition — başka bir request zaten oluşturmuş olabilir
    if (error.code === "23505") {
      const { data: retry } = await supabase
        .from("user_wallets")
        .select("wallet_address")
        .eq("user_id", userId)
        .single();
      return retry!.wallet_address;
    }
    throw new Error(`Wallet oluşturma hatası: ${error.message}`);
  }

  console.log(`Wallet oluşturuldu: user=${userId} address=${walletAddress}`);
  return walletAddress;
}

// ─────────────────────────────────────────────
//  Mint İşlemi
// ─────────────────────────────────────────────

interface BlockchainTx {
  id: string;
  user_id: string;
  asset_type: string;
  asset_id: string;
  tx_type: string;
  blockchain_token_id: number;
  token_amount: number;
  wallet_address: string;
  status: string;
}

async function processMint(
  contract: ethers.Contract,
  tx: BlockchainTx
): Promise<{ success: boolean; tx_hash?: string; block?: number; error?: string }> {
  console.log(
    `Mint işleniyor: id=${tx.id} tokenId=${tx.blockchain_token_id} amount=${tx.token_amount} to=${tx.wallet_address}`
  );

  try {
    // 0) blockchain_token_id kontrolü
    if (!tx.blockchain_token_id || tx.blockchain_token_id === 0) {
      throw new Error("Asset'in blockchain_token_id'si tanımlı değil. Önce asset'i kontrata kaydedin.");
    }

    // 1) Whitelist kontrolü
    const isWhitelisted = await contract.whitelisted(tx.wallet_address);
    if (!isWhitelisted) {
      console.log(`Whitelist'e ekleniyor: ${tx.wallet_address}`);
      const wlTx = await contract.addToWhitelist(tx.wallet_address);
      await wlTx.wait();
      console.log(`Whitelisted: ${wlTx.hash}`);

      // DB güncelle
      await supabase
        .from("user_wallets")
        .update({ is_whitelisted: true })
        .eq("wallet_address", tx.wallet_address);
    }

    // 2) Supply kontrolü
    const available = await contract.getAvailableSupply(tx.blockchain_token_id);
    if (BigInt(tx.token_amount) > available) {
      throw new Error(
        `Yetersiz token arzı. İstenen: ${tx.token_amount}, Mevcut: ${available}`
      );
    }

    // 3) Gas estimate + mint
    const gasEstimate = await contract.mintTokens.estimateGas(
      tx.wallet_address,
      tx.blockchain_token_id,
      tx.token_amount
    );
    const gasLimit = (gasEstimate * 120n) / 100n; // %20 buffer

    const mintTx = await contract.mintTokens(
      tx.wallet_address,
      tx.blockchain_token_id,
      tx.token_amount,
      { gasLimit }
    );

    console.log(`Mint tx gönderildi: ${mintTx.hash}`);

    // 4) Onay bekle
    const receipt = await mintTx.wait(1);

    if (!receipt || receipt.status !== 1) {
      throw new Error(`Transaction başarısız: ${mintTx.hash}`);
    }

    console.log(`Mint onaylandı! Block: ${receipt.blockNumber} Gas: ${receipt.gasUsed}`);

    // 5) DB güncelle — blockchain_transactions
    await supabase
      .from("blockchain_transactions")
      .update({
        tx_hash: mintTx.hash,
        status: "confirmed",
        block_number: Number(receipt.blockNumber),
        gas_used: Number(receipt.gasUsed),
        confirmed_at: new Date().toISOString(),
      })
      .eq("id", tx.id);

    // 6) DB güncelle — holdings tx_hash
    await supabase
      .from("holdings")
      .update({ tx_hash: mintTx.hash })
      .eq("user_id", tx.user_id)
      .eq("asset_type", tx.asset_type)
      .eq("asset_id", tx.asset_id);

    // 7) DB güncelle — transactions status
    await supabase
      .from("transactions")
      .update({
        status: "confirmed",
        description: tx.asset_type + " satın alma (HSR) - blockchain onaylandı",
      })
      .eq("user_id", tx.user_id)
      .eq("asset_type", tx.asset_type)
      .eq("asset_id", tx.asset_id)
      .eq("status", "pending_blockchain");

    // 8) Kullanıcıya bildirim
    const assetName = await getAssetName(tx.asset_type, tx.asset_id);
    await sendNotification(
      tx.user_id,
      "token_minted",
      "Token'larınız aktarıldı",
      `${tx.token_amount} adet ${assetName} tokeni cüzdanınıza eklendi.`,
      { propertyId: tx.asset_id, amount: tx.token_amount }
    );

    return {
      success: true,
      tx_hash: mintTx.hash,
      block: Number(receipt.blockNumber),
    };
  } catch (error: any) {
    console.error(`Mint hatası (${tx.id}):`, error.message);

    // Hata kaydet
    await supabase
      .from("blockchain_transactions")
      .update({
        status: "failed",
        error_message: error.message?.substring(0, 500),
      })
      .eq("id", tx.id);

    // 3 denemeden sonra kullanıcıya bildirim
    await sendNotification(
      tx.user_id,
      "token_mint_failed",
      "Token transferi başarısız",
      "Destek ekibiyle iletişime geçin."
    );

    return { success: false, error: error.message };
  }
}

// ─────────────────────────────────────────────
//  HTTP Handler
// ─────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const { action, user_id, transaction_id } = body;

    // ── Action: Wallet oluştur ──
    if (action === "create_wallet" && user_id) {
      const address = await createWalletForUser(user_id);
      return json({ success: true, wallet_address: address });
    }

    // ── Action: Tek transaction işle ──
    if (action === "process_single" && transaction_id) {
      const { data: tx, error } = await supabase
        .from("blockchain_transactions")
        .select("*")
        .eq("id", transaction_id)
        .eq("status", "pending")
        .single();

      if (error || !tx) {
        return json(
          { success: false, error: "Transaction bulunamadı veya zaten işlenmiş" },
          404
        );
      }

      const contract = getContract();
      const result = await processMint(contract, tx);
      return json(result);
    }

    // ── Default: Tüm pending transaction'ları işle (cron) ──
    const { data: pendingTxs, error: fetchError } = await supabase
      .from("blockchain_transactions")
      .select("*")
      .eq("status", "pending")
      .eq("tx_type", "mint")
      .order("created_at", { ascending: true })
      .limit(10);

    if (fetchError) {
      throw new Error(`DB fetch hatası: ${fetchError.message}`);
    }

    if (!pendingTxs || pendingTxs.length === 0) {
      return json({ success: true, message: "İşlenecek transaction yok", processed: 0 });
    }

    console.log(`${pendingTxs.length} pending transaction işleniyor...`);

    const contract = getContract();
    const results = [];

    for (const tx of pendingTxs) {
      // Rate limit — her transaction arasında 2s bekle
      if (results.length > 0) {
        await new Promise((r) => setTimeout(r, 2000));
      }
      const result = await processMint(contract, tx);
      results.push({ id: tx.id, ...result });
    }

    return json({
      success: true,
      processed: results.length,
      confirmed: results.filter((r) => r.success).length,
      failed: results.filter((r) => !r.success).length,
      results,
    });
  } catch (error: any) {
    console.error("Edge Function hatası:", error);
    return json({ success: false, error: error.message }, 500);
  }
});
