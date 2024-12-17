//
//  ReviewView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/21.
//

import SwiftUI

struct ReviewView: View {
    
    @EnvironmentObject var dataManager: CoreDataManager
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "name CONTAINS[cd] %@", "単語")
    ) var subGroup: FetchedResults<Group>
    
    @State private var isShowPlay = false
    
    let gradationColor = LinearGradient(gradient: Gradient(colors: [.cyan,.blue.opacity(0.8)] ), startPoint: .topLeading, endPoint: .bottomTrailing)
    
         //.mainBackground]
                                                                     
    var body: some View {
        
        ScrollView(showsIndicators: false){
            
            VStack {
                VStack(spacing: 20) {
                    
                    HStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .opacity(0.3)
                        Spacer()
                        VStack(spacing: 0) {
                            Text("お気に入り単語")
                                .font(.title2).bold()
                                .foregroundStyle(.black)
                            Text("⭐︎を付けた単語のみ出題")
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        isShowPlay = true
                    }, label: {
                        Text("お気に入り単語を学習")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50,alignment:.center)
                            .background(.yellow)
                            .clipShape(.rect(cornerRadius: 10))
                    })
                    .fullScreenCover(isPresented: $isShowPlay) {
                        PlayViewEX(words: dataManager.getFavoriteWords())
                    }
                    
                }
                .padding()
                .background(gradationColor)
                .clipShape(.rect(cornerRadius: 20))

                chatKunView(chatText: "全て”習得単語”にできるように頑張ろう！")
                
                ForEach(subGroup) { group in
                    GroupCell(group: group)
                }
            }
            .padding()
            
        }
        .background(.mainBackground)
        .navigationTitle("復習")
    }

    
}

#Preview {
    ReviewView()
}
