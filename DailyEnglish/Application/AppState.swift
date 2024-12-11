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
    
    init() {
        checkVersionUpdate()
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
