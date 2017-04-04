//
//  OpeningViewController.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/16/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit


class OpeningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    @IBOutlet weak var booksTableView: UITableView!
    let dao = DAO.sharedInstance
    
    //sets up UI registers for notifications
    override func viewDidLoad() {
        super.viewDidLoad()
        let navbarFont = UIFont(name: "Ubuntu", size: 17) ?? UIFont.systemFont(ofSize: 17)
        let barbuttonFont = UIFont(name: "Ubuntu-Light", size: 15) ?? UIFont.systemFont(ofSize: 15)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: barbuttonFont, NSForegroundColorAttributeName:UIColor.white], for: UIControlState.normal)
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 127.0/255.0, green: 180.0/255.0, blue: 57.0/255.0, alpha: 0.5)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadTableView), name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
        self.navigationItem.title = "Books"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.moveToAddBookVC))
        let deleteAllButton = UIBarButtonItem.init(title: "Delete All", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.deleteAllBooks))
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem = deleteAllButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    //sets delegate and reloads table view on view will appear
    override func viewWillAppear(_ animated: Bool) {
        dao.delegate = self
        self.booksTableView.reloadData()
    }
    
    //deletes all books after network request finishes
    func deleteAllBooks() {
        confirmDeleteAll()
    }

    //moves to add book form
    func moveToAddBookVC() {
        let contoller = AddBookViewController()
        self.navigationController?.pushViewController(contoller, animated: true)
    }
    
    //reloads table view after recieving notification of completed API call
    func loadTableView() {
        self.booksTableView.reloadData()
    }
    
    //cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "identifier")
        if cell == nil{
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "identifier")
        }
        let tempBook = dao.libraryBookArray[indexPath.row]
        cell.textLabel?.text = tempBook.title
        cell.detailTextLabel?.text = tempBook.author
        return cell
    }
    
    //didSelectRowAt indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = BookDetailViewController()
        controller.currentBook = dao.libraryBookArray[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dao.libraryBookArray.count
    }

    // UIAlertController confirms with the user that they infact want to delete the entire library
    func confirmDeleteAll() {
        let alert = UIAlertController.init(title: "Warning", message: "You are electing to delete the entire library.", preferredStyle: UIAlertControllerStyle.alert)
        let yesButton = UIAlertAction.init(title: "delete all", style: UIAlertActionStyle.default) { _ in self.dao.deleteAllBooks()
        }
        let noButton = UIAlertAction.init(title: "cancel", style: UIAlertActionStyle.default) { (alert) in
        }
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //refreshes the library with the current library books incase some have been added by another user.  
    @IBAction func refreshLibraryPressed(_ sender: UIButton) {
        dao.clearLocalBooks()
        dao.getBooks()
    }
}


