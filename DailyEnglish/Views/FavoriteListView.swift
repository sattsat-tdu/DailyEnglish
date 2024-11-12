//
//  FavoriteListView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/05/11.
//

import SwiftUI

struct FavoriteListView: View {
    
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.english, ascending: true)],
        predicate: NSPredicate(format: "isfavorite == %@", NSNumber(value: true))
    ) var favoriteWord: FetchedResults<Word>
    @EnvironmentObject var dataController: DataController
    @State private var isShowPlay = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("お気に入り単語一覧")
                .font(.headline)
            Spacer()
            
            ScrollView {
                LazyVStack {
                    ForEach(favoriteWord, id: \.id) { word in
                        WordCell(word: word)
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .clipShape(.rect(cornerRadius: 20))
            
            
            Spacer()
            
            Button(action: {
                isShowPlay = true
            }, label: {
                Label("学習する", systemImage: "play")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50,alignment:.center)
                    .background(.yellow)
                    .clipShape(.rect(cornerRadius: 10))
            })
            .fullScreenCover(isPresented: $isShowPlay) {
                PlayViewEX(words: dataController.getFavoriteWords())
            }
        }
        .padding()
        .background(yellowBaseGradient)
        .navigationTitle("お気に入り単語")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FavoriteListView()
}
