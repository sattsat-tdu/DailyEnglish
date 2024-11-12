//
//  GroupCell.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/14.
//

import SwiftUI

struct GroupCell: View {
    
    let group: Group
    let gradationColor = LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topTrailing, endPoint: .bottomLeading)
    @State private var count: Int16 = 0
    @State private var groupName = ""
    @State private var isShowWordList = false
    @State private var isShowPlay = false
    
    var body: some View {
        VStack {
            Button(action: {
                isShowPlay = true
            }, label: {
                HStack {
                    VStack {
                        HStack {
                            Image(systemName: "folder.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.yellow)
                                .frame(width: 50)
                                .opacity(0.8)
                            
                            Spacer()
                            
                            Text(groupName)
                                .foregroundStyle(.primary)
                                .font(.title3.bold())
                            
                            Spacer()
                        }
                    }
                    Text("〉")
                        .font(.title)
                }
                .padding()
            })
            //ボタン内のText色を青にしないため
            .buttonStyle(.plain)
//            .fullScreenCover(isPresented: $isShowPlay) {
//                PlayView(group: group)
//            }
            //新アプデ
            .fullScreenCover(isPresented: $isShowPlay) {
                if let word = group.word {
                    PlayViewEX(
                        words: word as? Set<Word>,
                        isNGSLWords: group.groupname?.contains("Part") ?? false)
                } else {
                    PlayViewEX(words: [],
                               isNGSLWords: group.groupname?.contains("Part") ?? false)
                }

            }
            HStack {
                
                Button(action: {
                    isShowWordList = true
                }, label: {
                    Label("一覧を見る 〉", systemImage: "list.bullet.rectangle")
                        .font(.headline)
                        .foregroundStyle(.black)
//                        .frame(maxWidth: .infinity)
                })
                .fullScreenCover(isPresented: $isShowWordList) {
                    WordListView(group: group)
                }
                Spacer()
                
                if groupName.contains("Part") {
                    Text("\(group.total - count) / \(group.total) 学習済み")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    
                } else {
                    Text("\(count) 単語")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding()
            .background(gradationColor)
        }
//        .padding()
        .background(Color("ItemColor"))
        .clipShape(.rect(cornerRadius: 10))
        .clipped()
        .shadow(radius: 1)
        .onAppear {
            count = Int16(group.word?.count ?? 0)
            groupName = group.groupname ?? ""
        }
        //        VStack {
        //            HStack(spacing:20) {
        //                Image(systemName: "folder.fill")
        //                    .resizable()
        //                    .scaledToFit()
        //                    .foregroundStyle(.yellow)
        //                    .frame(width: 50)
        //
        //
        //                VStack(spacing: 10) {
        //                    Text(groupName)
        //                        .font(.title.bold())
        //
        //                    if groupName.contains("Part") {
        //                        Text("\(group.total - count) / \(group.total) 学習済み")
        //                            .font(.subheadline)
        //                            .foregroundStyle(Color.secondary)
        //
        //                    } else {
        //                        Text("\(count) 単語")
        //                            .font(.subheadline)
        //                            .foregroundStyle(Color.secondary)
        //                    }
        //                }
        //            }
        //            Divider()
        //                .padding()
        //
        //            HStack(spacing: 20) {
        //
        //                Button(action: {
        //                    isShowWordList = true
        //                }, label: {
        //                    Label("一覧を見る", systemImage: "list.bullet.rectangle")
        //                        .font(.headline)
        //                        .foregroundStyle(.black)
        //                        .frame(maxWidth: .infinity)
        //                        .frame(minHeight: 50,alignment:.center)
        //                        .background(Color.yellow)
        //                        .clipShape(.rect(cornerRadius: 10))
        //                })
        //                .fullScreenCover(isPresented: $isShowWordList) {
        //                    WordListView(group: group)
        //                }
        //
        //                Button(action: {
        //                    isShowPlay = true
        //                }, label: {
        //                    Label("学習する", systemImage: "pencil.and.outline")
        //                        .font(.headline)
        //                        .foregroundStyle(.black)
        //                        .frame(maxWidth: .infinity)
        //                        .frame(minHeight: 50,alignment:.center)
        //                        .background(Color.yellow)
        //                        .clipShape(.rect(cornerRadius: 10))
        //                })
        //                .fullScreenCover(isPresented: $isShowPlay) {
        //                    PlayView(group: group)
        //                }
        //
        //            }
        //        }
        //        .padding()
        //        .background(Color("ItemColor"))
        //        .clipShape(.rect(cornerRadius: 20))
        //        .clipped()
        //        .shadow(radius: 1)
        //        .padding(.vertical)
        //        .onAppear {
        //            count = Int16(group.word?.count ?? 0)
        //            groupName = group.groupname ?? ""
        //        }
    }
}

#Preview {
    let previewContext = DataController().container.viewContext
    let testGroup = Group(context: previewContext)
    testGroup.groupname = "Part0 テスト単語"
    testGroup.total = 3264
    
    return GroupCell(group: testGroup)
        .environment(\.managedObjectContext, previewContext)
}
