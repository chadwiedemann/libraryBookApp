//
//  Extensions.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/21/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: HandleAlamoError {
    
    //method from custom protocol HandleAlamoError that can be called from model to show UIAlertView on current view controller
    func showErrorAlert(message: String){
        let alertController = UIAlertController.init(title: "Network Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction.init(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    //hides the keyboard when user presses on the main view
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //dismisses keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
}




