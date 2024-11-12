//
//  ngslGraphView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/04/26.
//

import SwiftUI
import Charts

struct ngslGraphView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.groupname)],
        predicate: NSPredicate(format: "groupname CONTAINS[cd] %@", "Part")
    ) var mainGroup: FetchedResults<Group>
    
    @State private var part1Value:CGFloat = 0
    @State private var part2Value:CGFloat = 0
    @State private var part3Value:CGFloat = 0
    @State private var maxPercent: CGFloat = 0
    @State private var maxGroupName = "サンプルグループ"
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 15) {
                VStack(spacing: 15) {
                    
                    Text("NGSL単語学習状況(%)")
                        .font(.headline)
                    
                    BarGraph(text: "Part1単語", value: part1Value)
                    BarGraph(text: "Part2単語", value: part2Value)
                    BarGraph(text: "Part3単語", value: part3Value)
                    
                    //まだ未回答だったら
                    if maxPercent == 0 {
                        Text("目標は、このグラフをすべてカラーに染めることです！\n少しずつ、頑張っていきましょう！")
                            .font(.footnote)
                            .padding(.top)
                    } else {
                        Text("\(maxGroupName)を\(Int(maxPercent * 100))学習されていますね！！\nこの調子でNGSL単語をマスターしていきましょう！")
                            .font(.footnote)
                            .padding(.top)
                    }
                }
                .padding()
                .background(Color("ItemColor"))
                .clipShape(.rect(cornerRadius: 10))
                .shadow(radius: 3) 
                
                //リンクへ飛ばす。
                Link(destination: URL(string: "https://apps.apple.com/jp/developer/daisuke-ishii/id1609332032")!) {
                    HStack {
                        VStack(spacing: 10) {
                            Text("休憩時間にどうですか？ 〉")
                                .font(.headline)
                                .foregroundStyle(.black)
                            Text("sattsatはゲームも開発しています。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        
                        Image("MyAdIMG")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .buttonStyle(.plain)
                .frame(height: 80)
                .padding()
                .background(.teal)
                .clipShape(.rect(cornerRadius: 10))
                
                
                Text("学習する")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(.top)
                
                ForEach(mainGroup) { group in
                    GroupCell(group: group)
                }
                
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                if let part1Group = mainGroup.filter({ $0.groupname == "Part1 words" }).first {
                    part1Value = convertPercentage(group: part1Group)
                    maxPercent = part1Value
                    maxGroupName = "Part1単語"
                }
                if let part2Group = mainGroup.filter({ $0.groupname == "Part2 words" }).first {
                    part2Value = convertPercentage(group: part2Group)
                    if maxPercent < part2Value {
                        maxPercent = part2Value
                        maxGroupName = "Part2単語"
                    }
                }
                if let part3Group = mainGroup.filter({ $0.groupname == "Part3 words" }).first {
                    part3Value = convertPercentage(group: part3Group)
                    if maxPercent < part3Value {
                        maxPercent = part3Value
                        maxGroupName = "Part3単語"
                    }
                }
            }
        }

    }
    private func convertPercentage(group: Group) -> CGFloat {
        let wordCount = Int16(group.word?.count ?? 0)
        let total = group.total
        
        let wordCountDouble = Double(total - wordCount)
        let totalDouble = Double(total)
        
        if totalDouble == 0 {
            return 50
        }
        
        let percentage = wordCountDouble / totalDouble
        return percentage
    }
}

#Preview {
    ngslGraphView()
}
