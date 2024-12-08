//
//  masteryGraphView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/04/26.
//

import SwiftUI
import Charts

struct masteryGraphView: View {
    
    @EnvironmentObject var dataController: DataController
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "groupname CONTAINS[cd] %@", "単語")
    ) var subGroup: FetchedResults<Group>
    
    @State private var goodWord:Int16 = 0
    @State private var subtleWord:Int16 = 0
    @State private var badWord:Int16 = 0
    
    @State private var totalCount: Int16 = 0
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 15) {
                VStack(spacing: 10) {
                    
                    Text("習得度状況")
                        .font(.headline)
                    
                    Chart {
                        BarMark(
                            x: .value("Value",  goodWord),
                            y: .value("Name", "習得度")
                        )
                        .foregroundStyle(.cyan)
                        BarMark(
                            x: .value("Value",  subtleWord),
                            y: .value("Name", "習得度")
                        )
                        .foregroundStyle(.orange)
                        BarMark(
                            x: .value("Value",  badWord),
                            y: .value("Name", "習得度")
                        )
                        .foregroundStyle(.red)
                    }
                    .chartXScale(domain: 0...totalCount)
                    //具体的な表示を避けるために空処理
                    .chartXAxis {
                    }
                    .frame(height: 100)
                    
                    HStack(spacing: 40) {
                        colorText(text: "習得", color: .cyan)
                        colorText(text: "微妙", color: .orange)
                        colorText(text: "苦手", color: .red)
                    }
                    
                    Text("学習した単語の習得度を確認しましょう！\nグラフ全体が水色に染まると素晴らしいです！！")
                        .font(.footnote)
                        .padding(.top)
                }
                .padding()
                .itemStyle()
                
                VStack {
                    Text("累計学習単語数")
                        .font(.headline)
                    
                    HStack {
                        Image("chatKun")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                            .rotationEffect(.degrees(-5))
                        Spacer()
                        Text("\(totalCount)")
                            .font(.largeTitle.bold())
                        Text("単語")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                        Spacer()
                        Image("chatKun")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                            .rotationEffect(.degrees(5))
                    }
                }
                .padding()
                .itemStyle()
                
                Text("復習する")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top)
                
                ForEach(subGroup) { group in
                    GroupCell(group: group)
                }

            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                if let goodGroup = subGroup.filter({ $0.groupname == "習得単語" }).first {
                    goodWord = Int16(goodGroup.word?.count ?? 0)
                }
                if let subtleGroup = subGroup.filter({ $0.groupname == "微妙単語" }).first {
                    subtleWord = Int16(subtleGroup.word?.count ?? 0)
                }
                if let badGroup = subGroup.filter({ $0.groupname == "苦手単語" }).first {
                    badWord = Int16(badGroup.word?.count ?? 0)
                }
                
                totalCount = goodWord + subtleWord + badWord
                
            }
        }
        .background(.mainBackground)
    }
    
    @ViewBuilder
    func colorText(text: String, color: Color) -> some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width:8, height: 8)
            
            Text(text)
                .font(.footnote)
        }
    }
}

#Preview {
    masteryGraphView()
}
