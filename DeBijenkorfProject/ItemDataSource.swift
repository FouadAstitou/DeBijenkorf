//
//  ItemDataSource.swift
//  DeBijenkorfProject
//
//  Created by Supervisor on 14-11-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import UIKit

class ItemDataSource: NSObject, UICollectionViewDataSource {
    
    // MARK: - Properties
    var items = [Item]()
    
    // MARK: - UICollectionViewDataSource methodes
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let item = items[indexPath.item]
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: "https:\(item.itemImageURL)") {
                let data = try! Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    cell.itemImage.image = UIImage(data: data)
                }
            }
        }
        cell.itemBrandName.text = item.itemBrandName.uppercased()
        cell.itemName.text = item.itemName
        cell.itemPrice.text = format(amount: item.itemPrice)
        return cell
    }
    
    // MARK: - numberformatter
    func format(amount: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "EUR"
        return numberFormatter.string(from: NSNumber(value: amount))!
    }
}

