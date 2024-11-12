//
//  SpeechSynthesizerViewModel.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/29.
//

import AVFoundation
import UIKit

class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onSpeechFinished: (() -> Void)?
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onSpeechFinished?()
    }
}

class SpeechSynthesizer: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var delegate: SpeechSynthesizerDelegate?
    @Published var isLoading: Bool = true
    var volume: Float
    var effectVolume: Float
    
    //効果音
    var soundPlayer:AVAudioPlayer!

    init() {
        self.volume = StudyInfo.load().voiceVolume
        self.effectVolume = StudyInfo.load().effectVolume
        delegate = SpeechSynthesizerDelegate()
        delegate?.onSpeechFinished = {
            // 発音が完了した後の処理
            if self.isLoading {
                print("初期発音が完了しました")
                self.isLoading = false
            }
        }
        synthesizer.delegate = delegate
        // テキストを読み上げる処理
        let utterance = AVSpeechUtterance(string: " ")
        synthesizer.speak(utterance)
    }

    func startSpeaking(speechText:String, isUS: Bool) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        //日本語音声か英語音声か。
        let speaker: String = isUS ? SpeakerUS.allCases.randomElement()?.rawValue ?? "com.apple.voice.compact.en-US.Samantha" : SpeakerJP.allCases.randomElement()?.rawValue ?? "com.apple.ttsbundle.Kyoko-compact"
        let utterance = AVSpeechUtterance(string: speechText)
        utterance.voice = AVSpeechSynthesisVoice(identifier: speaker)
//        utterance.voice = AVSpeechSynthesisVoice(language: isUS ? "en-US" : "ja-JP")
        utterance.volume = volume
        synthesizer.speak(utterance)
    }
    
    func effectPlay(name: String) {
        let soundData = NSDataAsset(name: name)!.data
        soundPlayer = try! AVAudioPlayer(data: soundData)
        soundPlayer.volume = effectVolume
        soundPlayer.play()
    }
}
