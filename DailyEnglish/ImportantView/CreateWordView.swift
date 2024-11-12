//
//  CreateWordView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/11/08.
//

import SwiftUI
import AlertKit

struct CreateWordView: View {
    
    //    @Binding var myWord: [MyWord]
    var onCreated: (MyWord) -> Void
    @Environment(\.presentationMode) private var presentationMode
    @State private var englishText = ""
    @State private var japaneseText = ""
    
    //広告表示
    @EnvironmentObject var adMobRef: AdmobController
    
    enum FocusType:Hashable{
        case english
        case japanese
    }
    @FocusState var focus:FocusType?
    
    var body: some View {
        ZStack(alignment : .topTrailing) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Text("単語を作成")
                        .foregroundStyle(Color.primary)
                        .font(.headline)
                    Spacer()
                }
                Text("英語")
                TextField("    make (英語を入力)", text: $englishText)
                    .keyboardType(.alphabet)
                    .frame(height: 50)
                    .background(Color("ItemColor"))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .focused($focus, equals: FocusType.english)
                    .onSubmit {
                        focus = .japanese
                    }
                    .submitLabel(.next)
                
                Text("↑     ↓")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("日本語")
                TextField("    作る (日本語を入力)", text: $japaneseText)
                    .keyboardType(.default)
                    .frame(height: 50)
                    .background(Color("ItemColor"))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .focused($focus, equals: FocusType.japanese)
                    .onSubmit {
                        afterMakeWord()
                    }
                    .submitLabel(.done)
                
                Button(action: {
                    afterMakeWord()
                }, label: {
                    Text("作成")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50,alignment:.center)
                        .background(Color.yellow)
                        .clipShape(.rect(cornerRadius: 10))
                })
                Spacer()
            }
            Button(action: {
                adMobRef.showInterstitial {
                    //前の画面へ
                    presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.primary.opacity(0.4))
                    .font(.system(size: 40, weight: .bold))
            })
        }
        .padding()
        .background(Color("BackgroundColor"))
        .onAppear {
            focus = .english
        }
    }
    func afterMakeWord(){
        if englishText.isEmpty || japaneseText.isEmpty {
            AlertKitAPI.present(
                title: "英語と日本語の入力は必須です",
                icon: .error,
                style: .iOS16AppleMusic,
                haptic: .error
            )
            focus = .japanese
        } else {
            let createdWord = MyWord(id: UUID(),
                                     english: englishText,
                                     japanese: japaneseText)
            onCreated(createdWord)
            AlertKitAPI.present(
                title: "作成しました",
                icon: .done,
                style: .iOS17AppleMusic,
                haptic: .success
            )
            englishText = ""
            japaneseText = ""
            focus = .english
        }
    }
}

#Preview {
    CreateWordView(onCreated: {_ in
        
    })
}
