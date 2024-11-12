//
//  aboutDandaiView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/12/04.
//

import SwiftUI

struct aboutDandaiView: View {
    var body: some View {
        VStack{
            Spacer()
            Image("chatKun")
                .resizable()
                .scaledToFit()
                .frame(width: 400)
            
            Text("　彼は、ある大学のチャットbotのイラスト募集がきっかけで生まれたキャラクターです。友達が試行錯誤して作り上げたキャラクターですので、可愛がってあげてください。")
            Spacer()
            Text("ちなみに、予選落ちです")
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
        .padding()
        .background(Color("BackgroundColor"))
        .navigationTitle("ダンダイとは")
    }
}

#Preview {
    aboutDandaiView()
}
