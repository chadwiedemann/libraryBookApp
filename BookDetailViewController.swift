//
//  BookDetailViewController.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/16/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {

    @IBOutlet weak var bookCheckoutInfo: UILabel!
    @IBOutlet weak var bookCategories: UILabel!
    @IBOutlet weak var bookPublisher: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookTitle: UILabel!
    var currentBook: Book!
    let dao = DAO.sharedInstance
    @IBOutlet weak var borrowerInfoLabel: UILabel!
    
    //create UI and register for notifications
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Detail"
        let shareButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(self.shareOnFBorTwitter))
        self.navigationItem.rightBarButtonItem = shareButton
        let backButton = UIBarButtonItem.init(image: UIImage.init(named: "arrow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateUI), name: NSNotification.Name(rawValue: "updateUI"), object: nil)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    //updates UI after download and sets DAO delegate
    override func viewWillAppear(_ animated: Bool) {
        dao.delegate = self
        updateUI()
    }
    
    //sends user aback to library view
    func backButtonPressed() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    
    //shares book on FB or Twitter
    func shareOnFBorTwitter(){
        let controller = UIActivityViewController(activityItems: ["I just read \(self.currentBook.title!) by \(self.currentBook.author!) I highly recommend it."], applicationActivities: nil)
        present(controller, animated: true, completion: {})
    }
    
    //updates the book with checkout data
    @IBAction func checkOutButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Checkout Book", message: "Please input your name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.currentBook.lastCheckOutBy = textField!.text
            self.dao.checkOut(book: self.currentBook)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //deletes book and sends user back to library view
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        dao.delete(book: self.currentBook)
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    //sends user to edit form
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let controller = EditBookViewController()
        controller.currentBook = self.currentBook
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //updates UI after download
    func updateUI() {
        bookTitle.text = currentBook.title
        bookTitle.lineBreakMode = .byWordWrapping
        bookTitle.numberOfLines = 0
        bookTitle.sizeToFit()
        bookCategories.text = "Tags: \(currentBook.categories!)"
        bookPublisher.text = "Publisher: \(currentBook.publisher!)"
        bookAuthor.text = currentBook.author
        if let lastCheckOut = currentBook.lastCheckOut{
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, yyyy h:mma"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            let dateString = formatter.string(from: lastCheckOut)
            borrowerInfoLabel.text = "\(currentBook.lastCheckOutBy!) @ \(dateString)"
        }
    }
}
