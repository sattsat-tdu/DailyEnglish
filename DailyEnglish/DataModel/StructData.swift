//
//  StructData.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/14.
//

import Foundation
import SwiftUI

//メインのデータの大きいグループ
let mainGroups = ["Part1 words","Part2 words","Part3 words"]

//グループの作成
let subGroups = ["お気に入り","仮グループ","苦手単語","微妙単語", "習得単語"]

let zeroToTwentyMessage = ["伸び代しかないね！！！！",
                           "やる気しか感じない、うん。",
                           "良かった。君はまだまだ強くなれる。",
                           "ひどい。",
                           "おいおいまじか",
                           "え、目隠ししてやった...?",
                           "レベルを見直してみよう！",
                           "敬意を払え",
                           "脳みそが疲れているようだ。",
                           "（ダンダイは寝ている...）"
]
let twentyToFortyMessage = ["ノーコメントで、、",
                            "ちょ待てよ、",
                            "中途半端だね（笑）",
                            "まずい。",
                            "そんなんで海賊王なれんの？",
                            "君には凄みがあるｯ！",
                            "繰り返し学習しよう！",
                            "ちょっと〜、目が寝てるよーっ？",
                            "はにゃ？",
                            "(ダンダイは黙秘を続けている。)"
]
let fortyToSixtyMessage = ["大学のテストならギリ落単してる。",
                           "まだまだこっから",
                           "非常にジューシーですね。",
                           "微妙。",
                           "エゴイストが足りてない。",
                           "繰り返し学習しよう。",
                           "君シーソーで真ん中いるタイプでしょ！",
                           "姿勢良さそう。",
                           "高校生なら落単してないからおけ。",
                           "(ダンダイは様子を見ている。)"
]
let sixtyToEightyMessage = ["惜しい！！！",
                            "そのまま進め。そこに道はある",
                            "今日は親にありがとうと伝えよう。",
                            "意外とできてて草",
                            "やるじゃねぇか",
                            "ダンダイと同じくらいの頭脳してる。",
                            "満点取るまで努力してるとは言えん",
                            "まずい、尾が８本！？",
                            "あと少し！！！",
                            "(ダンダイは嬉しそうにしている。)"
]
let eightyToMessage = ["え！天才！！",
                       "フッ。お前がナンバー１だ。",
                       "発明できるんじゃね。知らんけど",
                       "優秀で草",
                       "多分東大レベル（知らんけど）",
                       "一緒にmensa会員にならないか？",
                       "復習を忘れずにね！",
                       "今日は奢ってやる。",
                       "MBTI何？参考にしたい",
                       "(ダンダイは嬉しそうに走っている。)"
]

//発音する人を指定できるように
enum SpeakerJP: String, CaseIterable, Codable {
    //    case kyoko = "com.apple.ttsbundle.Kyoko-compact"
    case female_Siri = "com.apple.ttsbundle.siri_female_ja-JP_compact"
    //    case otoya = "com.apple.ttsbundle.Otoya-premium"
    case male_Siri = "com.apple.ttsbundle.siri_male_ja-JP_compact"
    
    var displayName: String {
        // ケース名を返す
        return "\(self)"
    }
}


//発音する人を指定、英語Ver
enum SpeakerUS: String, CaseIterable, Codable {
    case samantha = "com.apple.voice.compact.en-US.Samantha"
    case aaron = "com.apple.ttsbundle.siri_Aaron_en-US_compact"
    
    var displayName: String {
        // ケース名を返す
        return "\(self)"
    }
}
//-----------------β版-----------
//リスニングに関する設定
struct Testt: Codable {
    var speakerJP:SpeakerJP = .female_Siri
    var speakerUS: SpeakerUS = .samantha
}

extension Testt {
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "speak")
            print("Saveに成功！")
        }
    }
    
    static func load() -> Testt {
        if let data = UserDefaults.standard.data(forKey: "speak"),
           let speaker = try? JSONDecoder().decode(Testt.self, from: data) {
            print("ロードに成功 : \(speaker)")
            return speaker
        }
        print("ロードに失敗")
        return Testt(speakerJP: .female_Siri, speakerUS: .samantha)
    }
}

//-----------------/β版-----------


//学習設定に関する情報
struct StudyInfo: Codable {
    var timeLimit: Int = 5
    var wordNum: Int = 10
    var isENtoJP: Bool = true
    var useAnki: Bool = true
    var isDirectMode: Bool = false
    var ankiTicket: Int = 0
    var listeningTicket: Int = 0
    var effectVolume: Float = 1.0
    var voiceVolume: Float = 1.0
}

extension StudyInfo {
    // UserDefaultsにStudyInfoを保存するメソッド
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "studyInfo")
        }
    }
    
    // UserDefaultsからStudyInfoを読み込むメソッド
    static func load() -> StudyInfo {
        if let data = UserDefaults.standard.data(forKey: "studyInfo"),
           let studyInfo = try? JSONDecoder().decode(StudyInfo.self, from: data) {
            print("設定のロードに多分成功しました")
            return studyInfo
        }
        return StudyInfo()
    }
}

//My単語帳関連の構造体

struct MyWord: Codable, Identifiable {
    var id: UUID
    var english: String
    var japanese: String
}

class File: Identifiable, ObservableObject, Codable {
    let id = UUID()
    @Published var name: String
    @Published var myWord: [MyWord]?
    @Published var children: [File]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case myword
        case children
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.myWord = try container.decode([MyWord].self, forKey: .myword)
        self.children = try container.decodeIfPresent([File].self, forKey: .children)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(myWord, forKey: .myword)
        try container.encodeIfPresent(children, forKey: .children)
    }
    
    init(name: String, myWord: [MyWord]? = [], children: [File]? = []) {
        self.name = name
        self.myWord = myWord
        self.children = children
    }
}

