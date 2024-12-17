//
//  MyWordsView.swift
//  DailyEnglish
//  
//  Created by SATTSAT on 2024/12/14
//  
//

import SwiftUI

struct MyWordsView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name)]
    ) var groups: FetchedResults<Group>
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(groups, id: \.self) { group in
                    GroupCell(group: group)
                }
            }
        }
    }
}

#Preview {
    MyWordsView()
}
