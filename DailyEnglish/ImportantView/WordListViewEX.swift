//
//  PlayViewTest.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/04/28.
//

import SwiftUI

struct WordListViewEX: View {
    
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = ""
    @FocusState var focus:Bool
    //グループからWordを取得
//    @State private var words: Set<Word> = []
    let initWord:Set<Word>
    
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
            
            //abc順にソートするための定数
            let sortedWords = Array(initWord).sorted(by: { $0.english ?? "" < $1.english ?? "" })
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
        .background(Color("BackgroundColor"))
        .onAppear {
            //引数をStateの変数に入れる。
//            words = initWord
        }
    }
}

#Preview {
    let previewContext = DataController().container.viewContext
    let testGroup = Group(context: previewContext)
    let words = testGroup.word as? Set<Word> ?? []
    
    return WordListViewEX(initWord: words)
        .environment(\.managedObjectContext, previewContext)
}
