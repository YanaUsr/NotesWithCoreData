//
//  StorageManager.swift
//  NotesWithCoreData
//
//  Created by Яна Иноземцева on 15.05.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
  private var persistentContainer: NSPersistentContainer = {
      
       let container = NSPersistentContainer(name: "NotesWithCoreData")
       container.loadPersistentStores(completionHandler: { (storeDescription, error) in
           if let error = error as NSError? {
         
               fatalError("Unresolved error \(error), \(error.userInfo)")
           }
       })
       return container
   }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    func fetchData(completion: (Result<[Note], Error>) -> Void) {
        let fetchRequest = Note.fetchRequest()
        
        do {
            let note = try self.viewContext.fetch(fetchRequest)
            completion(.success(note))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - Core Data Saving support

    func create(_ noteName: String, completion: (Note) -> Void) {
        let note = Note(context: viewContext)
        note.title = noteName
        completion(note)
        saveContext()
    }
    
    func update(_ note: Note, newName: String) {
        note.title = newName
        saveContext()
    }
    
    func delete(_ note: Note) {
        viewContext.delete(note)
        saveContext()
    }
    

    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
