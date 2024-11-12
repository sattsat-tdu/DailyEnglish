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
        sortDescriptors: [SortDescriptor(\.groupname)],
        predicate: NSPredicate(format: "groupname CONTAINS[cd] %@", "Part")
    ) var mainGroup: FetchedResults<Group>
    
    //    @State private var flag = true
    
    var body: some View {
        
        
        ScrollView(showsIndicators: false){
            VStack{
                AdBannerView().frame(height: 50)
                VStack {
                    
                    Text("NGSL単語学習状況(%)")
                    
                    Chart {
                        ForEach(mainGroup) { group in
                            BarMark(
                                x: .value("Value", convertPercentage(group: group)),
                                y: .value("Name", group.groupname ?? "nil")
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
                .background(Color("ItemColor"))
                .clipShape(.rect(cornerRadius: 10))
                
                chatKunView(chatText: "NGSL単語は、一般的な英文の92％以上を網羅しているんだって！")
                
                ForEach(mainGroup, id: \.id) { group in
                    GroupCell(group: group)
//                        .id(UUID())
                    //↑Viewが更新されるようになるためのid付与
                }
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle("日常単語(NGSL)")
        
    }
    
    private func convertPercentage(group: Group) -> Int {
        let wordCount = Int16(group.word?.count ?? 0)
        let total = group.total
        
        let wordCountDouble = Double(total - wordCount)
        let totalDouble = Double(total)
        
        if totalDouble == 0 {
            return 50
        }
        
        let percentage = (wordCountDouble / totalDouble) * 100
        return Int(percentage)
    }
    
}

#Preview {
    StudyWordView()
}
