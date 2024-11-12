//
//  MyPageView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

struct MyPageView: View {
    
    @State private var isNightMode = false
    @State private var isShowcopyright = false
    @State private var isShowprivacy = false
    //ダークモードかどうか
    @AppStorage("isDarkMode") var isDarkMode = false
    //バージョンを取得
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let copyrightURL = URL(string: "https://sattsat.blogspot.com/2022/07/blog-post.html?m=1")
    let privacyURL = URL(string: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1")
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("マイページ")
                    .font(.headline)
                Form {
                    //ナイトモードとライトモードの切り替え
                    Toggle(isOn: $isDarkMode) {
                        Label("ナイトモード", systemImage: "moon.fill")
                            .onChange(of: isDarkMode) { newState in
                                let scenes = UIApplication.shared.connectedScenes
                                let windowScene = scenes.first as? UIWindowScene
                                let window = windowScene?.windows.first
                                window?.overrideUserInterfaceStyle = newState ? .dark : .light
                            }
                    }
                    .tint(.yellow)
                    NavigationLink(
                        destination: StudySettingView(),
                        label: {
                            Label("学習設定", systemImage: "graduationcap")
                        }
                    )
                    Section(header: Text("アプリ情報"), footer: Text("copyright ©︎ 2023 sattsat Inc.")) {
                        
                        HStack {
                            Text("バージョン")
                            Spacer()
                            Text(version)
                        }
                        Button(action: {
                            isShowcopyright = true
                        }, label: {
                            Label("コピーライト", systemImage: "newspaper")
                        })
                        .fullScreenCover(isPresented: $isShowcopyright) {
                            SafariView(url: copyrightURL!)
                        }
                        Button(action: {
                            isShowprivacy.toggle()
                            
                            
                        }, label: {
                            Label("プライバシーポリシー", systemImage: "hand.raised")
                        })
                        .fullScreenCover(isPresented: $isShowprivacy) {
                            SafariView(url: privacyURL!)
                        }
                    }
                    
                    Section(header: Text("追記")) {
                        NavigationLink(
                            destination: aboutDandaiView(),
                            label: {
                                Image("chatKun")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                
                                Text("ダンダイとは")
                            }
                        )
                        AdBannerView().frame(height: 250)
                    }
                    
                    
                }
            }
        }
    }
}

#Preview {
    MyPageView()
}
