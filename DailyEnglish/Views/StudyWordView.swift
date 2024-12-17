//
//  StudyWordView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI
import Charts

struct StudyWordView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)],
        predicate: NSPredicate(format: "name CONTAINS[cd] %@", "Part")
    ) var mainGroup: FetchedResults<Group>
    
    var body: some View {
        
        
        ScrollView(showsIndicators: false){
            VStack(spacing: 24) {
                AdBannerView().frame(height: 50)
                
                studyChart
                
                chatKunView(chatText: "NGSL単語は、一般的な英文の92％以上を網羅しているんだって！")
                
                folderList
            }
            .padding()
        }
        .background(.mainBackground)
        .navigationTitle("日常単語(NGSL)")
    }
    
    private func convertPercentage(group: Group) -> Int {
        let wordCount = Int16(group.word?.count ?? 0)
        let totalWordCount = group.wordCount
        
        let wordCountDouble = Double(totalWordCount - wordCount)
        let totalDouble = Double(totalWordCount)
        
        if totalDouble == 0 {
            return 50
        }
        
        let percentage = (wordCountDouble / totalDouble) * 100
        return Int(percentage)
    }
    
    private var studyChart: some View {
        VStack(alignment: .leading) {
            
            Text("NGSL単語学習状況(%)")
                .font(.headline)
            
            Chart {
                ForEach(mainGroup) { group in
                    BarMark(
                        x: .value("Value", convertPercentage(group: group)),
                        y: .value("Name", group.name ?? "nil")
                    )
                    .annotation(position: .top){
                        //学習済みなら表示
                        if group.word?.count == 0 {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            .foregroundStyle(.yellow)
            .chartXScale(domain: 0...100)
        }
        .frame(height: 200)
        .padding()
        .itemStyle()
    }
    
    private var folderList: some View {
        VStack(spacing: 16) {
            ForEach(mainGroup, id: \.self) { group in
                GroupCell(group: group)
            }
        }
    }
}

#Preview {
    StudyWordView()
}
