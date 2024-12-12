//
//  AppState.swift
//  DailyEnglish
//
//  Created by SATTSAT on 2024/12/11
//
//

import SwiftUI

class AppState: ObservableObject {
    @Published var versionAlertFlg = false
    private let UD = UDManager.shared
    
    init() {
//        checkUserState()
//        checkVersionUpdate()
    }
    
    //ユーザーが初回起動なのかを確認
    private func checkUserState() {
        //バージョン更新前へ、引き継ぎを行う
        if UD.existsStringKey("isFirstLaunch") {
            UD.set(true, forKey: AppStateKeys.didCompleteFirstLaunch)
        }
        
        guard let didCompleteFirstLaunch = UD.get(forKey: AppStateKeys.didCompleteFirstLaunch) as Bool? else {
            return
        }
        
        if didCompleteFirstLaunch {
            print("起動済みです")
        } else {
            print("初めての起動です")
        }
    }

    //バージョンの差異を確認、バージョンが異なれば更新Viewの表示
    func checkVersionUpdate() {
        print("checkVersionUpdate()が呼ばれました")
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return
        }
        print("現在のバージョン: \(currentVersion)")
        let savedVersion = UserDefaults.standard.string(forKey: AppStateKeys.lastVersion.rawValue) ?? "nil"
        print("セーブしたバージョン\(savedVersion)")

        if currentVersion != savedVersion {
            DispatchQueue.main.async {
                self.versionAlertFlg = true
            }
            UserDefaults.standard.set(currentVersion, forKey: AppStateKeys.lastVersion.rawValue)
        } else {
            print("すでに更新されています。")
        }
    }
}
