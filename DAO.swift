//
//  DAO.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/18/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

//used to pass data to viewController to show UIAlert
protocol HandleAlamoError {
    func showErrorAlert(message: String)
}

class DAO: NSObject {

    static let sharedInstance = DAO()
    var libraryBookArray: Array<Book> = []
    var bookMOArray: Array<BookMO> = []
    var delegate: UIViewController?
    
    //this function retrieves the books data from the server
    func getBooks() {
        Alamofire.request(AppKeys.serverURL.rawValue + AppKeys.booksDirectory.rawValue).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_,subJson):(String, JSON) in json {
                    let author = subJson[AppKeys.author.rawValue].stringValue
                    let categories = subJson[AppKeys.categories.rawValue].stringValue
                    let id = subJson[AppKeys.id.rawValue].int!
                    let lastCheckedOut = subJson[AppKeys.lastCheckedOut.rawValue].stringValue
                    let lastCheckedOutBy = subJson[AppKeys.lastCheckedOutBy.rawValue].stringValue
                    let publisher = subJson[AppKeys.publisher.rawValue].stringValue
                    let title = subJson[AppKeys.title.rawValue].stringValue
                    let url = subJson[AppKeys.url.rawValue].stringValue
                    let currentBook = Book.init(author: author, categories: categories, bookid: Int32(id), lastCheckedOut: lastCheckedOut, lastCheckedOutBy: lastCheckedOutBy, publisher: publisher, title: title, url: url)
                    self.createManaged(book: currentBook!)
                    self.libraryBookArray.append(currentBook!)
                } 
                let notificationCenter = NotificationCenter.default
                notificationCenter.post(name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    //adds a new book to the server and then parses the response to create a new local Book
    func post(book: Book) {
        let parameters: Parameters = [AppKeys.author.rawValue: book.author!, AppKeys.categories.rawValue: book.categories ?? "", AppKeys.title.rawValue: book.title!, AppKeys.publisher.rawValue: book.publisher ?? ""]
        Alamofire.request(AppKeys.serverURL.rawValue + AppKeys.booksDirectory.rawValue, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in print(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let author = json[AppKeys.author.rawValue].stringValue
                let categories = json[AppKeys.categories.rawValue].stringValue
                let bookid = json[AppKeys.id.rawValue].int
                let lastCheckedOut = json[AppKeys.lastCheckedOut.rawValue].stringValue
                let lastCheckedOutBy = json[AppKeys.lastCheckedOutBy.rawValue].stringValue
                let publisher = json[AppKeys.publisher.rawValue].stringValue
                let title = json[AppKeys.title.rawValue].stringValue
                let url = json[AppKeys.url.rawValue].stringValue
                let tempBook = Book.init(author: author, categories: categories, bookid: Int32(bookid!), lastCheckedOut: lastCheckedOut, lastCheckedOutBy: lastCheckedOutBy, publisher: publisher, title: title, url: url)
                self.createManaged(book: tempBook!)
                self.libraryBookArray.append(tempBook!)
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.post(name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    //deletes a book from the server
    func delete(book: Book) {
        let filePath = AppKeys.serverURL.rawValue + AppKeys.booksDirectory.rawValue + "\(book.bookid)"
        Alamofire.request(filePath, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).response{
            response in
            if let error = response.error{
                DispatchQueue.main.async {
                    self.delegate?.showErrorAlert(message: error.localizedDescription)
                }
            }else{
                for element in self.libraryBookArray {
                    if element === book{
                        self.libraryBookArray.remove(at: self.libraryBookArray.index(of: element)!)
                        self.deleteManaged(book: book)
                    }
                }
                let notificationCenter = NotificationCenter.default
                notificationCenter.post(name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
            }
        }
    }
    
    //updates an exsiting entry on the server to reflect new checkout info
    func checkOut(book: Book) {
        let formatter = DateFormatter()
        formatter.dateFormat = AppKeys.dateFormat.rawValue
        book.lastCheckOut = Date.init()
        editManaged(book: book)
        let checkOutString = formatter.string(from: book.lastCheckOut!)
        let parameters: Parameters = [AppKeys.lastCheckedOut.rawValue: checkOutString, AppKeys.lastCheckedOutBy.rawValue: book.lastCheckOutBy!]
        let url = AppKeys.serverURL.rawValue + AppKeys.booksDirectory.rawValue + String(book.bookid)
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                let notificationCenter = NotificationCenter.default
                notificationCenter.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    //updates the server with new data for the edit form
    func edit(book: Book) {
        editManaged(book: book)
        let parameters: Parameters = [AppKeys.author.rawValue: book.author!, AppKeys.title.rawValue: book.title!, AppKeys.publisher.rawValue: book.publisher!, AppKeys.categories.rawValue: book.categories!]
        let url = AppKeys.serverURL.rawValue + AppKeys.booksDirectory.rawValue + String(book.bookid)
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in print(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    //deletes all the books from the server and locally
    func deleteAllBooks() {
        let url = AppKeys.serverURL.rawValue + "clean"
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).response{
            response in
            if let error = response.error{
                DispatchQueue.main.async {
                    self.delegate?.showErrorAlert(message: error.localizedDescription)
                }
            }else{
            self.libraryBookArray.removeAll()
            self.deleteAllManagedBooks()
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
            }
        }
    }
    
    //creates a managed book object to store in CoreData
    func createManaged(book: Book) {
        let newManagedBook = NSEntityDescription.insertNewObject(forEntityName: "BookMO", into: managedObjectContext) as! BookMO
        newManagedBook.bookid = book.bookid
        newManagedBook.author = book.author
        newManagedBook.categories = book.categories
        newManagedBook.publisher = book.publisher
        newManagedBook.url = book.url
        newManagedBook.lastCheckedOutBy = book.lastCheckOutBy
        newManagedBook.title = book.title
        if (book.lastCheckOut != nil){
            let formatter = DateFormatter()
            formatter.dateFormat = AppKeys.dateFormat.rawValue
            let checkOutString = formatter.string(from: book.lastCheckOut)
            newManagedBook.lastCheckedOut = checkOutString
        }
        self.bookMOArray.append(newManagedBook)
    }
    
    //edits an already existing managed Book object
    func editManaged(book: Book) {
        for element in self.bookMOArray {
            if element.bookid == book.bookid {
                element.author = book.author
                element.publisher = book.publisher
                element.categories = book.categories
                element.title = book.title
                if (book.lastCheckOut != nil){
                    let formatter = DateFormatter()
                    formatter.dateFormat = AppKeys.dateFormat.rawValue
                    let checkOutString = formatter.string(from: book.lastCheckOut)
                    element.lastCheckedOut = checkOutString
                }
                element.lastCheckedOutBy = book.lastCheckOutBy
                do {
                    try managedObjectContext.save()
                } catch  {
                    print(error)
                }
            }
        }
    }
    
    //removes a managed Book object from the managed object context
    func deleteManaged(book: Book) {
        for element in self.bookMOArray {
            if element.bookid == book.bookid{
                managedObjectContext.delete(element)
            }
        }
    }
    
    //removes all of the managed Books from the managed object context
    func deleteAllManagedBooks() {
        for element in self.bookMOArray {
            managedObjectContext.delete(element)
        }
    }
    
    //loads Books from CoreData if available if not then it makes a API call the the library server
    func loadDataFromCoreData(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BookMO")
        let sortDescriptor = NSSortDescriptor(key: "bookid", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetch.sortDescriptors = sortDescriptors
        do {
            let fetchedBooks = try managedObjectContext.fetch(fetch)
            self.bookMOArray = fetchedBooks as! Array<BookMO>
            if self.bookMOArray.count > 0 {
                self.createBookArrayFromCoreData()
            }else{
                self.getBooks()
            }
        } catch {
            self.getBooks()
        }
    }
    
    //creates a regular object array from a managed object array
    func createBookArrayFromCoreData() {
        for book in self.bookMOArray {
            let newBook = Book.init(author: book.author, categories: book.categories, bookid: book.bookid, lastCheckedOut: book.lastCheckedOut, lastCheckedOutBy: book.lastCheckedOutBy, publisher: book.publisher, title: book.title, url: book.url)
            self.libraryBookArray.append(newBook!)
        }
    }
    
    //removes all Book objects from the class
    func clearLocalBooks() {
        deleteAllManagedBooks()
        self.libraryBookArray.removeAll()
        saveContext()
    }
    
    // MARK: - CoreData Stack
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ProlificCodingChallenge.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        let undoManager = UndoManager.init()
        managedObjectContext.undoManager = undoManager
        return managedObjectContext
    }()

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
