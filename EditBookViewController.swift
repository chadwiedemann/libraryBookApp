//
//  EditBookViewController.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/16/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit

class EditBookViewController: UIViewController {

    @IBOutlet weak var catagoriesTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var bookAuthorTextField: UITextField!
    @IBOutlet weak var bookTitleTextField: UITextField!
    let dao = DAO.sharedInstance
    var currentBook: Book!
    
    //sets up UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Edit Book"
        self.hideKeyboardWhenTappedAround()
        let backButton = UIBarButtonItem.init(image: UIImage.init(named: "arrow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

    //refreshes UI
    override func viewWillAppear(_ animated: Bool) {
        catagoriesTextField.text = currentBook.categories
        publisherTextField.text = currentBook.publisher
        bookAuthorTextField.text = currentBook.author
        bookTitleTextField.text = currentBook.title
    }
    
    //send data to model to edit book on the server
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        self.currentBook.author = bookAuthorTextField.text
        self.currentBook.title = bookTitleTextField.text
        self.currentBook.categories = catagoriesTextField.text
        self.currentBook.publisher = publisherTextField.text
        dao.edit(book: self.currentBook)
        _ = self.navigationController?.popViewController(animated: true)
    }

    //sends user back to book detail view
    func backButtonPressed() {
        _  = self.navigationController?.popViewController(animated: true)
    }
}
