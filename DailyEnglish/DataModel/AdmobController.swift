//
//  AdmobController.swift
//  Template
//
//  Created by 石井大翔 on 2023/11/25.
//
/*
テスト広告(iOS)
 バナー広告：ca-app-pub-3940256099942544/2934735716
 インタースティシャル広告：ca-app-pub-3940256099942544/4411468910
 リワード広告：ca-app-pub-3940256099942544/1712485313

 その他：https://developers.google.com/admob/ios/test-ads?hl=ja
 */

/*
「日常英単語」本番広告(iOS)
 バナー広告：ca-app-pub-7618656440774198/2268426336
 インタースティシャル広告：ca-app-pub-7618656440774198/2584193245
 リワード広告：ca-app-pub-7618656440774198/3705703221
 */

import GoogleMobileAds
import SwiftUI


//バナー処理、Viewにて直接よぶ
struct AdBannerView: UIViewRepresentable {
    let bannerID: String = "ca-app-pub-7618656440774198/2268426336"

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50))) // Set your desired banner ad size
        bannerView.adUnitID = bannerID
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        bannerView.rootViewController = window?.rootViewController
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}


class AdmobController: NSObject,GADFullScreenContentDelegate,  ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    @Published var rewardLoaded: Bool = false

    var interstitialAd: GADInterstitialAd?
    var rewardedAd: GADRewardedAd?
    
    let interstitialID = "ca-app-pub-7618656440774198/2584193245"
    let rewardID = "ca-app-pub-7618656440774198/3705703221"
    
    override init() {
        super.init()
        loadInterstitial()
        loadReward()
    
    }
//インタースティシャル広告の実装--------------------------------------------------
    
    //クロージャ
    private var onInterstitialClosed: (() -> Void)?

    // インタースティシャル広告の読み込み
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: interstitialID, request: GADRequest()) { (ad, error) in
            if let _ = error {
                print("😭: インタースティシャル広告の読み込みに失敗しました")
                self.interstitialAdLoaded = false
                return
            }
            print("😍: インタースティシャル広告の読み込みに成功しました")
            self.interstitialAdLoaded = true
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    // インタースティシャル広告の表示
    func showInterstitial(onClosed: @escaping () -> Void) {
        //60%の確率で広告を見せず、クローズ
        if randomBoolWithPercent(percentage: 60) {
            onClosed()
            return
        }
        let root = getTopViewController()
        if let ad = interstitialAd {
            ad.present(fromRootViewController: root!)
            self.interstitialAdLoaded = false
        } else {
            print("😭: インタースティシャル広告の準備ができていませんでした")
            self.interstitialAdLoaded = false
            self.loadInterstitial()
        }

        // クロージャをセット
        onInterstitialClosed = onClosed
    }

    // 失敗通知、失敗したら何もせずクロージャに渡す
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        self.loadInterstitial()
        onInterstitialClosed?()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("広告を表示しました")
    }

    // クローズ通知
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("広告を閉じました")
        
        //次すぐに広告を準備するため閉じた後すぐにLoadさせる
        if !interstitialAdLoaded {
            loadInterstitial()
        }
        if !rewardLoaded {
            loadReward()
        }
        
        // クロージャを実行
        onInterstitialClosed?()
    }
    
//インタースティシャル広告の実装End--------------------------------------------------

    // リワード広告の読み込み
    func loadReward() {
        GADRewardedAd.load(withAdUnitID: rewardID, request: GADRequest()) { (ad, error) in
            if let _ = error {
                print("😭: リワード広告の読み込みに失敗しました")
                self.rewardLoaded = false
                return
            }
            print("😍: リワード広告の読み込みに成功しました")
            self.rewardLoaded = true
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    // リワード広告の表示
    func showReward(onRewarded: @escaping () -> Void) {
        let root = getTopViewController()
        if let ad = rewardedAd {
            self.rewardLoaded = false
            ad.present(fromRootViewController: root!, userDidEarnRewardHandler: {
                print("😍: 報酬を獲得しました")
                // 報酬を受け取る処理を実行
                onRewarded()
            })
        } else {
            print("😭: リワード広告の準備ができていませんでした")
            self.rewardLoaded = false
            self.loadReward()
        }
    }
    //現在表示しているViewを取得する関数 
    func getTopViewController() -> UIViewController? {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = scene.windows.first {
                var topViewController = window.rootViewController
                
                while let presentedViewController = topViewController?.presentedViewController {
                    topViewController = presentedViewController
                }
                
                return topViewController
            }
        }
        
        return nil
    }
    
    //引数％による確率関数
    func randomBoolWithPercent(percentage: Int) -> Bool {
        guard percentage >= 0 && percentage <= 100 else {
            fatalError("Percentage should be in the range of 0 to 100.")
        }

        let randomValue = Int.random(in: 0...100)
        return randomValue <= percentage
    }
}
