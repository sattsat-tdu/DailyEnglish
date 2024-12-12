//
//  UDManager.swift
//  DailyEnglish
//  
//  Created by SATTSAT on 2024/12/12
//  
//

import Foundation

final class UDManager {
    static let shared = UDManager()
    private let UD = UserDefaults.standard
    
    private init() {}
    
    // MARK: - 値の取得と設定
    func set<T>(_ value: T, forKey key: UserDefaultsKey) {
        UD.set(value, forKey: key.rawValue)
    }
    
    func get<T>(forKey key: UserDefaultsKey) -> T? {
        return UD.object(forKey: key.rawValue) as? T
    }
    
    func remove(forKey key: UserDefaultsKey) {
        UD.removeObject(forKey: key.rawValue)
    }
    
    func exists(forKey key: UserDefaultsKey) -> Bool {
        return UD.object(forKey: key.rawValue) != nil
    }
    
    func existsStringKey(_ key: String) -> Bool {
        return UD.object(forKey: key) != nil
    }
//    // MARK: - 初期設定
//    func setupDefaultValues() {
//        let defaultValues: [Keys: Any] = [
//            .hasLaunchedBefore: false,
//            .didCompleteTutorial: false,
//            .userLanguagePreference: "en",
//            .notificationsEnabled: true
//        ]
//        
//        for (key, value) in defaultValues {
//            if !exists(forKey: key) { // 存在しない場合のみ設定
//                set(value, forKey: key)
//            }
//        }
//    }
}
