//
//  FirstLaunchView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI
import AppTrackingTransparency

struct FirstLaunchView: View {
    
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    @EnvironmentObject var dataController: DataController
    @State private var isLoading = false
    let walkthroughImage = ["Walkthrough1",
                            "Walkthrough2",
                            "Walkthrough3",
                            "Walkthrough4",
                            "Walkthrough5",
                            "Walkthrough6"
                            ]
    @State private var currentPage = 0
    //初回プレゼント←必要ないかも
//    @State private var isBonusViewPresented = false
    
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $currentPage) {
                    ForEach(walkthroughImage.indices, id: \.self) { index in
                        Image(walkthroughImage[index])
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.default, value: currentPage)
                
                Button(action: {
                    if currentPage == walkthroughImage.count - 1 {
                        isLoading = true
                        dataController.saveInitData(finishImportWords: {
                            isLoading = false
                            isFirstLaunch = false
//                            isBonusViewPresented = true
                        })
                    } else {
                        currentPage += 1
                    }
                }, label: {
                    Text(currentPage == walkthroughImage.count - 1 ? "始める" : "次へ")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .padding()
                })
            }
            
            if isLoading {
                LoadingView(loadingText: "初期データをロード中...")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
        }
    }
}

#Preview {
    FirstLaunchView()
}
