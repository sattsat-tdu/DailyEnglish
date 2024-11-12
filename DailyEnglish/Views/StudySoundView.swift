//
//  StudySoundView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI
import AlertKit

//リスニングに関する設定
struct ListeningInfo: Codable {
    var interval:Double = 1.0
    var voiceVolume: Float = 1.0
    var voiceSpeed: Float = 0.4
    var items:[String] = ["単語 (英語)", "単語 (日本語)","例文 (英語)", "例文 (日本語)"]
//    var speakerJP:SpeakerJP = .kyoko
//    var speakerUS: SpeakerUS = .flo
}

struct StudySoundView: View {
    
    @EnvironmentObject var speechRef: SpeechSynthesizer
    //すべてのデータを取得するが、仮グループは表示しない
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.groupname)],
        predicate: NSPredicate(format: "groupname != %@", "仮グループ")
    ) var groups: FetchedResults<Group>
    @State var group: Group?
    @State private var showingDialog = false
    @State private var isShowPlaySound = false
    @State private var listeningInfo = ListeningInfo()
    @State private var pronunciationItems:[String] = ["単語 (英語)", "単語 (日本語)","例文 (英語)", "例文 (日本語)"].enumerated().map { $0.element }
    @State private var inductionAdAlert = false
    let text = "発音順"
    //グラデーションカラー
    let gradationColor = LinearGradient(gradient: Gradient(colors: [.blue, Color("BackgroundColor")]), startPoint: .top, endPoint: .bottom)
    let widthsize =  UIScreen.main.bounds.width / 1.7

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack {
                        //縦書き
                        ForEach(text.map(String.init), id: \.self) { character in
                            Text(character)
                                .font(.headline)
                        }
                        .padding()
                        Image(systemName: "arrow.down")
                            .padding()
                    }
                    .padding(.leading)
                    
                    //Listの動的サイズに挑戦してみよう
                    List {
                        ForEach(pronunciationItems.indices, id: \.self) { index in
                            Text(pronunciationItems[index])
                                .font(.headline)
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: move)
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            Capsule()
                                .fill(Color.primary.opacity(0.1))
                                .padding(.vertical, 5)
                        )
                        .frame(height: UIScreen.main.bounds.height / CGFloat((4 * pronunciationItems.count)))
                    }
                    .scrollContentBackground(.hidden)
                }
                VStack(spacing : 15) {
                    HStack(spacing : 20) {
                        Text("間隔 : ")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            if listeningInfo.interval > 0 {
                                listeningInfo.interval -= 0.5
                            }
                        }, label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                        //小数点一桁表示
                        Text("\(String(format: "%.1f",listeningInfo.interval))秒")
                        Button(action: {
                            if listeningInfo.interval < 5 {
                                listeningInfo.interval += 0.5
                            }
                        }, label: {
                            Image(systemName: "chevron.right.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                    }
                    HStack {
                        Text("出題範囲 : ")
                            .font(.headline)
                        Spacer()
                        Picker("出題する範囲", selection: $group) {
                            Text("範囲を選択").tag(nil as Group?) // デフォルトの選択肢を追加
                            ForEach(groups, id: \.self) { group in
                                Text(group.groupname ?? "")
                                    .tag(group as Group?)
                            }
                        }
                    }
                    HStack {
                        Text("声の大きさ:")
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Slider(value: $listeningInfo.voiceVolume, in: 0...2)
                            .frame(width: widthsize)
                    }
                    
                    HStack {
                        Text("声の速さ:")
                            .font(.headline)
                        
                        Spacer()
                        
                        Slider(value: $listeningInfo.voiceSpeed, in:0...0.8)
                            .frame(width: widthsize)
                    }
                    //発音者の設定
//                    HStack {
//                        Text("英語発音:")
//                            .font(.headline)
//                        Picker("英語発音", selection: $listeningInfo.speakerUS) {
//                            ForEach(SpeakerUS.allCases, id: \.self) { speaker in
//                                Text(speaker.displayName).tag(speaker)
//                            }
//                        }
//                        .onChange(of: listeningInfo.speakerUS){ speaker in
//                            print(speaker.displayName)
//                        }
//                        Spacer()
//                        Text("日本語発音:")
//                            .font(.headline)
//                        Picker("日本語発音", selection: $listeningInfo.speakerJP) {
//                            ForEach(SpeakerJP.allCases, id: \.self) { speaker in
//                                Text(speaker.displayName).tag(speaker)
//                            }
//                        }
//                    }
                    Spacer()
                    Button(action: {
                        if group != nil {
                            //リスニング情報のセーブ
                            SaveListeningInfo()
                            
                            var ticket = StudyInfo.load()
                            if ticket.listeningTicket == 0 {
                                inductionAdAlert = true
                            } else if group?.word?.count != 0 {
                                //リスニング実行
                                ticket.listeningTicket -= 1
                                ticket.save()
                                isShowPlaySound = true
                            } else {
                                isShowPlaySound = true
                            }
                        } else {
                            AlertKitAPI.present(
                                title: "範囲が選択されていません",
                                icon: .error,
                                style: .iOS16AppleMusic,
                                haptic: .error
                            )
                        }
                    }, label: {
                        Label("再生開始", systemImage: "headphones")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50,alignment:.center)
                            .background(Color.yellow)
                            .clipShape(.rect(cornerRadius: 10))
                    })
                    .alert("チケットが足りません", isPresented: $inductionAdAlert) {
                        Button("キャンセル"){}
                        Button("広告を見て学習する"){
                            print("リワード広告の実装")
                        }
                    } message: {
                        Text("リスニング学習を行うにはチケットが必要です。\n\n広告を見ることで特別に学習することができます。")
                    }
                    .padding(.bottom)
                    .fullScreenCover(isPresented: $isShowPlaySound) {
                        PlaySoundView(
                            isShowPlaySound: $isShowPlaySound,
                            group: group!,
                            listeningInfo: listeningInfo)
                    }
                    Text("※リスニングチケットを1枚消費します。")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.top,-10)
                }
                .padding()
                .background(Color("BackgroundColor"))
            }
            .background(gradationColor)
            .navigationTitle("リスニング学習")
            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                //画面表示時にロード
                listeningInfo = loadListeningInfo()
                pronunciationItems = listeningInfo.items
                _ = Testt.load()
            }
//            .onDisappear {
//                let speakersave = Testt(speakerJP: .otoya, speakerUS: .cellos)
//                speakersave.save()
//            }
            .onDisappear(perform: SaveListeningInfo)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        EditButton()
                        Button(action: {
                            showingDialog = true
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .confirmationDialog("追加する発音を選択してください", isPresented: $showingDialog, titleVisibility: .visible) {
                            Button("単語（英語）") {
                                pronunciationItems.append("単語 (英語)")
                            }
                            Button("単語 (日本語)") {
                                pronunciationItems.append("単語 (日本語)")
                            }
                            Button("例文（英語）") {
                                pronunciationItems.append("例文 (英語)")
                            }
                            Button("例文（日本語）") {
                                pronunciationItems.append("例文 (日本語)")
                            }
                        }
                    }
                    .foregroundStyle(Color.primary)
                }
            }
        }
    }
    func delete(at offsets: IndexSet) {
        pronunciationItems.remove(atOffsets: offsets)
    }
    
//    func move(fromOffsets: IndexSet, toOffset: Int) {
////        listeningInfo.items.move(fromOffsets: fromOffsets, toOffset: toOffset)
//        self.testStrings.move(fromOffsets: fromOffsets, toOffset: toOffset)
//    }
    func move(from source: IndexSet, to destination: Int) {
        self.pronunciationItems.move(fromOffsets: source, toOffset: destination)
            print("source:\(source.first!)")
            print("destination:\(destination)")
        }
    
    //Save処理
    func SaveListeningInfo() {
        listeningInfo.items = pronunciationItems
        print(listeningInfo)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? jsonEncoder.encode(listeningInfo) else {
            print("リスニング情報のSaveができませんでした")
            return
        }
        UserDefaults.standard.set(data, forKey: "listeningkey")
    }
    
    //ロード処理
    func loadListeningInfo()->ListeningInfo {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = UserDefaults.standard.data(forKey: "listeningkey"),
              let dataModel = try? jsonDecoder.decode(ListeningInfo.self, from: data) else {
            print("リスニング情報のロードができませんでした")
            return ListeningInfo()
        }
        return dataModel
    }
}

#Preview {
    StudySoundView()
}
