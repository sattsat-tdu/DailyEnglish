//
//  ColorModel.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2024/05/01.
//
import SwiftUI
import Foundation


//FavoriteListViewで使用
let yellowWhiteGradient = LinearGradient(gradient: Gradient(colors: [.yellow, Color("ItemColor")]), startPoint: .bottomLeading, endPoint: .topTrailing)

//お気に入り単語で使用
let favoriteStyle = LinearGradient(
    gradient: Gradient(stops: [
        .init(color: .yellow, location: 0.0),
        .init(color: Color("ItemColor"), location: 0.9),
        .init(color: .yellow.opacity(0.5), location: 1.0)]),
    startPoint: .leading,
    endPoint: .trailing)

////オレンジと黄色のグラデーション、NGSL単語グラフで使用
let orangeYellowGradient = LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topTrailing, endPoint: .bottomLeading)

//三色 青、青（薄い）、白
let whiteBlueGradient = LinearGradient(
    gradient: Gradient(stops: [
        .init(color: Color("ItemColor"), location: 0.0),
        .init(color: .cyan.opacity(0.3), location: 0.6),
        .init(color: .cyan, location: 1.0)]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing)

//縦の青色ベースのグラデーション、.finish時に利用
let blueBaseGradient = LinearGradient(gradient: Gradient(colors: [.blue, Color("BackgroundColor")]), startPoint: .top, endPoint: .center)

let yellowBaseGradient = LinearGradient(gradient: Gradient(colors: [.yellow, Color("BackgroundColor")]), startPoint: .top, endPoint: .bottom)

//ホーム画面の復習ボタンに使用
let circleGradient = RadialGradient(gradient: Gradient(colors: [Color("ItemColor"), .cyan]), center: .center, startRadius: 1, endRadius: 110)


#Preview {
    HomeView()
}
