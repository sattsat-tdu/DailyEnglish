//
//  StudySettingView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

struct StudySettingView: View {
    
    @EnvironmentObject var speechRef: SpeechSynthesizer
    @State private var studyInfo : StudyInfo = StudyInfo.load()
    let pickerData = [10,15,20,25,30,40,50]
    @State private var toggle = false
    
    @State private var isUStoJA: Bool
    
    init() {
        _isUStoJA = State(initialValue: UserDefaults.standard.bool(forKey: SettingKeys.questionFormat.rawValue))
    }
    
    var body: some View {
        Form {
            studySettingSection
            
            soundSettingSection
        }
        //表示されたタイミングでSaveDataのロード
        .onAppear {
            studyInfo = StudyInfo.load()
        }
        //このViewから離れるときにSave
        .onDisappear {
            studyInfo.save()
            //音声ViewModelに値をSet
            speechRef.volume = studyInfo.voiceVolume
            speechRef.effectVolume = studyInfo.effectVolume
        }
        .navigationTitle("学習設定")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var studySettingSection: some View {
        Section("詳細設定") {
            VStack {
                HStack {
                    Label("学習モード", systemImage: "platter.filled.bottom.iphone")
                    Spacer()
                    
                }
                HStack {
                    Button(action: {
                        studyInfo.isDirectMode = false
                    }, label: {
                        VStack {
                            Image("SampleImage_Select")
                                .resizable()
                                .scaledToFit()
                            Text("4択回答形式")
                        }
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    .opacity(studyInfo.isDirectMode ? 0.3 : 1)
                    
                    Spacer()
                    
                    Button(action: {
                        studyInfo.isDirectMode = true
                    }, label: {
                        VStack {
                            Image("SampleImage_Direct")
                                .resizable()
                                .scaledToFit()
                            Text("直接回答形式")
                        }
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    .opacity(studyInfo.isDirectMode ? 1 : 0.3)
                }
                .foregroundStyle(Color.primary)
                .padding()
            }
            
            VStack {
                Toggle(isOn: $isUStoJA) {
                    Label("出題：英語, 回答：日本語", systemImage: "textformat.el")
                }
                .onChange(of: isUStoJA) { newValue in
                    UserDefaults.standard.set(newValue, forKey: SettingKeys.questionFormat.rawValue)
                }
                Text("OFFにすると、出題：日本語, 回答：英語になります")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing : 20) {
                Label("制限時間", systemImage: "timer")
                Spacer()
                
                Button(action: {
                    if studyInfo.timeLimit > 1 {
                        studyInfo.timeLimit -= 1
                    }
                }, label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                })
                //Form内でボタンを押すために必要
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(studyInfo.timeLimit)秒")
                
                Button(action: {
                    if studyInfo.timeLimit < 10 {
                        studyInfo.timeLimit += 1
                    }
                }, label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                })
                .buttonStyle(BorderlessButtonStyle())
            }
            .frame(minHeight: 40)
            
            //ドロップダウンリストの作成
            Picker(selection: $studyInfo.wordNum) {
                ForEach(pickerData, id:\.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            } label: {
                Label("学習する単語数", systemImage: "list.number")
            }
            .frame(minHeight: 40)
            
            VStack {
                Toggle(isOn: $studyInfo.useAnki) {
                    Label("暗記チケットを利用する", systemImage: "brain.filled.head.profile")
                }
                Text("現在の暗記チケット数 : \(studyInfo.ankiTicket)")
                    .foregroundStyle(Color.secondary)
                chatKunView(chatText: "暗記シートは、アプリを起動して初めて暗記シートを使う際にチケットが1枚消費されるよ！「1プレイ」毎に減っていかないから安心して！")
            }
            .frame(minHeight: 50)
        }
    }
    
    private var soundSettingSection: some View {
        Section("音響設定") {
            VStack(alignment : .leading) {
                Text("声の大きさ")
                    .foregroundStyle(Color.secondary)
                HStack {
                    Image(systemName: "speaker.slash")
                    Slider(value: $studyInfo.voiceVolume, in: 0...2)
                    Image(systemName: "speaker.wave.3")
                }
            }
            VStack(alignment : .leading) {
                Text("効果音")
                    .foregroundStyle(Color.secondary)
                HStack {
                    Image(systemName: "speaker.slash")
                    Slider(value: $studyInfo.effectVolume, in: 0...2)
                    Image(systemName: "speaker.wave.3")
                }
            }
        }
    }
}

#Preview {
    StudySettingView()
}
