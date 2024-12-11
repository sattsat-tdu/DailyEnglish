//
//  forgettingCurveView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/04/26.
//

import SwiftUI

struct forgettingCurveView: View {
    
    @EnvironmentObject var dataManager: CoreDataManager
    
    @State private var oneDayWord: Set<Word> = []
    @State private var sevenDaysWord: Set<Word> = []
    @State private var thirtyDaysWord: Set<Word> = []
    
    
    
    @State private var isShowPlay = false
    @State private var isShowWordList = false
    
    //ダークモードか判別
    @Environment(\ .colorScheme)var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 20) {
                VStack{
                    Image(colorScheme == .light ? "forgettingCurve":"forgettingCurve_Dark")
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                    Text("出典: sakura394.jp")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text("初めて暗記した単語を１日後、7日後、30日後に復習することで、確実な定着を実感できます。")
                        .font(.footnote)
                        .padding(.vertical)
                    
                }
                .padding()
                .background(.item)
                .clipShape(.rect(cornerRadius: 10))
                .clipped()
                .shadow(radius: 3)
                
                Text("復習する")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top)
                daysAgoView(daysnum: 1, words: oneDayWord)
                daysAgoView(daysnum: 7, words: sevenDaysWord)
                daysAgoView(daysnum: 30, words: thirtyDaysWord)
            }
            .padding()
        }
        .onAppear {
            oneDayWord = dataManager.getTestWords(daysago: 1)
            sevenDaysWord = dataManager.getTestWords(daysago: 7)
            thirtyDaysWord = dataManager.getTestWords(daysago: 30)
        }
        .background(.mainBackground)
    }
}

struct daysAgoView: View {
    
    @State private var isShowPlay = false
    @State private var isShowWordList = false
    let daysnum: Int
    let words: Set<Word>
    
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
                            
                            Text("\(daysnum)日前に覚えた単語")
                                .foregroundStyle(.primary)
                                .font(.title3.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Spacer()
                        }
                    }
                    Text("〉")
                        .font(.title)
                }
            })
            //ボタン内のText色を青にしないため
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $isShowPlay) {
                PlayViewEX(words: words)
            }
            
            Divider()
            
            HStack {
                
                Button(action: {
                    isShowWordList = true
                }, label: {
                    Label("一覧を見る 〉", systemImage: "list.bullet.rectangle")
                        .font(.headline)
                        .foregroundStyle(.black)
                })
                .fullScreenCover(isPresented: $isShowWordList) {
                    WordListViewEX(initWord: words)
                }
                Spacer()
                
                Text("\(words.count) 単語")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding()
        .background(whiteBlueGradient)
        .clipShape(.rect(cornerRadius: 10))
        .clipped()
        .shadow(radius: 1)
    }
}

#Preview {
    ChertView()
        .environmentObject(CoreDataManager.shared)
}
