//
//  ViewController.swift
//  DeBijenkorfProject
//
//  Created by Supervisor on 14-11-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit
import SafariServices

var redirectURLGlobal: String?
var hasToRedirect: Bool?

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var logoImage: UIImageView!
    
    // MARK: - Properties
    // This property is used for the logoImage animation
    var input = 0
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        self.searchButton.isEnabled = false
    }
    
    // MARK: - IBAction searchButtonTapped
    
    /*
     Workaround: So far i haven't managed to implement correct for logic when the api doesn't find products with a given searchterm. When there is a redirectUrl it is stored in redirectURLGlobal and hasToRedirect is set to true. But only after you repeat the same searchterm the link will be used to load the page.
     */
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        if hasToRedirect == true {
            if let redirectURL = redirectURLGlobal {
                self.loadInSafari(urlString: redirectURL,hasToRedirect: true)
                hasToRedirect = false
            }
        }
        else {
            performSegue(withIdentifier: "Manual", sender: nil)
        }
        self.searchTextField.resignFirstResponder()
        self.searchButton.isEnabled = false
        self.searchTextField.text = nil
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsListViewController
        destinationVC.searchTerm = self.searchTextField.text!
    }
}

//MARK: - Extension UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text) as NSString?
        let textWithReplacedCharacters = text?.replacingCharacters(in: range, with: string)
        
        if (textWithReplacedCharacters?.isEmptyOrHasWhitespace())! {
            self.searchButton.isEnabled = false
        } else {
            self.searchButton.isEnabled = true
        }
        self.animateLogoImage()
        
        return true
    }
    
    func animateLogoImage() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            
            if self.input == 0 {
                self.logoImage.transform = CGAffineTransform(scaleX: 1.09, y: 1.09)
                self.input = 1
            }
            else {
                self.logoImage.transform = CGAffineTransform.identity
                self.input = 0
            }
            
            }, completion: nil)
    }
}

//MARK: - Extension String
extension String {
    
    /// Checks if the string is empty and removes whitespaces
    func isEmptyOrHasWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        return self.trimmingCharacters(in: .whitespaces) == ""
    }
}

//MARK: - Extension UIViewController
extension UIViewController {
    
    /// Loads a SFSafariViewController
    func loadInSafari(urlString: String, hasToRedirect: Bool) {
        let itemURLString = urlString
        var url = URL(string: "")
        if hasToRedirect {
            url = URL(string: itemURLString) ?? URL(string: "www.debijenkorf.nl")
        }
        else {
            url = URL(string: "https:\(itemURLString)") ?? URL(string: "www.debijenkorf.nl")
        }
        let vc = SFSafariViewController(url: url!)
        vc.preferredBarTintColor = .orange
        vc.preferredControlTintColor = .white
        vc.navigationController?.navigationBar.isTranslucent = false
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

