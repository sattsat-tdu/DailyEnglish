//
//  UserDefaultsKeys.swift
//  DailyEnglish
//  
//  Created by SATTSAT on 2024/12/10
//  
//

// MARK: - 共通プロトコル
protocol UserDefaultsKey {
    var rawValue: String { get }
}

// MARK: - Keysの定義
enum SettingKeys: String, UserDefaultsKey {
    case questionFormat // 出題形式 英→日（true）, 日→英(false)
}

enum AppStateKeys: String, UserDefaultsKey {
    case lastVersion // バージョンを保存。更新時の表示フラグ
    case didCompleteFirstLaunch // 初回起動なのかを取得。すでに起動済みならTrue
}
