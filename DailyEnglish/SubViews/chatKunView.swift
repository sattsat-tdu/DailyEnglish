//
//  chatKunView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/21.
//

import SwiftUI

struct chatKunView: View {
    
    let chatText: String
    var body: some View {
        HStack {
            VStack {
                Image("chatKun")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .padding(4)
                    .background(Color.primary.opacity(0.1))
                    .clipShape(Circle())
                Text("ダンダイ")
                    .foregroundStyle(Color.secondary)
            }
            
            Text(chatText)
                .padding()
                .foregroundStyle(.black)
                .background(.yellow)
                .clipShape(BubbleShape())
        }
    }
}

struct BubbleShape: Shape {
    func path(in rect:CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 20, y: height))
        path.addLine(to: CGPoint(x: width - 15, y: height))
        path.addCurve(to: CGPoint(x: width, y: height - 15),
                      controlPoint1: CGPoint(x: width - 8, y: height),
                      controlPoint2: CGPoint(x: width, y: height - 8))
        path.addLine(to: CGPoint(x: width, y: 15))
        path.addCurve(to: CGPoint(x: width - 15, y: 0),
                      controlPoint1: CGPoint(x: width, y: 8),
                      controlPoint2: CGPoint(x: width - 8, y: 0))
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addCurve(to: CGPoint(x: 5, y: 15),
                      controlPoint1: CGPoint(x: 12, y: 0),
                      controlPoint2: CGPoint(x: 5, y: 8))
        path.addLine(to: CGPoint(x: 5, y: height - 10))
        path.addCurve(to: CGPoint(x: 0, y: height),
                      controlPoint1: CGPoint(x: 5, y: height - 1),
                      controlPoint2: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: -1, y: height))
        path.addCurve(to: CGPoint(x: 12, y: height - 4),
                      controlPoint1: CGPoint(x: 4, y: height + 1),
                      controlPoint2: CGPoint(x: 8, y: height - 1))
        
        
        return Path(path.cgPath)
    }
}

#Preview {
    chatKunView(chatText: "サンプルテキストです。")
}
