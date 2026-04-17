//
//  SplashView.swift
//  Hissedar
//
//  Created by Sinan Dinç on 3/22/26.
//

import SwiftUI

struct SplashView: View {
    
    var onFinished: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Arka plan: #0f0720
            Color(red: 0.059, green: 0.027, blue: 0.125)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo - ortada
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                
                // Slogan - logonun 8pt altında
                Text(String.localized("splash.slogan"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.769, green: 0.710, blue: 0.992))
                    .padding(.top, 8)
                
                Spacer()
                
                // Versiyon - safe area bottom'dan 5pt yukarıda
                Text("\(String.localized("common.app_name")) 1.0.0v")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            }
        }
    }
}
