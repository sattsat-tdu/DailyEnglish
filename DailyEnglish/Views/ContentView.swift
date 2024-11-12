//
//  ContentView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/11.
//

import SwiftUI

enum tabList {
    case home
    case chart
    case dictionary
    case mypage
}

struct ContentView: View {
    
//    @AppStorage("isUsedAnki") var isUsedAnki = false
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    @AppStorage("isDarkMode") var isDarkMode = false
    @EnvironmentObject var speechRef: SpeechSynthesizer
    
    init() {
        //Tab背景色の設定
        let appearance: UITabBarAppearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
        
        //ダークモードかどうか
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    @State var selected = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selected) {
                HomeView().tag(0)
                    .tabItem {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                
                //バージョンアプデ対応
                ChertView().tag(1)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("成長")
                        
                    }
                DictionaryView().tag(2)
                    .tabItem {
                        Image(systemName: "a.book.closed")
                        Text("NGSL辞書")
                    }
                
                MyPageView().tag(3)
                    .tabItem {
                        Image(systemName: "person")
                        Text("マイページ")
                    }
            }
            .overlay {
                if speechRef.isLoading {
                    LoadingView(loadingText: "音声を準備中")
                }
            }
            .animation(.easeInOut, value: selected)
            .tint(Color.primary)
            .fullScreenCover(isPresented: $isFirstLaunch) {
                FirstLaunchView()
            }
//            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
