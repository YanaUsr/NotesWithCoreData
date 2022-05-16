//
//  ViewController.swift
//  NotesWithCoreData
//
//  Created by Яна Иноземцева on 15.05.2022.
//

import UIKit


class TaskListViewController: UITableViewController {
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    private var noteList: [Note] = []
    private let noteID = "note"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: noteID)
        view.backgroundColor = .white
        setUpNavigationBar()
        fetchData()
    }
    
    private func setUpNavigationBar() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 149/255,
                                                   green: 53/255,
                                                   blue: 83/255,
                                                   alpha: 194/255)
        
    
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector (addNewTask)
                                                            )
        navigationController?.navigationBar.tintColor = .white
        
    }
    
   @objc private func addNewTask() {
      showAlert("NewNote", "What do you want to do?")
    }
    
    private func fetchData(){
        let fetchRequest = Note.fetchRequest()
        do{
        noteList = try StorageManager.shared.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let note = alert.textFields?.first?.text, !note.isEmpty else {return}
            self.save(note)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert,animated: true)
       
    }
    
    private func save(_ noteName: String){
        let note = Note(context: viewContext)
        note.title = noteName
        noteList.append(note)
        
        let cellIndex = IndexPath(row: noteList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        if viewContext.hasChanges {
            do{
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
                                                        
}


extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noteList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteID, for: indexPath)
        let note = noteList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = note.title
        cell.contentConfiguration = content
        return cell
    }
}

