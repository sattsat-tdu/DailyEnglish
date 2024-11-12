//
//  GraphViewer.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/05/03.
//

import SwiftUI

struct BarGraph: View {
    
    var text = ""
    var value:CGFloat = 0
    
    var body: some View {
        VStack(alignment:.leading) {
            Text(text)
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .leading) {
                Capsule().frame(height: 30)
                    .foregroundStyle(.secondary.opacity(0.5))
                
                Capsule().frame(height: 30)
                    .foregroundStyle(orangeYellowGradient)
                    .scaleEffect(x: value ,y: 1, anchor: .leading)
            }
        }
    }
}
