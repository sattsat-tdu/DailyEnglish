//
//  PlaySoundView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/11/01.
//

import SwiftUI
import AVFoundation
import AlertKit

//file:SoundViewModelとは無関係。このViewのみ独自で実装
class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onSpeechFinished: (() -> Void)?
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onSpeechFinished?()
    }
    
}

struct PlaySoundView: View {
    
    @Binding var isShowPlaySound : Bool
    @EnvironmentObject var dataController: DataController
    let group: Group
    let listeningInfo: ListeningInfo
    @State private var words: Set<Word> = []
    @State private var selectedWord: Word?
    @State private var spokenWords: Set<Word> = []
    @State private var itemCount = 0
    
    //透過関連
    @State private var isHiddenEN = true
    @State private var isHiddenJP = true
    @State private var isHiddenENSentence = true
    @State private var isHiddenJPSentence = true
    
    //音声関連
    private let synthesizer = AVSpeechSynthesizer()
    private let delegate = SpeechSynthesizerDelegate()
    @State private var isSpokenJP = false
    @State private var isReady = false
    @State private var isStopping = false
    @State private var speakerJP = "com.apple.ttsbundle.siri_female_ja-JP_compact"
    @State private var speakerUS = "com.apple.voice.compact.en-US.Samantha"
    
    //広告表示
    @EnvironmentObject var adMobRef: AdmobController
    
    
    var body: some View {
        if isReady {
            VStack(spacing : 30) {
                Text("リスニング学習")
                    .font(.title3.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("BackgroundColor"))
                    .clipShape(Capsule())
                    .padding(.top)
                
                Spacer()
                
                Text(selectedWord?.english ?? "Test")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .opacity(isHiddenEN ? 0 : 1)
//                    .animation(.easeInOut, value: isHiddenEN)
                Text(selectedWord?.japanese ?? "テスト")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .opacity(isHiddenJP ? 0 : 1)
                Divider()
                Text(selectedWord?.ensentence ?? "This is Test sentence.")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .opacity(isHiddenENSentence ? 0 : 1)
                Text(selectedWord?.jpsentence ?? "これは例文です。")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .opacity(isHiddenJPSentence ? 0 : 1)
                

                Spacer()
                
                Text("発音中にホームに戻ることで、\nバックグラウンド再生が可能です")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                
                Button(action: {
                    synthesizer.stopSpeaking(at: .immediate)
                    isStopping = true
                    adMobRef.showInterstitial {
                        isShowPlaySound.toggle()
                    }
                }, label: {
                    Label("リスニング学習をやめる", systemImage: "xmark.square")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50,alignment:.center)
                        .background(Color.yellow)
                        .clipShape(.rect(cornerRadius: 10))
                })
            }
            .padding()
            .onAppear {
                //listening学習を開始
                listeningStudy()
            }
        } else {
            LoadingView(loadingText: "音声を準備中...")
                .onAppear {
                    //単語とついていたら通常通りwordから取得
                    if let groupname = group.groupname {
                        if groupname.contains("単語") {
                            words = group.word as? Set<Word> ?? []
                        } else if groupname == "お気に入り" {
                            words = dataController.getFavoriteWords()
                        } else {
                            words = dataController.convertCSVtoWord(csvName: groupname)
                        }
                    }
                    //そのGroupに単語が存在しなければViewを閉じる
                    if let randomWord = words.randomElement() {
                        selectedWord = randomWord
                        spokenWords.insert(randomWord)
                        words.remove(randomWord)
                    } else {
                        isShowPlaySound.toggle()
                        AlertKitAPI.present(
                            title: "学習する単語がありませんでした",
                            icon: .error,
                            style: .iOS16AppleMusic,
                            haptic: .error
                        )
                        return
                    }
                    // AVSpeechSynthesizerのデリゲートを設定
                    synthesizer.delegate = delegate
                    // テキストを読み上げる処理
                    let utterance = AVSpeechUtterance(string: " ")
                    synthesizer.speak(utterance)
                    // 読み上げ完了時のコールバック
                    delegate.onSpeechFinished = {
                        // 読み上げが完了したらMainViewを表示
                        self.isReady = true
                        print("読み上げ準備が完了しました")
                    }
                }
        }
    }
    //リスニング学習を進めるコントローラー
    func listeningStudy() {
        let speechText = convertToWordString(item: listeningInfo.items[itemCount])
        speaking(
            speechText: speechText,
            isJP: isSpokenJP,
            speaker: isSpokenJP ? speakerJP : speakerUS)

        //再生し終わったら次の処理へ
        synthesizer.delegate = delegate
        delegate.onSpeechFinished = {
            print("読み上げ完了！")
            DispatchQueue.main.asyncAfter(deadline: .now() + listeningInfo.interval) {
                //閉じるボタンが押されていたら発音処理を行わない。
                if isStopping {
                    return
                } else {
                    itemCount += 1
                    if itemCount == listeningInfo.items.count {
                        //すべて話し終わったらWordをリセット
                        if words.isEmpty {
                            words = spokenWords
                        }
                        selectedWord = words.randomElement()
                        //すべて話し終わった後にリセットするため、一時保存
                        spokenWords.insert(selectedWord!)
                        //一度でたWordはまた出ないように削除
                        words.remove(selectedWord!)
                        resetVariable()
                        listeningStudy()
                    } else{
                        listeningStudy()
                    }
                }
            }
        }
        
    }
    //順番を定義した配列の一要素から、対応するWord型Stringを返す。
    func convertToWordString(item: String) -> String {
        switch item {
        case "単語 (英語)":
            isSpokenJP = false
            isHiddenEN = false
            return selectedWord?.english ?? "単語(英語)is nil"
        case "単語 (日本語)":
            isSpokenJP = true
            isHiddenJP = false
            return selectedWord?.japanese ?? "単語(日本語)is nil"
        case "例文 (英語)":
            isSpokenJP = false
            isHiddenENSentence = false
            return selectedWord?.ensentence ?? "例文(英語)is nil"
        case "例文 (日本語)":
            isSpokenJP = true
            isHiddenJPSentence = false
            return selectedWord?.jpsentence ?? "例文(日本語)is nil"
        default:
            print("発音させる単語が見つかりません。")
        }
        return ""
    }
    
    func speaking(speechText: String, isJP: Bool, speaker: String){
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: speechText)
//        utterance.voice = AVSpeechSynthesisVoice(language: isJP ? "jp-JP" : "en-US")
        utterance.voice = AVSpeechSynthesisVoice(identifier: speaker)
        utterance.volume = listeningInfo.voiceVolume
        //日本語発音の場合はスピードを変えない。
        utterance.rate = isJP ? 0.5 : listeningInfo.voiceSpeed
        synthesizer.speak(utterance)
    }
    
    func resetVariable() {
        itemCount = 0
        //透過を再設定
        speakerJP = SpeakerJP.allCases.randomElement()?.rawValue ?? "com.apple.ttsbundle.Kyoko-compact"
        speakerUS = SpeakerUS.allCases.randomElement()?.rawValue ?? "com.apple.voice.compact.en-US.Samantha"
        isHiddenEN = true
        isHiddenJP = true
        isHiddenENSentence = true
        isHiddenJPSentence = true
    }
}

#Preview {
    let previewContext = DataController().container.viewContext
    let testGroup = Group(context: previewContext)
    testGroup.groupname = "Part0 テスト単語"
    testGroup.total = 3264
    
    return PlaySoundView(
        isShowPlaySound: .constant(true),
        group: testGroup,
        listeningInfo: ListeningInfo())
}
