//
//  WordListView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/14.
//

import SwiftUI

struct WordListView: View {
    
    let group:Group
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = ""
    @FocusState var focus:Bool
    
    var wordin: Set<Word> {
        if let groupWords = group.word as? Set<Word> {
            return groupWords
        } else {
            return []
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 23, weight: .bold))
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
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.primary.opacity(0.4))
                        .font(.system(size: 40, weight: .bold))
                })
            }
            .padding()
            
            if let words = group.word as? Set<Word> {
                //abc順にソートするための定数
                let sortedWords = Array(words).sorted(by: { $0.english ?? "" < $1.english ?? "" })
                let filteredWords = sortedWords.filter { word in
                    return word.english?.contains(searchText) ?? false
                }
                ScrollView {
                    LazyVStack {
                        ForEach(Array(searchText == "" ? sortedWords : filteredWords)) { word in
                            WordCell(word: word)
                        }
                    }
                }
            }
        }
        .background(Color("BackgroundColor"))
    }
}

#Preview {
    let previewContext = DataController().container.viewContext
    let testGroup = Group(context: previewContext)
    testGroup.groupname = "Part0 テスト単語"
    testGroup.total = 3264
    
    return WordListView(group: testGroup)
        .environment(\.managedObjectContext, previewContext)
}
