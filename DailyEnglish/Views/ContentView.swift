//
//  ContentView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/11.
//

import SwiftUI



struct ContentView: View {
    
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    @AppStorage("isDarkMode") var isDarkMode = false
    @EnvironmentObject var speechRef: SpeechSynthesizer
    
    @State private var selectedTab: TabList = .home
    
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    HomeView()
                case .chart:
                    ChertView()
                case .dictionary:
                    DictionaryView()
                case .mypage:
                    MyPageView()
                }
                CustomTab(selectedTab: $selectedTab)
            }
            .overlay {
                if speechRef.isLoading {
                    LoadingView(loadingText: "音声を準備中")
                }
            }
            .animation(.easeInOut, value: selectedTab)
            .tint(.primary)
            .fullScreenCover(isPresented: $isFirstLaunch) {
                FirstLaunchView()
            }
        }
    }
}

#Preview {
    ContentView()
}
