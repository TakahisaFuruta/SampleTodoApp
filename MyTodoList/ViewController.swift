//
//  ViewController.swift
//  MyTodoList
//
//  Created by 古田貴久 on 2017/10/07.
//  Copyright © 2017年 TakahisaFuruta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var todoList = [MyTodo]()
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 保存したデータの取り出し
    let userDefaults = UserDefaults.standard
    if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data {
      if let unarchieveTodoList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyTodo] {
        todoList.append(contentsOf: unarchieveTodoList)
      }
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // 行数を返す
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.todoList.count
  }
  
  // セルをタップした際の挙動
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // 再利用可能なcellを取得する
    let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
    
    // 行番号にあったTODOのタイトルを取得
    let myTodo = todoList[indexPath.row]
    cell.textLabel?.text = myTodo.todoTitle
    
     //完了状態をみてチェックマークをだす
    if myTodo.todoDone {
      cell.accessoryType = UITableViewCellAccessoryType.checkmark
    } else {
      cell.accessoryType = UITableViewCellAccessoryType.none
    }
    
    return cell
  }
  
  // cellがタップされた時のイベント処理
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let myTodo = self.todoList[indexPath.row]
    if myTodo.todoDone {
      // 完了済み => 未完了
      myTodo.todoDone = false
    } else {
      myTodo.todoDone = true
    }
    
    // セルの状態変更を適用する
    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    // 変更データも保存
    let userDefault = UserDefaults.standard
    let storeData :Data = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
    userDefault.set(storeData, forKey: "todoList")
    userDefault.synchronize()
  }
  
  // セルが編集可能か
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  // セルの編集完了処理
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    // 削除処理か
    if editingStyle == UITableViewCellEditingStyle.delete {
      //TodoListから削除
      todoList.remove(at: indexPath.row)
      // セル自体を削除
      tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
      // データ保存
      let ud = UserDefaults.standard
      let data :Data = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
      ud.set(data, forKey: "todoList")
      ud.synchronize()
    }
  }
  
  
  @IBAction func tapAddBtn(_ sender: Any) {
    // アラート作成
    let artController = UIAlertController(
      title: "TODO追加",
      message: "TODOを入力してください",
      preferredStyle: UIAlertControllerStyle.alert
    )
    
    artController.addTextField(configurationHandler: nil)
    
    // okボタンが押された時の処理
    let okAction = UIAlertAction(
      title: "OK",
      style: UIAlertActionStyle.default
    ) { (action: UIAlertAction) in
      if let textField = artController.textFields?.first {
        
        let myTodo = MyTodo()
        myTodo.todoTitle = textField.text!
        
        self.todoList.insert(myTodo, at: 0)
        
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.right)
        
        // 永続化
        let userDefaults = UserDefaults.standard
        let saveData = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
        userDefaults.set(saveData, forKey: "todoList")
        userDefaults.synchronize()
        
      }
      
    }
    artController.addAction(okAction)
    
    //キャセルボタンが押された時の処理
    let cancelAction = UIAlertAction(
      title: "CANCEL",
      style: UIAlertActionStyle.cancel,
      handler: nil
    )
    artController.addAction(cancelAction)
    
    // アラート表示
    present(artController, animated: true, completion: nil)
  }
}

class MyTodo: NSObject, NSCoding {
  // TODOのタイトル
  var todoTitle: String?
  // 完了フラグ
  var todoDone: Bool = false
  
  override init() {}
  
  //デシリアライズ
  required init?(coder aDecoder: NSCoder) {
    todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
    todoDone = aDecoder.decodeBool(forKey: "todoDone")
  }
  
  // シリアライズ
  func encode(with aCoder: NSCoder) {
    aCoder.encode(todoTitle, forKey: "todoTitle")
    aCoder.encode(todoDone, forKey: "todoDone")
  }
  
}

