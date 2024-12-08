//
//  WordCell.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/14.
//

import SwiftUI

struct WordCell: View {
    
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var speechRef: SpeechSynthesizer
    let word: Word
    private let height = UIScreen.main.bounds.height / 6
    @State private var isShowMoreSentence = false
    @State private var isFavorite = false
    @State private var isSafariViewPresented = false
    private let urlString: String
    
    init(word: Word) {
        self.word = word
        self.urlString = "https://tatoeba.org/ja/sentences/search?from=eng&query=\(word.english ?? "")&to=jpn"
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text(word.english ?? "")
                        .font(.largeTitle).bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    Spacer()
                    Button(action: {
                        speechRef.startSpeaking(speechText: word.english ?? "", isUS: true)
                    }, label: {
                        Image(systemName: "speaker.wave.2.circle")
                            .resizable()
                            .frame(width: 30, height:30)
                    })
                    .foregroundStyle(.yellow)
                    
                }
                HStack {
                    Spacer()
                    Text("[ \(word.pos ?? "") ]")
                        .foregroundStyle(Color.secondary)
                    Text(word.japanese ?? "")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        isFavorite.toggle()
                        word.isfavorite = isFavorite
                        dataController.save()
                    }, label: {
                        Image(systemName: isFavorite ? "star.circle.fill" : "star.circle")
                            .resizable()
                            .frame(width: 30, height:30)
                    })
                    .foregroundStyle(.yellow)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                Divider()
                
                Text(word.ensentence ?? "")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                
                Text(word.jpsentence ?? "")
                    .font(.subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                
                if isShowMoreSentence {
                    Divider()
                    
                    Button(action: {
                        isSafariViewPresented = true
                    }, label: {
                        Label("例文をもっと見る", systemImage: "eye")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 40,alignment:.center)
                            .background(Color.yellow)
                            .clipShape(.rect(cornerRadius: 10))
                    })
                    .sheet(isPresented: $isSafariViewPresented) {
                        if let url = URL(string: urlString) {
                            SafariView(url: url)
//                                    .ignoresSafeArea()
                        }
                    }
                }
            }
            
            //My単語帳で作成した単語なら削除可能
            if word.pos == nil {
                Button {
                    dataController.saveContext.delete(word)
                    dataController.save()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.white)
                        .padding([.top, .trailing], 8)
                        .padding(10)
                        .background(.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .itemStyle()
        .animation(.default, value: isShowMoreSentence)
        .onTapGesture {
            isShowMoreSentence.toggle()
        }
        .onAppear {
            isFavorite = word.isfavorite
        }
    }
}

#Preview {
    let previewContext = DataController().container.viewContext
    let testWord = Word(context: previewContext)
    testWord.english = "test"
    testWord.japanese = "テスト"
    testWord.pos = "名詞"
    testWord.ensentence = "I have a test"
    testWord.jpsentence = "テストがあります。"
    testWord.isfavorite = false
    
    return WordCell(word: testWord)
        .environment(\.managedObjectContext, previewContext)
        .environmentObject(SpeechSynthesizer())
}
