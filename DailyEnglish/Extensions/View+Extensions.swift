//
//  View+Extensions.swift
//  DailyEnglish
//  
//  Created by SATTSAT on 2024/12/09
//  
//


import SwiftUI

extension View {
    func itemStyle() -> some View {
        self
            .background(
                Color.item
                    .clipShape(.rect(cornerRadius: 8))
                    .shadow(color: Color.black.opacity(0.1), radius: 3))// カスタムの影)
    }
}
