//
//  MyWordViewModel.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/11/08.
//

import Foundation

class MyWordViewModel: ObservableObject {
    
    @Published var sourceFile: File?
    
    init() {
        sourceFile = loadFileFromDocument()
    }
    
    //Save処理、Documentに直接作成することにより、大容量データを保存可能。
    func saveFileToDocument() {
        //構造体からData型への変換処理
        let file = StructToData()
        let fileURL = getDocumentsDirectory().appendingPathComponent("myWord.json")
        do {
            try file!.write(to: fileURL, options: .atomic)
            print("myWord.jsonが保存されました")
        } catch {
            print("データの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    //ロード処理、Documentから取得
    func loadFileFromDocument()->File {
        let fileURL = getDocumentsDirectory().appendingPathComponent("myWord.json")
        do {
            let data = try Data(contentsOf: fileURL)
            return DataToStruct(data: data)
        } catch {
            print("データがありませんでした。")
            //データがない場合は新規作成
            return File(name: "My単語帳",myWord: [], children: [])
        }
    }
    
    //Data型から、構造体に変換する関数
    func DataToStruct(data:Data) -> File{
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let mywordFile = try jsonDecoder.decode(File.self, from: data)
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("デコードされるJSON文字列: \(jsonString)")
//            }
            return mywordFile
        } catch {
            print("デコードすることができませんでした: \(error.localizedDescription)")
            return File(name: "My単語帳",myWord: [], children: [])
        }
    }
    
    //構造体から、Data型に変換する関数
    func StructToData()-> Data? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let data = try jsonEncoder.encode(sourceFile)
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                        print("エンコードされたJSON文字列: \(jsonString)")
            //                    }
            return data
        } catch {
            print("構造体からData型への変換に失敗しました")
            return nil
        }
    }
    
    //パスを取得、Documentに入れるために必要
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
