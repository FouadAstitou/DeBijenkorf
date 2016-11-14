//
//  ItemsListViewController.swift
//  DeBijenkorfProject
//
//  Created by Supervisor on 14-11-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit
import SafariServices

class ItemsListViewController: UIViewController {
    
    @IBOutlet var listCollectionView: UICollectionView!
    
    let itemDataSource = ItemDataSource()
    var items = [Item]()
    var searchTerm = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listCollectionView.dataSource = itemDataSource
        self.listCollectionView.delegate = self
        
        self.title = self.searchTerm
        self.loadData()

        print(items.count)
    }
    
    func loadData() {
        API.fetchItemsFor(searchTerm: self.searchTerm) { (itemsResult) in
            DispatchQueue.main.async {
                
                switch itemsResult {
                    
                case let .Success(items):
                    self.itemDataSource.items = items
                    print("Successfully found \(items.count) items.")
                    
                case let .Failure(error):
                    self.itemDataSource.items.removeAll()
                    print("Error fetching items for search term: \(self.searchTerm), error: \(error)")
                }
                self.listCollectionView.reloadData()
            }
            
        }
    }
}

extension ItemsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.listCollectionView.bounds.size.width / 2.0 - 14.0 , height: 300)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = self.itemDataSource.items[indexPath.item]
        self.loadInSafari(urlString: item.itemURL)
    }
}
