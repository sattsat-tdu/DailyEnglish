//
//  DataController.swift
//  DailyEnglish
//
//  Created by 石井大翔 on 2023/10/11.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "DataModel")
    var saveContext: NSManagedObjectContext
    
    //CoreDataの定義
    init(){
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Failed to load the data \(error.localizedDescription)")
            }
        }
        saveContext = container.viewContext
    }
    
    //CoreDataへ、初期データの代入
    func saveInitData(finishImportWords: @escaping () -> Void) {
        //三つの並行処理を行うための準備
        let loadgroup = DispatchGroup()
        //単語データの追加
        for group in mainGroups {
            let newGroup = Group(context: saveContext)
            newGroup.groupname = group
            loadgroup.enter()
            loadInitWordCSV(setgroup: newGroup, fileName: group, completion: { loadgroup.leave() })
        }
        // すべてのロードが完了したら次の処理を実行
        loadgroup.notify(queue: .main) {
            //優先度の高くなく、処理の軽いグループの作成(DisPatch)
            for subGroup in subGroups {
                let newGroup = Group(context: self.saveContext)
                newGroup.groupname = subGroup
            }
            self.save()
            print("すべてのCSVデータのロードが完了しました")
            finishImportWords()
        }
    }
    
    //お気に入り単語のみを取得
    func getFavoriteWords() -> Set<Word>{
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isfavorite == %@", NSNumber(value: true))
        do {
            let favoriteWord = try saveContext.fetch(fetchRequest)
            return Set(favoriteWord)
        } catch {
            print("お気に入り単語が見つかりませんでした。")
        }
        return Set()
    }
    
    //引数groupnameから、Groupを取得
    func getGroupWords(groupname: String) -> Set<Word> {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupname == %@", groupname)
        
        do {
            let targetGroup = try saveContext.fetch(fetchRequest)
            if let group = targetGroup.first, let groupWords = group.word {
                // Groupに関連付けられたWordのセットを返す
                return groupWords as? Set<Word> ?? []
            } else {
                // グループが見つからない場合や、関連付けられた単語がない場合は空のセットを返す
                print("単語が見つかりませんでした。")
                return []
            }
        } catch {
            print("エラー：\(error)")
            return []
        }
    }
    
    
    //デバッグよう忘却曲線
    func getTestWords(daysago: Int) -> Set<Word>{
        let calendar = Calendar.current
        let daysAgo = Calendar.current.date(byAdding: .day, value: (daysago * -1), to: Date())!
        let daysAgoStartOfDay = calendar.startOfDay(for: daysAgo)
        let daysAgoEndOfDay = calendar.date(byAdding: .day, value: 1, to: daysAgoStartOfDay)!
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(correctedDate >= %@) AND (correctedDate < %@)", daysAgoStartOfDay as NSDate, daysAgoEndOfDay as NSDate)
        print("\(daysAgoStartOfDay)から\(daysAgoEndOfDay)の間")
        do {
            let TestWord = try saveContext.fetch(fetchRequest)
            return Set(TestWord)
        } catch {
            print("お気に入り単語が見つかりませんでした。")
        }
        return Set()
    }
    
//    func convertCSVtoWord(csvName: String) -> Set<Word>{
//        var words: Set<Word> = []
//        let csvBundle = Bundle.main.path(forResource: csvName, ofType: "csv")
//        do {
//            let csvData = try String(contentsOfFile: csvBundle!, encoding: .utf8)
//            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
//            var dataArray = lineChange.components(separatedBy: "\n")
//            dataArray.removeLast()
//            
//            for word in dataArray {
//                let items = word.components(separatedBy: ",")
//                words.insert(getWord(english: items[0])!)
//            }
//            return words
//            
//        } catch {
//            print("convertCSVtoWord関数で、CSVデータの取得に失敗しました")
//        }
//        return []
//    }
    func convertCSVtoWord(csvName: String) -> Set<Word> {
        var words: Set<Word> = []
        guard let csvBundle = Bundle.main.path(forResource: csvName, ofType: "csv") else {
            print("CSVファイルが見つかりません")
            return []
        }
        
        do {
            let csvData = try String(contentsOfFile: csvBundle, encoding: .utf8)
            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
            var dataArray = lineChange.components(separatedBy: "\n")
            dataArray.removeLast()
            
            for word in dataArray {
                let items = word.components(separatedBy: ",")
                if let wordObject = getWord(english: items[0]) {
                    // データの完全ロードを保証
                    let fullyLoadedWord = saveContext.object(with: wordObject.objectID) as! Word
                    _ = fullyLoadedWord.english  // 強制的にプロパティにアクセスして完全ロード
                    words.insert(fullyLoadedWord)
                } else {
                    print("\(items[0])の取得に失敗しました")
                }
            }
            return words
            
        } catch {
            print("convertCSVtoWord関数で、CSVデータの取得に失敗しました: \(error.localizedDescription)")
        }
        return []
    }

    
    func getWord(english: String) -> Word? {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "english == %@", english)
        do {
            let word = try saveContext.fetch(fetchRequest)
            if let targetWord = word.first {
                return targetWord
            }
        } catch {
            print("単語が見つかりませんでした")
        }
        return nil
    }
    
    
    //MyWord専用関数、品詞が空の単語のみ出題
    func getMyWord(wordData: MyWord) -> Word? {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        let enPredicate = NSPredicate(format: "english == %@", wordData.english)
        let posPredicate = NSPredicate(format: "pos == nil")
        // AND条件を使用して二つの条件を結合
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [enPredicate, posPredicate])
        fetchRequest.predicate = compoundPredicate
        
        do {
            let word = try saveContext.fetch(fetchRequest)
            if let targetWord = word.first {
                return targetWord
            } else {
                //なかったら新規作成
                let newWord = Word(context: saveContext)
                newWord.id = UUID()
                newWord.english = wordData.english
                newWord.japanese = wordData.japanese
                return newWord
            }
        } catch {
            print("単語が見つかりませんでした")
        }
        return nil
    }
    
    func createWord(en: String, jp: String){
        let newWord = Word(context: saveContext)
        newWord.id = UUID()
        newWord.english = en
        newWord.japanese = jp
    }
    
    //My単語帳限定→品詞が””の場合にしか削除しません。
    func deleteWord(en: String) {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        let enPredicate = NSPredicate(format: "english == %@", en)
        let posPredicate = NSPredicate(format: "pos == nil")
        // AND条件を使用して二つの条件を結合
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [enPredicate, posPredicate])
        fetchRequest.predicate = compoundPredicate
        do {
            let word = try saveContext.fetch(fetchRequest)
            if let targetWord = word.first {
                saveContext.delete(targetWord)
            }
        } catch {
            print("単語が見つかりませんでした(関数deleteWord)")
        }
    }
    
    //引数groupnameから、Groupを取得
    func getGroup(groupname:String) -> Group?{
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupname == %@", groupname)
        do {
            let groups = try saveContext.fetch(fetchRequest)
            if let targetGroup = groups.first {
                return targetGroup
            }
        } catch {
            print("グループが見つかりませんでした。")
        }
        return nil
    }
    
    //CoreDataのセーブ
    func save() {
        do {
            try saveContext.save()
            print("セーブに成功しました。")
        } catch {
            print("セーブに失敗しました。")
        }
    }
    
//    //デバッグ関数 日付の差を取得する。
//    func checkWordDate(word: Word){
//        
//        let calendar = Calendar.current
//        if let correctedDate = word.correctedDate{
//            // Date()からcorrectedDateを引くことで、初めて習得単語になった時の日数の差を取得
//            let components = calendar.dateComponents([.day], from: correctedDate, to: Date())
//            // 日数の差を取得
//            if let days = components.day {
//                print("日数の差:", days) // 出力: 1
//            } else {
//                print("日数の差は取得できませんでした")
//            }
//        } else {
//            print("まだ日付の登録がされていないようです。")
//        }
//    }
//    
    //引数と同じグループ名に保存、もしくは移動
    func moveWordToGroup(targetGroup: String, word: Word?) {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupname == %@", targetGroup)
        do {
            
            //初めて取り組んだ単語でないかつ、遷移先が習得単語の場合のみ実行。忘却曲線の準備
            if let groupname = word?.group?.groupname,
               !groupname.contains("Part"),
               targetGroup == "習得単語" {
                print("忘却曲線の準備をします。")
                word?.correctedDate = Date()
            }
            
            
            //遷移先グループが前所属と同じならば何もしない。
            let groups = try saveContext.fetch(fetchRequest)
            if let targetGroup = groups.first,
               word?.group != targetGroup{
                word?.group = targetGroup
                save()
            }
        } catch {
            print("エラー")
        }
    }
    
    //CSVからロードし、引数GroupにWordデータを代入。
    func loadInitWordCSV(setgroup: Group, fileName: String, completion: @escaping () -> Void) {
        
        let csvBundle = Bundle.main.path(forResource: fileName, ofType: "csv")
        
        do {
            let csvData = try String(contentsOfFile: csvBundle!, encoding: .utf8)
            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
            var dataArray = lineChange.components(separatedBy: "\n")
            dataArray.removeLast()
            
            //ファイルに入っている総数を取得するための変数
            var count = 0
            
            for (index, word) in dataArray.enumerated() {
                let items = word.components(separatedBy: ",")
                
                if items.count >= 5 {
                    //引数で得たGroupに、ワードデータを入れる。
                    let word = Word(context: saveContext)
                    word.id = UUID()
                    word.group = setgroup
                    word.english = items[0]
                    word.japanese = items[1]
                    word.pos = items[2]
                    word.ensentence = items[3]
                    word.jpsentence = items[4]
                    
                    count += 1
                } else {
                    print("Error: Insufficient columns at line \(index + 1)")
                }
            }
            setgroup.total = Int16(count)
            print("csv代入完了")
            //ロード完了通知
            completion()
            
        } catch {
            print("csv load エラー")
        }
    }
    
}
