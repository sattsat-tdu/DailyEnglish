//
//  DictionaryView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

struct DictionaryView: View {
    
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Word.english, ascending: true)]) var word:
    FetchedResults<Word>
    
    @State private var searchText = ""
    @FocusState var focus:Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            searchBar
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(word) { word in
                        WordCell(word: word)
                    }
                }
                .padding()
            }
        }
        .background(.mainBackground)
    }
    
    private var searchBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.gray)
            
            TextField("英単語を検索する...", text: $searchText)
                .keyboardType(.alphabet)
                .focused(self.$focus)
                .toolbar { //キーボードに閉じるボタンを付与
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()         // 右寄せにする
                        Button("閉じる") {
                            focus = false
                        }
                    }
                }
                .onChange(of: searchText) { text in
                    if text == "" {
                        word.nsPredicate = nil
                    } else {
                        //英語、もしくは日本語の絞り込み
                        let enPredicate = NSPredicate(format: "english CONTAINS[c] %@", text)
                        let jpPredicate = NSPredicate(format: "japanese CONTAINS[c] %@", text)
                        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: [enPredicate, jpPredicate])
                        word.nsPredicate = compoundPredicate
                    }
                }
            
            if focus {
                Button(action: {
                    focus = false
                    searchText = ""
                }, label: {
                    Text("キャンセル")
                        .foregroundStyle(Color.primary)
                })
            }
        }
        .padding(.vertical,10)
        .padding(.horizontal)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    DictionaryView()
}
