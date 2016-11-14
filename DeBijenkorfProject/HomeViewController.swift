//
//  ViewController.swift
//  DeBijenkorfProject
//
//  Created by Supervisor on 14-11-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit
import SafariServices

class HomeViewController: UIViewController {
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var logoImage: UIImageView!
    
    var steps = 0
    var bool = false
    let vc = ItemsListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bool = true
        searchTextField.delegate = self
        self.searchButton.isEnabled = false
    }
    
    @IBAction func searchButtonTapped(_ sender: AnyObject) {
        
        self.searchButton.isEnabled = false
        if self.bool {
        performSegue(withIdentifier: "Manual", sender: nil)
        }
        else {
        self.loadInSafari(urlString: "www.google.nl")
        }
        self.searchTextField.text = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsListViewController
        destinationVC.searchTerm = self.searchTextField.text!
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text) as NSString?
        let textWithReplacedCharacters = text?.replacingCharacters(in: range, with: string)
        
        if (textWithReplacedCharacters?.isEmptyOrHasWhitespace())! {
            self.searchButton.isEnabled = false
        } else {
            self.searchButton.isEnabled = true
        }
        animateLogoImage()
        
        return true
    }
    
    func animateLogoImage() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            
            if self.steps == 0 {
                self.logoImage.transform = CGAffineTransform(scaleX: 1.09, y: 1.09)
                self.steps = 1
                print(self.steps)
            }
            else {
                self.logoImage.transform = CGAffineTransform.identity
                self.steps = 0
            }
            
            }, completion: nil)
    }
}

extension String {
    func isEmptyOrHasWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        return self.trimmingCharacters(in: .whitespaces) == ""
    }
}

extension UIViewController{
    func loadInSafari(urlString: String) {
        let itemURLString = "https:\(urlString)"
        let url = URL(string: itemURLString)!
        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = .orange
        vc.preferredControlTintColor = .white
        vc.navigationController?.navigationBar.isTranslucent = false
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

