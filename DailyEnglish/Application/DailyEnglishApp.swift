//
//  DailyEnglishApp.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/11.
//

import SwiftUI
import AVFAudio
import GoogleMobileAds

//広告実装のため、Mobile Ads SDK を初期化する
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}

@main
struct DailyEnglishApp: App {
    
    @AppStorage("isUsedAnki") var isUsedAnki = false
    
    init() {
        //バックグラウンド再生を可能に
        setupAudioSession()
        
        //アプリを開き、初回プレイ時に暗記シートを消費させる処理に必要
        isUsedAnki = false
        
        //ログイン処理だが、すぐにすると動かないので、遅延
        DispatchQueue.main.asyncAfter(deadline : .now() + 3) { [self] in
            // ログインボーナスチェック
            judgeDate()
        }
    }
    
    //バックグラウンド再生をできるようにする
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    //日付判定関数、ログインボーナスの実装
    func judgeDate(){
        
        // userdefaultsを用意しておく
        let UD = UserDefaults.standard
        //現在のカレンダ情報を設定
        let calender = Calendar.current
        //日本時間を設定
        let now_day = Date(timeIntervalSinceNow: 60 * 60 * 9)
        
        // 日時経過チェック
        if UD.object(forKey: "today") != nil{
            let past_day = UD.object(forKey: "today") as! Date
            let now = calender.component(.day, from: now_day)
            let past = calender.component(.day, from: past_day)
            
            //日にちが変わっていた場合
            if now != past {
                var ticketInfo = StudyInfo.load()
                ticketInfo.ankiTicket += 1
                ticketInfo.listeningTicket += 1
                ticketInfo.save()
                /* 今の日時を保存 */
                UD.set(now_day, forKey: "today")
                showCustomDialog(title: "ログインボーナス",
                                 subtitle: "暗記シートを1枚獲得しました！！\nリスニングチケットを1枚獲得しました！！",
                                 onClicked: {})
            }
        }
        //初回実行のみelse
        else {
            var studyInfo = StudyInfo.load()
            studyInfo.ankiTicket += 20
            studyInfo.listeningTicket += 20
            studyInfo.save()
            /* 今の日時を保存 */
            UD.set(now_day, forKey: "today")
            showCustomDialog(title: "ダウンロード\nありがとうございます！！",
                             subtitle: "感謝の気持ちを込めて、\n\n「暗記チケット」×20\n「リスニングチケット」× 20\n\nをプレゼントします！！\n学習に役立ててくださいね♪",
                             onClicked: {print("こんにちはははははあ")})
        }
    }
    //CoreData参照のため
//    @StateObject private var dataController = DataController()
    @StateObject private var dataController = DataController.shared
    //音声、効果音再生のため
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    //広告使用のため
    @StateObject private var admobRef = AdmobController()
    
    //広告実装のため
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
                .environmentObject(speechSynthesizer)
                .environmentObject(admobRef)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .alert("new Version!", isPresented: $appState.versionAlertFlg) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("これがアラートのメッセージです。")
                }
        }
    }
}
