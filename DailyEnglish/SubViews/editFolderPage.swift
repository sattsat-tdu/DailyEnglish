//
//  editFolderPage.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/11/28.
//

import SwiftUI

struct editFolderPage: View {
    
    let folderName: String
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isShowEditView: Bool
    let onRemoved: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .fill(Color.secondary)
                .frame(width: 100, height: 8)
                .clipShape(Capsule())
            Spacer()
            Text(folderName)
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Button(action: {
                
            }, label: {
                Label("フォルダ名を変更する", systemImage: "pencil")
                    .font(.headline)
            })
            Divider()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                onRemoved()
            }, label: {
                Label("フォルダを削除する", systemImage: "trash")
                    .font(.headline)
            })
            Spacer()
        }
        .padding()
        .background(.mainBackground)
    }
}

#Preview {
    editFolderPage(folderName:"", isShowEditView: .constant(true), onRemoved: {})
}
