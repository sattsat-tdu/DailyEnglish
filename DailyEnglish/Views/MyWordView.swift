//
//  MyWordView.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/13.
//

import SwiftUI

struct MyWordView: View {
    
    @StateObject var myWordRef = MyWordViewModel()
    @State private var folder: File = File(name: "My単語帳",myWord: [], children: [])
    
    var body: some View {
        NavigationStack {
            FileView(folder: folder)
                .environmentObject(myWordRef)
                .onAppear {
                    folder = myWordRef.sourceFile!
                }
        }
    }
}
struct FileView: View {
    
    @EnvironmentObject var dataManager: CoreDataManager
    @EnvironmentObject var myWordRef: MyWordViewModel
    @State private var isShowAlert = false
    @State private var fileText = ""
    @ObservedObject var folder: File
    @State private var isShowCreateWord = false
    @State private var isShowPlay = false
    //バージョン1では必ずリスト表示
    @State private var isListStyle = true
    @State private var isEditName = false
    
    var columns: [GridItem] {
        return Array(repeating: .init(.flexible(), spacing: 0), count: 1)
    }
    //「学習する」ボタン使用時の引数
    var playWords: Set<Word> {
        var wordSet = Set<Word>() // 空のセットを初期化
        if let myWordArray = folder.myWord {
            for wordInfo in myWordArray {
                if let word: Word = dataManager.getMyWord(wordData: wordInfo) {
                    wordSet.insert(word) // セットに要素を追加
                }
            }
        }
        return wordSet // セットを返す
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("サブフォルダー")
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
            if isListStyle {
                ScrollView {
                    ForEach(folder.children ?? []) { child in
                        NavigationLink(destination:
                                        FileView(folder:child).id(UUID()).environmentObject(myWordRef)
                                       
                        ) {
                            HStack(spacing: 30) {
                                Image(systemName: "folder.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.yellow)
                                Text(child.name)
                                    .foregroundStyle(Color.primary)
                                    .lineLimit(1)
                                Spacer()
                                Button(action: {
                                    removeFile(child)
                                }, label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.secondary)
                                })
//                                .sheet(isPresented: $isShowEditView) {
//                                    editFolderPage(
//                                        folderName: folderName,
//                                        isShowEditView: $isShowEditView,
//                                        onRemoved: {
//                                            removeFile(child)
//                                        })
//                                        .presentationDetents([.medium])
//                                }
                                
                            }
                            .padding(.horizontal)
                        }
                        //3Dタッチ
                        .contextMenu {
                            Button(action: {
                                removeFile(child)
                            }) {
                                Label("削除する", systemImage: "trash")
                            }
                        }
                    }
                }
                VStack {
                    HStack {
                        Text("「\(folder.name)」 の単語")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        EditButton()
                    }
                    List {
                        HStack {
                            Text("英語")
                            Spacer()
                            Text("日本語")
                        }
                        .bold()
                        .listRowBackground(Color.black.opacity(0.1))
                        ForEach(folder.myWord ?? []){ myword in
                            HStack {
                                Text(myword.english)
                                Spacer()
                                Text(myword.japanese)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .clipShape(.rect(cornerRadius: 10))
                    HStack {
                        Button(action: {
                            isShowCreateWord = true
                        }, label: {
                            Label("単語を追加", systemImage: "note.text.badge.plus")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 50,alignment:.center)
                                .background(Color.yellow)
                                .clipShape(.rect(cornerRadius: 10))
                        })
                        .sheet(isPresented: $isShowCreateWord) {
                            CreateWordView(
                                onCreated: {myWord in
                                    //単語を作成したときに呼ばれる
                                    folder.myWord?.append(myWord)
                                    myWordRef.saveFileToDocument()
                                    //CoreData Wordを作成
                                    dataManager.createWord(en: myWord.english, jp: myWord.japanese)
                                })
                        }
                        
                        Button(action: {
                            isShowPlay = true
                        }, label: {
                            Label("学習する", systemImage: "play")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 50,alignment:.center)
                                .background(folder.myWord!.isEmpty ? Color.secondary.opacity(0.5) : Color.yellow)
                                .clipShape(.rect(cornerRadius: 10))
                        })
                        //My単語がなかったら学習するボタンを押せなくする
//                        .disabled(folder.myWord!.isEmpty)
                        .disabled(playWords.isEmpty)
                        .fullScreenCover(isPresented: $isShowPlay) {
                            PlayViewEX(words: playWords)
                        }
                    }
                }
                .padding()
                .background(.black.opacity(0.1))
                .clipShape(.rect(cornerRadius: 30))
                .edgesIgnoringSafeArea(.bottom)
                
            } else {
                ScrollView {
                    LazyVGrid(columns: columns,spacing: 0) {
                        ForEach(folder.children ?? []) { child in
                            NavigationLink(destination:
                                            FileView(folder: child).environmentObject(myWordRef)
                            ) {
                                VStack {
                                    Image(systemName: "folder.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundStyle(.yellow)
                                    
                                    Text(child.name)
                                        .foregroundStyle(Color.primary)
                                }
                                
                            }
                            .contextMenu {
                                Button(action: {
                                    removeFile(child)
                                }) {
                                    Label("削除する", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
        }

        .background(.mainBackground)
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            //ファイル名を変更
            Button(action: {
                fileText = folder.name
                isEditName = true
            }, label: {
                Image(systemName: "square.and.pencil")
            })
            //ファイルを作成
            Button(action: {
                fileText = ""
                isShowAlert = true
            }, label: {
                Image(systemName: "folder.badge.plus")
            })

        }
        .alert("ファイル名の変更", isPresented: $isEditName) {
            TextField("ファイル名を入力", text: $fileText)
            Button("キャンセル"){}
            Button("完了"){
                folder.name = fileText
                myWordRef.saveFileToDocument()
            }
        }
        .alert("ファイルの作成", isPresented: $isShowAlert) {
            TextField("ファイル名を入力", text: $fileText)
            Button("キャンセル"){}
            Button("作成"){
                addNewFolder(fileName: fileText)
            }
        }
    }
    //リスト、削除するための関数,CoreDataからも消去
    func delete(at offsets: IndexSet) {
        let deleteEN = folder.myWord?[offsets.first!]
        dataManager.deleteWord(en: deleteEN?.english ?? "")
        folder.myWord?.remove(atOffsets: offsets)
        myWordRef.saveFileToDocument()
    }
    
    func addNewFolder(fileName: String) {
        let newFolder = File(name: fileName, children: [])
        folder.children?.append(newFolder)
        //Save
        myWordRef.saveFileToDocument()
    }
    
    func removeFile(_ fileToRemove: File) {
        guard var children = folder.children else {
            return
        }
        
        children.removeAll { $0.id == fileToRemove.id }
        folder.children = children
        //Save
        myWordRef.saveFileToDocument()
    }
}

#Preview {
    MyWordView()
}
