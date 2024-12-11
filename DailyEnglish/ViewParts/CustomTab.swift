//
//  CustomTab.swift
//  DailyEnglish
//  
//  Created by SATTSAT on 2024/12/11
//  
//

import SwiftUI

enum TabList: CaseIterable {
    case home
    case chart
    case dictionary
    case mypage
    
    var iconImage: Image {
        switch self {
        case .home:
            return Image(systemName: "house")
        case .chart:
            return Image(systemName: "chart.line.uptrend.xyaxis")
        case .dictionary:
            return Image(systemName: "book")
        case .mypage:
            return Image(systemName: "person")
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "ホーム"
        case .chart:
            return "成長"
        case .dictionary:
            return "NGSL辞書"
        case .mypage:
            return "マイページ"
        }
    }
}

struct CustomTab: View {
    
    @Binding var selectedTab: TabList
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(TabList.allCases, id: \.self) { tab in
                    tabItem(tab)
                        .frame(maxWidth: .infinity) // 幅を均等に広げる
                        .tag(tab)
                    if tab != TabList.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .background(.item)
    }
    
    @ViewBuilder
    private func tabItem(_ tab: TabList) -> some View {
        Button(action: {
            selectedTab = tab
        }, label: {
            VStack {
                tab.iconImage
                
                Text(tab.title)
                    .font(.caption2).bold()
            }
            .foregroundStyle(.primary.opacity(selectedTab == tab ? 1 : 0.3))
        })
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CustomTab(selectedTab: .constant(.home))
}
