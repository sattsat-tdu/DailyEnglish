//
//  LoadingView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
    let loadingText: String
    
    let scaleEffect: CGFloat = 2
    
    var body: some View {
        let size = UIScreen.main.bounds.width / 2.5
        ZStack {
            //ロード中は背景にあるボタンなどの反応させないようにするため
            Color.black.opacity(0.2) // 背景をclearに設定
                .edgesIgnoringSafeArea(.all) // Safe
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(scaleEffect)
                    .frame(width: scaleEffect * 20, height: scaleEffect * 20)
                Text(loadingText)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
            .frame(width: size, height: size)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
        }
    }
}

//struct LoadingView: View {
//
//    @State var animate = false
//    let loadingText: String
//
//    var body: some View {
//        let size = UIScreen.main.bounds.width / 2.5
//
//        ZStack {
//
//            //ロード中は背景にあるボタンなどの反応させないようにするため
//            Color.white.opacity(0.2) // 背景をclearに設定
//                .edgesIgnoringSafeArea(.all) // Safe Area外まで背景を広げ
//
//            VStack(spacing: 30) {
//                Circle()
//                    .trim(from: 0,to: 0.8)
//                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 8, lineCap: .round))
//                    .frame(width: 50,height: 50)
//                    .rotationEffect(.init(degrees: self.animate ? 360 : 0))
//                    .animation(
//                        .linear(duration: 0.8).repeatForever(autoreverses: false),
//                        value: animate
//                    )
//
//                Text(loadingText)
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.1)
//            }
//            .frame(width: size, height: size)
//            .background(.ultraThinMaterial)
//            .clipShape(.rect(cornerRadius: 20))
//        }
//        .onAppear {
//            animate = true
//        }
//    }
//}

#Preview {
    LoadingView(loadingText: "データをロード中...")
}
