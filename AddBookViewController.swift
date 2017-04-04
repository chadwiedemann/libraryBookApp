//
//  AddBookViewController.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/16/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController {

    var dao = DAO.sharedInstance
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var categoriesTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createdUI()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    //sumbits the changes in the form to create a new book also shows an alert
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if authorTextField.text == "" || bookTitleTextField.text == "" {
            let alert = UIAlertController.init(title: "Error", message: "New books must have a title and author listed.  Please update fields.", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction.init(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let newBook = Book.init(author: self.authorTextField.text, categories: self.categoriesTextField.text, bookid: 1, lastCheckedOut: "", lastCheckedOutBy: "", publisher: self.publisherTextField.text, title: self.bookTitleTextField.text, url: "")
            dao.post(book: newBook!)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    //send the user back to the library view
    func leaveForm() {
        if self.authorTextField.text == "" && self.bookTitleTextField.text == "" && self.categoriesTextField.text == "" && self.publisherTextField.text == "" {
            _ = self.navigationController?.popViewController(animated: true)
        } else{
            presentLeaveWithoutChangesView()
        }
    }
    
    //presents a UIAlertView
    func presentLeaveWithoutChangesView() {
        let alert = UIAlertController.init(title: "Unsaved Changes", message: "You are leaving the page without submitting a new book", preferredStyle: UIAlertControllerStyle.alert)
        let yesButton = UIAlertAction.init(title: "okay", style: UIAlertActionStyle.default) { alert in
            _ = self.navigationController?.popViewController(animated: true)
        }
        let noButton = UIAlertAction.init(title: "cancel", style: UIAlertActionStyle.default) { (alert) in
        }
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //creates UI
    func createdUI(){
        self.navigationItem.title = "Add Book"
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.leaveForm))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.hideKeyboardWhenTappedAround()
    }
}
