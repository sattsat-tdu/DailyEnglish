//
//  ChertView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

enum ChartType: String, CaseIterable{
    case forgettingCurve = "忘却曲線"
    case ngslGraph = "NGSL単語"
    case masteryGraph = "習得度"
}

struct ChertView: View {
    
    @State private var activeTab:ChartType = .forgettingCurve
    @Namespace private var animation
    
    var body: some View {
        VStack {
            Text("成長記録")
                .font(.title2).bold()
            selectTabs()
            
            switch activeTab {
            case .forgettingCurve:
                forgettingCurveView()
            case .ngslGraph:
                ngslGraphView()
            case .masteryGraph:
                masteryGraphView()
            }
        }
        .navigationTitle("成長記録")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
    }
    
    //タブ画面を構成
    @ViewBuilder
    func selectTabs() -> some View {
        HStack(spacing: 10) {
            ForEach(ChartType.allCases, id: \.rawValue) { type in
                Text(type.rawValue)
                    .foregroundStyle(.black)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding()
                    .background(alignment:.bottom, content: {
                        if activeTab == type {
                            Capsule()
                                .fill(.white)
                                .frame(height: 5)
                                .padding(.horizontal, -5)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    })
                    .padding(.horizontal, 15)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)){
                            activeTab = type
                        }
                    }
            }
        }
        .background(.yellow)
    }
}

#Preview {
    ChertView()
}
