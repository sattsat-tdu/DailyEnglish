//
//  ButtonWithImage.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/27.
//

import SwiftUI

struct ButtonWithImage: View {
    
    let text: String
    let imageName: String
    let color: Color
    let onClicked: () -> Void
    
    var body: some View {
        Button(action: {
            onClicked()
        }, label: {
            VStack{
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Text(text)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 90)
            .foregroundStyle(.black)
            .background(color)
            .clipShape(.rect(cornerRadius: 15))
        })
    }
}

#Preview {
    ButtonWithImage(text: "次の問題へ", imageName: "arrowshape.right",
                    color: .yellow, onClicked: {})
}
