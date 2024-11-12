//
//  PlayView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/16.
//

import SwiftUI
import AlertKit

private enum Viewswitcher {
    case question
    case answer
    case finish
}
private enum ShowWord: String, CaseIterable {
    case incorrect = "間違えた単語"
    case correct = "正解した単語"
    case all = "全ての単語"
}
enum LevelOfMastery: String, CaseIterable {
    case goodWord = "得意単語"
    case subtleWord = "微妙単語"
    case badWord = "苦手単語"
}

struct PlayView: View {
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) private var presentationMode
    //発音させるためのViewModelを取得。
    @EnvironmentObject var speechRef: SpeechSynthesizer
    //広告表示のため
    @EnvironmentObject var adMobRef: AdmobController
    
    let group:Group
    
    //暗記シートを今回の起動時に使ったかどうか
    @AppStorage("isUsedAnki") var isUsedAnki = false
    @State private var inductionAdAlert = false
    //設定のロード
    let studyInfo: StudyInfo = StudyInfo.load()
    //グループからWordを取得
    @State private var words: Set<Word> = []
    //正解した問題を格納
    @State private var correctWords: Set<Word> = []
    //Partを含んだ、最初に学ぶ単語たちかどうか
    @State private var isPartWords = true
    //復習ボタン使用時は問題の移動を行わないように
    @State private var isReviewMode = false
    //間違えた問題を格納
    @State private var incorrectWords: Set<Word> = []
    @State private var selectedWord: Word?
    @State private var inCorrectWord = ""
    @State private var viewSwitcher:Viewswitcher = .question
    @State private var isTapChoices = false
    @State private var choicesWords: [String] = []
    @State private var quizCount = 0
    @State private var isfavorite = false
    @State private var isHideAnki = false
    //最大問題数を取得
    @State private var numberOfPlay = 0
    @State private var selectedSlide: ShowWord = .incorrect
    //Timer機能
    @State private var remainingTime = 10 // カウントダウンする秒数
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    //SafariView
    @State private var isSafariViewPresented = false
    @State private var urlString = ""
    
    @State private var isShowNextGroup = false
    
    var body: some View {
        VStack {
            switch viewSwitcher {
            case .question:
                VStack(spacing:25) {
                    HStack {
                        if numberOfPlay < 20 {
                            // 上部に何問目かを表示
                            ForEach(0..<numberOfPlay, id: \.self) { index in
                                if index < quizCount {
                                    Rectangle()
                                        .fill(.yellow)
                                        .frame(height: 4)
                                } else {
                                    Rectangle()
                                        .fill(Color.primary.opacity(0.2))
                                        .frame(height: 4)
                                }
                            }
                        } else {
                            Text("\(quizCount) / \(numberOfPlay)")
                        }
                        
                    }
                    HStack {
                        //Timer処理
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 10)
                                .foregroundStyle(Color.secondary.opacity(0.5))
                            Circle()
                                .trim(from: 0, to: CGFloat(remainingTime) / CGFloat(studyInfo.timeLimit)) // カウントダウンの進捗を表示
                                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                                .foregroundStyle(.yellow)
                                .rotationEffect(.degrees(-90))
                            Text("\(remainingTime)")
                                .font(.headline)
                        }
                        .onReceive(timer) { _ in
                            withAnimation {
                                if self.remainingTime > 0 {
                                    self.remainingTime -= 1
                                } else {
                                    isHideAnki = true
                                    //時間切れ処理、強制苦手単語
                                    timer.upstream.connect().cancel()//Timer停止
                                    quizCount += 1
                                    isTapChoices = true
                                    moveWord(destination: .badWord)
                                }
                            }
                        }
                        .frame(width: 60, height: 60)
                        
                        Spacer()
                        
                        Button(action: {
                            //前の画面へ
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.primary.opacity(0.4))
                                .font(.system(size: 40, weight: .bold))
                        })
                    }
                    Button(action:{
                        speechRef.startSpeaking(speechText: selectedWord?.english ?? "", isUS: true)
                    }, label: {
                        Text(selectedWord?.english ?? "Test")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.primary)
                            .padding(.top,70)
                    })
                    
                    Text(selectedWord?.pos ?? "名詞")
                        .font(.title2)
                        .foregroundStyle(Color.secondary)
                    
                    Spacer()
                    
                    //4択か直接か
                    if studyInfo.isDirectMode{
                        HStack {
                            ButtonWithImage(
                                text: "苦手",
                                imageName: "person.fill.questionmark",
                                color: .cyan,
                                onClicked: {
                                    timer.upstream.connect().cancel()//Timer停止
                                    quizCount += 1
                                    isTapChoices = true
                                    moveWord(destination: .badWord)
                                })
                            ButtonWithImage(
                                text: "微妙",
                                imageName: "person.fill",
                                color: .yellow,
                                onClicked: {
                                    timer.upstream.connect().cancel()//Timer停止
                                    quizCount += 1
                                    isTapChoices = true
                                    moveWord(destination: .subtleWord)
                                })
                            ButtonWithImage(
                                text: "得意",
                                imageName: "person.fill.checkmark",
                                color: .orange,
                                onClicked: {
                                    timer.upstream.connect().cancel()//Timer停止
                                    quizCount += 1
                                    isTapChoices = true
                                    moveWord(destination: .goodWord)
                                })
                            
                        }
                        .disabled(isTapChoices)
                    } else {
                        //暗記シートを使っているかどうか
                        if studyInfo.useAnki && !isHideAnki {
                            VStack(spacing: 15) {
                                Button(action: {
                                    isHideAnki = true
                                    speechRef.effectPlay(name: "bookFlipSound")
                                }, label: {
                                    Label("回答する", systemImage: "lightbulb.max")
                                        .font(.title2.bold())
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 150)
                                        .background(.orange)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .shadow(radius: 1)
                                })
                                Button(action: {
                                    isHideAnki = true
                                    //時間切れ処理、強制苦手単語
                                    timer.upstream.connect().cancel()//Timer停止
                                    quizCount += 1
                                    isTapChoices = true
                                    moveWord(destination: .badWord)
                                }, label: {
                                    Label("スキップする", systemImage: "questionmark")
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 60)
                                        .background(.yellow)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .shadow(radius: 1)
                                })
                            }
                        } else {
                            ForEach(choicesWords, id: \.self){ word in
                                Button(action: {
                                    
                                    afterChoiceEvent(word: word)
                                    
                                }, label: {
                                    Text(word)
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 60,alignment:.center)
                                        .background(isTapChoices && selectedWord?.japanese == word ? .orange : (inCorrectWord == word ? .blue : Color("ItemColor")))
                                        .clipShape(.rect(cornerRadius: 10))
                                        .shadow(radius: 1)
                                })
                                .disabled(isTapChoices)
                            }
                        }
                    }
                }
                .onAppear {
                    //画面が表示されたら発音
                    speechRef.startSpeaking(speechText: selectedWord?.english ?? "", isUS: true)
                }
                .padding()
                //-------------------question処理終------------------------------
            case .answer:
                VStack(spacing:20) {
                    Button(action: {
                        speechRef.startSpeaking(speechText: selectedWord?.english ?? "", isUS: true)
                    }, label: {
                        Text(selectedWord?.english ?? "Test")
                            .font(.system(size: 70.0).bold())
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    })
                    .padding(.top,50)
                    Text(selectedWord?.pos ?? "名詞")
                        .font(.title2)
                        .foregroundStyle(Color.secondary)
                    
                    Divider()
                    HStack {
                        Image(systemName: "circle.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.red)
                        Spacer()
                        Text(selectedWord?.japanese ?? "nil")
                            .font(.title.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        Spacer()
                    }
                    if inCorrectWord != "" {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.blue)
                            Spacer()
                            Text(inCorrectWord)
                                .font(.title.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            Spacer()
                        }
                    }
                    Divider()
                    HStack {
                        Spacer()
                        Text("- 例文 -")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            speechRef.startSpeaking(speechText: selectedWord?.ensentence ?? "", isUS: true)
                        }, label: {
                            Image(systemName: "speaker.wave.2.circle")
                                .resizable()
                                .frame(width: 40, height:40)
                        })
                        .foregroundStyle(.yellow)
                    }
                    .padding(.horizontal)
                    Text(selectedWord?.ensentence ?? "")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    Text(selectedWord?.jpsentence ?? "")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    Spacer()
                    
                    
                    HStack {
                        Button(action: {
                            //tatoebaの表示
                            isSafariViewPresented.toggle()
                        }, label: {
                            VStack{
                                Image(systemName: "character.book.closed.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                                Text("もっと例文")
                                    .font(.headline)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.black)
                            .background(.yellow)
                            .clipShape(.rect(cornerRadius: 15))
                        })
                        .sheet(isPresented: $isSafariViewPresented) {
                            if let url = URL(string: urlString) {
                                SafariView(url: url)
//                                    .ignoresSafeArea()
                            }
                        }
                        //お気に入りに追加ボタン
                        ButtonWithImage(
                            text:isfavorite ? "削除" : "追加",
                            imageName: isfavorite ? "star.fill" : "star",
                            color: .yellow,
                            onClicked: {
                                isfavorite.toggle()
                                selectedWord?.isfavorite = isfavorite
                                dataController.save()
                            })
                        ButtonWithImage(
                            text: quizCount == numberOfPlay ? "解説へ" : "次の問題へ",
                            imageName: "arrowshape.right",
                            color: .cyan,
                            onClicked: {
                                if quizCount >= numberOfPlay {
                                    viewSwitcher = .finish
                                } else {
                                    //変数の状態をリセットし、次の問題へ
                                    words.remove(selectedWord!)
                                    ResetVariable()
                                }
                            })
                    }
                }
                .padding()
                //-------------------answer処理終------------------------------
            case .finish:
                VStack {
                    let correctRate:Double = Double(correctWords.count) / Double(numberOfPlay) * 100
                    let rateString = String(format: "%.0f", correctRate)
                    (
                        Text("\(rateString) %")
                            .font(.system(size: 60))
                            .bold()
                        
                        
                        +
                        
                        Text("　正解！")
                            .font(.title3).bold()
                    )
                    .foregroundStyle(.white)
                    .padding(.bottom, -10)
                    chatKunView(chatText: "伸び代しかないね！！！")
                    VStack {
                        Spacer()
                        Picker("問題を表示", selection: $selectedSlide) {
                            ForEach(ShowWord.allCases, id: \.self){
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        ScrollView(showsIndicators: false) {
                            LazyVStack {
                                
                                var wordsToDisplay: Set<Word> {
                                    switch selectedSlide {
                                    case .incorrect:
                                        return incorrectWords
                                    case .correct:
                                        return correctWords
                                    case .all:
                                        return incorrectWords.union(correctWords)
                                    }
                                }
                                
                                if !wordsToDisplay.isEmpty{
                                    ForEach(Array(wordsToDisplay)) { word in
                                        WordCell(word: word)
                                    }
                                } else {
                                    Text(selectedSlide == .incorrect ? "おめでとうございます！\n全問正解です！" : "正解した問題はありませんでした。\n全問正解目指して頑張りましょう！")
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                        HStack {
                            ButtonWithImage(
                                text: "閉じる",
                                imageName: "xmark.circle",
                                color: .yellow,
                                onClicked: {
                                    //確率で広告表示
                                    adMobRef.showInterstitial {
                                        //前の画面へ
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                })
                            //間違えた問題があれば復習ボタンを表示
                            if !incorrectWords.isEmpty {
                                ButtonWithImage(
                                    text: "復習",
                                    imageName: "arrow.triangle.2.circlepath.circle",
                                    color: .yellow,
                                    onClicked: {
                                        //初期データのリセット
                                        quizCount = 0
                                        words = incorrectWords
                                        numberOfPlay = words.count
                                        correctWords.removeAll()
                                        incorrectWords.removeAll()
                                        //変数状態のリセットなどを管理する関数
                                        ResetVariable()
                                        isReviewMode = true
                                    })
                            }
                            //group変数でさえ整える。
                            if group.groupname != "仮グループ" {
                                Button(action: {
                                    //確率で広告表示後遷移
                                    adMobRef.showInterstitial{
                                        quizCount = 0
                                        correctWords.removeAll()
                                        incorrectWords.removeAll()
                                        initInfo()
                                        ResetVariable()
                                    }
                                }, label: {
                                    VStack{
                                        Image(systemName: "arrowshape.right.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 30)
                                        Text("次の問題へ")
                                            .font(.headline)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.black)
                                    .background(.cyan)
                                    .clipShape(.rect(cornerRadius: 15))
                                })
                                .fullScreenCover(isPresented: $isShowNextGroup) {
                                    PlayView(group: group)
                                }
                            }
                        }
                        .padding()
                        Spacer()
                            .frame(height: 20)
                    }
                    .background(Color("BackgroundColor"))
                    .clipShape(.rect(cornerRadius: 40))
                    //下画面いっぱいまで広げる。
                    .ignoresSafeArea(edges: [.bottom])
                }
                .background(blueBaseGradient)
                //-------------------finish処理終------------------------------
            }
        }
        .background(Color("BackgroundColor"))
        .onAppear(perform: initInfo)
        //暗記チケットが足りない時
        .alert("チケットが足りません", isPresented: $inductionAdAlert) {
            Button("キャンセル"){
                presentationMode.wrappedValue.dismiss()
            }
            Button("広告を見て学習する"){
                print("リワード広告の実装")
            }
        } message: {
            Text("暗記シートを利用するためのチケットが足りません。\n\n広告を見ることで特別に暗記シートを利用することができます。")
        }
    }
    //初期データの設定
    func initInfo() {
        print("PlayViewが呼び出されています。")
        if let groupname = group.groupname {
            if groupname == "お気に入り" {
                //お気に入り単語のみを取得
                words = dataController.getFavoriteWords()
                if words.isEmpty {
                    AlertKitAPI.present(
                        title: "学習する単語がありませんでした",
                        icon: .error,
                        style: .iOS16AppleMusic,
                        haptic: .error
                    )
                    presentationMode.wrappedValue.dismiss()
                    return
                }
            } else {
                if group.word?.count == 0 {
                    if groupname.contains("Part") {
                        //groupnameのCSVデータをすべて取得
                        words = dataController.convertCSVtoWord(csvName: groupname)
                        AlertKitAPI.present(
                            title: "学習済み",
                            subtitle: "\(groupname):\(words.count)単語から出題",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                        //暗記シート使用と判断、一枚消費
                        if studyInfo.useAnki && !studyInfo.isDirectMode && !isUsedAnki {
                            if studyInfo.ankiTicket == 0 {
                                timer.upstream.connect().cancel()//Timer停止
                                inductionAdAlert = true
                            } else {
                                isUsedAnki = true
                                var newStudyInfo = studyInfo
                                newStudyInfo.ankiTicket -= 1
                                newStudyInfo.save()
                            }
                        }
                    } else {
                        AlertKitAPI.present(
                            title: "学習する単語がありませんでした",
                            icon: .error,
                            style: .iOS16AppleMusic,
                            haptic: .error
                        )
                        presentationMode.wrappedValue.dismiss()
                        return
                    }
                } else {
                    //groupnameからWordを取得
                    words = group.word as? Set<Word> ?? []
                    //NGSL初期問題を問いているかどうか
                    isPartWords = group.groupname?.contains("Part") ?? false
                    print(isPartWords)
                    //暗記シート使用と判断、一枚消費
                    if studyInfo.useAnki && !studyInfo.isDirectMode && !isUsedAnki {
                        if studyInfo.ankiTicket == 0 {
                            timer.upstream.connect().cancel()//Timer停止
                            inductionAdAlert = true
                        } else {
                            isUsedAnki = true
                            var newStudyInfo = studyInfo
                            newStudyInfo.ankiTicket -= 1
                            newStudyInfo.save()
                        }
                    }
                }
            }
        }
        numberOfPlay = min(studyInfo.wordNum, words.count)
        //問題の取得
        selectedWord = words.randomElement()
        choicesWords = getRandomWordFromCSV(selectedWord: selectedWord)
        //tatoebaサイトの準備
        urlString = "https://tatoeba.org/ja/sentences/search?from=eng&query=\(selectedWord?.english ?? "")&to=jpn"
        isfavorite = selectedWord?.isfavorite ?? false
        remainingTime = studyInfo.timeLimit
    }
    
    //変数状態のリセット、次の問題へボタンを押したとき呼ばれる。
    func ResetVariable() {
        isHideAnki = false
        isTapChoices = false
        inCorrectWord = ""
        remainingTime = studyInfo.timeLimit
        //問題の取得
        selectedWord = words.randomElement()
        choicesWords = getRandomWordFromCSV(selectedWord: selectedWord)
        //tatoebaサイトの準備
        urlString = "https://tatoeba.org/ja/sentences/search?from=eng&query=\(selectedWord?.english ?? "")&to=jpn"
        isfavorite = selectedWord?.isfavorite ?? false
        viewSwitcher = .question
    }
    
    //単語の移動処理
    func moveWord(destination: LevelOfMastery){
        // 復習問題を学習中であったらif以下を実行
        // 微妙単語を正解したら習得単語に、苦手単語→微妙単語に移動
        if !isPartWords, let groupname = selectedWord?.group?.groupname {
            switch destination{
                
            case .goodWord:
                speechRef.effectPlay(name: "correctSound")
                correctWords.insert(selectedWord!)
                if groupname == "微妙単語"{
                    dataController.moveWordToGroup(targetGroup: "習得単語", word: selectedWord)
                    
                } else if groupname == "苦手単語"{
                    dataController.moveWordToGroup(targetGroup: "微妙単語", word: selectedWord)
                    
                }
            case .subtleWord:
                speechRef.effectPlay(name: "uncertainSound")
                incorrectWords.insert(selectedWord!)
                
            case .badWord:
                dataController.moveWordToGroup(targetGroup: "苦手単語", word: selectedWord)
                speechRef.effectPlay(name: "inCorrectSound")
                incorrectWords.insert(selectedWord!)
            }
            
        } else {
            switch destination {
            case .goodWord:
                if !isReviewMode {
                    dataController.moveWordToGroup(targetGroup: "習得単語", word: selectedWord)
                }
                speechRef.effectPlay(name: "correctSound")
                correctWords.insert(selectedWord!)
                
            case .subtleWord:
                if !isReviewMode{
                    dataController.moveWordToGroup(targetGroup: "微妙単語", word: selectedWord)
                }
                speechRef.effectPlay(name: "uncertainSound")
                incorrectWords.insert(selectedWord!)
                
            case .badWord:
                if !isReviewMode {
                    dataController.moveWordToGroup(targetGroup: "苦手単語", word: selectedWord)
                }
                speechRef.effectPlay(name: "inCorrectSound")
                incorrectWords.insert(selectedWord!)
            }
        }
        //Viewの移動処理も記載
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            viewSwitcher = .answer
        }
    }
    
    //問題のどれかを選択した後の処理（4択モードのみでの呼び出し）
    func afterChoiceEvent(word:String) {
        timer.upstream.connect().cancel()//Timer停止
        quizCount += 1
        isTapChoices = true
        if word == selectedWord?.japanese {
            //時間ギリギリに正解すると微妙単語へ
            if Float(remainingTime)/Float(studyInfo.timeLimit) <= 0.2{
                moveWord(destination: .subtleWord)
            } else {
                //”習得単語”へ移動
                moveWord(destination: .goodWord)
            }
        } else {
            inCorrectWord = word
            //”苦手単語”へ移動
            moveWord(destination: .badWord)
        }
    }
}

//正解以外の選択肢を取得するのに必要
private func getRandomWordFromCSV(selectedWord:Word?)->[String] {
    let pos:String = selectedWord?.pos ?? "名詞"
    let posWithoutSpaces = pos.replacingOccurrences(of: " ", with: "")
    let correctWord:String = selectedWord?.japanese ?? "テスト"
    let csvBundle = Bundle.main.path(forResource: posWithoutSpaces, ofType: "csv")
    do {
        let csvData = try String(contentsOfFile: csvBundle!, encoding: .utf8)
        let lines = csvData.components(separatedBy: "\n")
        // 最初の行はヘッダーなので削除
        let dataRows = Array(lines.dropFirst())
        //ランダムに選ばれた単語を初期値に四つデータを取得
        var randomWords: [String] = [correctWord]
        //一度問題文が出たものは表示しないようにする定数
        var ngWords:Set<String> = [correctWord]
        
        while randomWords.count < 4 {
            let randomRow = dataRows.randomElement()
            let columns = randomRow?.components(separatedBy: ",")
            if let columns = columns,
               columns.count >= 2,
               !ngWords.contains(columns[0]) {
                ngWords.insert(columns[0])
                randomWords.append(columns[1])
            }
        }
        randomWords.shuffle()
        return randomWords
        
    } catch {
        print("データが見つかりませんでした")
    }
    return []
}

#Preview {
    let previewContext = DataController().container.viewContext
    let testGroup = Group(context: previewContext)
    testGroup.groupname = "Part0 テスト単語"
    testGroup.total = 3264
    
    @State var words: Set<Word> = []
    let testWord = Word(context: previewContext)
    testWord.id = UUID()
    testWord.english = "test"
    testWord.japanese = "テスト"
    testWord.pos = "名詞"
    testWord.ensentence = "I have a test"
    testWord.jpsentence = "テストがあります。"
    testWord.group = testGroup
    
    return PlayView(group: testGroup)
        .environment(\.managedObjectContext, previewContext)
    
}
