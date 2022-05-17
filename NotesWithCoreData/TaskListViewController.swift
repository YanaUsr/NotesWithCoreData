//
//  ViewController.swift
//  NotesWithCoreData
//
//  Created by Яна Иноземцева on 15.05.2022.
//

import UIKit


class TaskListViewController: UITableViewController {
    
    
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
      showAlert()
    }
    
    
    private func EditShowAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let note = alert.textFields?.first?.text, !note.isEmpty else {return}
            self.save(note)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Update Task"
        }
        present(alert,animated: true)
       
    }
    
    
    private func save(_ noteName: String){
        StorageManager.shared.create(noteName) { note in
            self.noteList.append(note)
            self.tableView.insertRows(
                at: [IndexPath(row: self.noteList.count - 1, section: 0)],
                with: .automatic
            )
        }
        
        
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let notes):
                self.noteList = notes
            case .failure(let error):
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

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = noteList[indexPath.row]
        showAlert(note: note) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = noteList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(note)
        }
    }
}

// MARK: - Alert Controller
extension TaskListViewController {
    private func showAlert(note: Note? = nil, completion: (() -> Void)? = nil) {
        let title = note != nil ? "Update Task" : "New Task"
        let alert = UIAlertController.createAlertController(withTitle: title)
        
        alert.action(note: note) { noteName in
            if let note = note, let completion = completion {
                StorageManager.shared.update(note, newName: noteName)
                completion()
            } else {
                self.save(noteName)
            }
        }
        
        present(alert, animated: true)
    }
}




