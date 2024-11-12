//
//  firstBonusView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/11/21.
//

import SwiftUI

struct firstBonusView: View {
    
    let onClicked: () -> Void
    
    var body: some View {
        
        ZStack {
            
            //ロード中は背景にあるボタンなどの反応させないようにするため
            Color.black.opacity(0.1) // 背景をclearに設定
                .edgesIgnoringSafeArea(.all) // Safe
            
            VStack(spacing: 30) {
                Text("ダウンロード\nありがとうございます！！")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
                
                Text("感謝の気持ちを込めて、\n\n「暗記チケット」×20\n「リスニングチケット」× 20\n\nをプレゼントします！！\n学習に役立ててくださいね♪")
                Text("チケットのご利用はバージョン2.1からです。お待ちくださいませ🙇‍♀️")
                Button(action: {
                    onClicked()
                }, label: {
                    Label("受け取る", systemImage: "truck.box.fill")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 40,alignment:.center)
                        .background(Color.yellow)
                        .clipShape(.rect(cornerRadius: 10))
                })
            }
            .padding()
            .background(Color("ItemColor"))
            .clipShape(.rect(cornerRadius: 30))
            .shadow(radius: 5)
        .padding()
        }
    }
}

#Preview {
    firstBonusView(onClicked: {
        
    })
}
