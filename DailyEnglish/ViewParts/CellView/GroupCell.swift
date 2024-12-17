//
//  GroupCell.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/14.
//

import SwiftUI

struct GroupCell: View {
    
    let group: Group
    private let count: Int16
    private let groupName: String
    @State private var isShowWordList = false
    @State private var isShowPlay = false
    
    init(group: Group) {
        self.group = group
        count = Int16(group.word?.count ?? 0)
        groupName = group.name ?? ""
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.yellow)
                .frame(width: 48)
            
            VStack(alignment: .leading) {
                ZStack {
                    if groupName.contains("Part") {
                        Text("\(group.wordCount - count) / \(group.wordCount) 学習済み")
                        
                    } else {
                        Text("\(count) 単語")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                Text(groupName)
                    .font(.headline)
            }
            
            Spacer()
            
            Button(action: {
                isShowWordList = true
            }) {
                Image(systemName: "list.bullet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(12)
                    .overlay(
                        Circle()
                            .stroke(.secondary, lineWidth: 1) // 外枠を追加
                    )
            }
            
            Button(action: {
                isShowPlay = true
            }, label: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.green)
                    .padding(12)
                    .overlay(
                        Circle()
                            .stroke(.secondary, lineWidth: 1) // 外枠を追加
                    )
            })
            .fullScreenCover(isPresented: $isShowPlay) {
                if let word = group.word {
                    PlayViewEX(
                        words: word as? Set<Word>,
                        isNGSLWords: group.name?.contains("Part") ?? false)
                } else {
                    PlayViewEX(words: [],
                               isNGSLWords: group.name?.contains("Part") ?? false)
                }

            }
            .fullScreenCover(isPresented: $isShowWordList) {
                WordListView(group: group)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 10)
        .padding(.horizontal)
        .itemStyle()
    }
}

#Preview {
    let context = CoreDataManager.shared.viewContext
    
    // 仮のデータを CoreData に挿入
    let group = Group(context: context)
    group.name = "Hello World!"
    group.wordCount = 10 // サンプルデータ

    // Preview の描画
    return GroupCell(group: group)
}
