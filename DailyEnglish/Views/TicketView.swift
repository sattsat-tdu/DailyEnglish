//
//  TicketView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/14.
//

import SwiftUI
import AlertKit

struct TicketView: View {
    
    let gradationBlue = LinearGradient(gradient: Gradient(colors: [.cyan,.blue.opacity(0.8)] ), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let gradationYellow = LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topTrailing, endPoint: .bottomLeading)
    
    @State private var ticketInfo = StudyInfo.load()
    
    //広告表示
    @EnvironmentObject var adMobRef: AdmobController
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 5) {
                HStack {
                    Image(systemName: "brain.filled.head.profile")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.3)
                    Spacer()
                    VStack(spacing: 30) {
                        Text("暗記チケット")
                        Text("×\(ticketInfo.ankiTicket)")
                            .font(.title).bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding()
                .frame(height: 150)
                .background(gradationBlue)
                .clipShape(.rect(cornerRadius: 20))
                chatKunView(chatText: "暗記チケットを消費することで、四択問題の場合に解答欄を隠すことができるよ！")
                Button(action: {
                    adMobRef.showReward {
                        ticketInfo.ankiTicket += 1
                        ticketInfo.save()
                        AlertKitAPI.present(
                            title: "暗記チケットを獲得しました",
                            icon: .done,
                            style: .iOS16AppleMusic,
                            haptic: .success
                            )
                    }
                }, label: {
                    Label("広告視聴で暗記チケットを入手", systemImage: "play.rectangle")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .padding()
                })
                
                
                Divider()
                
                
                HStack {
                    Image(systemName: "airpodsmax")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.3)
                    Spacer()
                    VStack(spacing: 30) {
                        Text("リスニングチケット")
                        Text("×\(ticketInfo.listeningTicket)")
                            .font(.title).bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding()
                .frame(height: 150)
                .background(gradationYellow)
                .clipShape(.rect(cornerRadius: 20))
                chatKunView(chatText: "リスニングチケットを消費することで、リスニング学習を行うことができるよ！")
                Button(action: {
                    adMobRef.showReward {
                        ticketInfo.listeningTicket += 1
                        ticketInfo.save()
                        AlertKitAPI.present(
                            title: "リスニングチケットを獲得しました",
                            icon: .done,
                            style: .iOS16AppleMusic,
                            haptic: .success
                            )
                    }
                }, label: {
                    Label("広告視聴でリスニングチケットを入手", systemImage: "play.rectangle")
                        .minimumScaleFactor(0.1)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                        .padding()
                })
            }
            .padding()
            .navigationTitle("チケット管理")
        }
        .background(Color("BackgroundColor"))
    }
}

#Preview {
    TicketView()
}
