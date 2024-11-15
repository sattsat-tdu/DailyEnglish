//
//  HomeView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\ .colorScheme)var colorScheme
    let heightSize =  UIScreen.main.bounds.height
    
    @State private var ticketInfo = StudyInfo()
    
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false){
                LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                    Section(header: AdBannerView().frame(height: 50)) {
                        
                        Text("学習する")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            VStack {
                                DestinationLinkButton(
                                    destinationView: StudyWordView(),
                                    imageName: "brain.head.profile",
                                    title: "日常単語", 
                                    color: .yellow
                                )
                                DestinationLinkButton(
                                    destinationView: MyWordView(),
                                    imageName: "menucard",
                                    title: "My単語帳", 
                                    color: .green
                                )
                            }
                            VStack {
                                DestinationLinkButton(
                                    destinationView: StudySoundView(),
                                    imageName: "airpodsmax",
                                    title: "リスニング", 
                                    color: .blue
                                )
                                DestinationLinkButton(
                                    destinationView: StudySettingView(),
                                    imageName: "gearshape",
                                    title: "学習設定",
                                    color: .orange
                                )
                            }
                        }
                        
                        NavigationLink {
                            TicketView()
                        } label: {
                            
                            HStack {
                                VStack {
                                    HStack {
                                        Label("暗記チケット", systemImage: "brain.filled.head.profile")
                                        Spacer()
                                        Text("×\(ticketInfo.ankiTicket)")
                                    }
                                    
                                    HStack {
                                        Label("リスニングチケット", systemImage: "airpodsmax")
                                        Spacer()
                                        Text("×\(ticketInfo.listeningTicket)")
                                    }
                                }
                                .font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                Divider()
                                Text("チケット追加　〉")
                                    .font(.headline)
                            }
                            .padding()
                            .background()
                            .clipShape(.rect(cornerRadius: 10))
                            .shadow(radius: 1)
                        }
                        
                        VStack(spacing: 15) {
                            Text("復習する")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                            
                            HStack {
                                
                                NavigationLink {
                                    masteryGraphView()
                                } label: {
                                    
                                    VStack {
                                        Image(systemName: "chart.bar")
                                            .resizable()
                                            .scaledToFit()
                                            .opacity(0.6)
                                            .frame(height: 50)
                                            .padding()
                                        Text("習得度　〉")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                    }
//                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(circleGradient)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .shadow(radius: 1)
                                }
                                NavigationLink {
                                    forgettingCurveView()
                                } label: {
                                    
                                    VStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .resizable()
                                            .scaledToFit()
                                            .opacity(0.6)
                                            .frame(height: 50)
                                            .padding()
                                        Text("忘却曲線　〉")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                    }
                                    .padding()
                                    .background(circleGradient)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .shadow(radius: 1)
                                }
                            }
                            
                            
                            NavigationLink {
                                FavoriteListView()
                            } label: {
                                
                                HStack {
                                    
                                    Text("お気に入り単語　〉")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .bottomLeading)
                                    
                                    Image(systemName: "folder.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(0.6)
                                        .frame(height: 50)
                                    
                                }
                                .padding()
                                .background(yellowWhiteGradient)
                                .clipShape(.rect(cornerRadius: 10))
                                .shadow(radius: 1)

                            }
                            
                        }
                        .padding()
                        .background()
                        .clipShape(.rect(cornerRadius: 30))
                        //paddingのデフォルト余白は16
                        .padding(.horizontal,-16)
                        .shadow(color: .primary.opacity(0.1),radius: 5,y: -5)
                        
                        
                        //リンクへ飛ばす。
                        Link(destination: URL(string: "https://apps.apple.com/jp/developer/daisuke-ishii/id1609332032")!) {
                            HStack {
                                VStack(spacing: 10) {
                                    Text("休憩時間にどうですか？ 〉")
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                    Text("sattsatはゲームも開発しています。")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                
                                Image("MyAdIMG")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(height: 80)
                        .padding()
                        .background(.teal)
                        .clipShape(.rect(cornerRadius: 10))
                        
                        chatKunView(chatText: "ここまでみてくれてありがとう！\nスマイルあげます！ﾆｺｯ")
                        
                    }
                }
                .padding()
                .onAppear {
                    ticketInfo = StudyInfo.load()
                }
            }
            .background(Color("BackgroundColor"))
        }
    }
}

struct DestinationLinkButton<Destination: View>: View {
    let destinationView: Destination
    let imageName: String
    let title: String
    let color: Color
    //三色 青、青（薄い）、白
    var customColor: LinearGradient {
        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color("ItemColor"), location: 0.0),
                .init(color: Color("ItemColor"), location: 0.5),
                .init(color: color, location: 1.0)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }
    
    var body: some View {
        NavigationLink(
            destination: destinationView,
            label: {
                VStack {
                    Text("\(title)　〉")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .frame(maxWidth: .infinity,alignment: .topLeading)
                    Spacer()
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        .frame(minHeight: 30, maxHeight: 50)
                        .foregroundStyle(.black)
                    
                }
                .padding()
                .background(customColor)
                .clipShape(.rect(cornerRadius: 10))
                .shadow(radius: 1)
            }
        )
    }
}

#Preview {
    HomeView()
}
