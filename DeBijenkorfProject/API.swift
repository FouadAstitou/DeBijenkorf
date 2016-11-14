//
//  API.swift
//  Swift3RestAPI
//
//  Created by Supervisor on 14-11-16.
//  Copyright © 2016 Nerdvana. All rights reserved.
//

import Foundation
import SafariServices

protocol FHEMDelegate{
    
    func reloadDataOfTable()
}

enum ItemsResult {
    case Success([Item])
    case Failure(Error)
}

enum ItemError: Error {
    case InvalidJSONData
}

struct API {
    
    private static let baseURLString = "https://ceres-catalog.debijenkorf.nl/catalog/navigation/search?text="
    
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    static func fetchItemsFor(searchTerm: String, completionHandler: @escaping (ItemsResult) -> ()) {
        
        let urlString = self.baseURLString + searchTerm
        if let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            if let url = URL(string: encodedURLString) {
                let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    let result = processItemsForSearchTerm(data: data, error: error)
                    completionHandler(result)
                    
                })
                task.resume()
            }
        }
        
    }
    
    static   func processItemsForSearchTerm(data: Data?, error: Error?) -> ItemsResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        return self.itemsFromJSONData(data: jsonData)
    }
    
    static func itemsFromJSONData(data: Data) -> ItemsResult {
        
        do {
            guard
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject],
                let jsonDictionary = json["data"] as? [String: AnyObject],
                let itemsArray = jsonDictionary["products"] as? [[String: AnyObject]]
                
                else {
                    return .Failure(ItemError.InvalidJSONData)
            }
            if let redirectURL = jsonDictionary["redirectUrl"] as? String {
                let itemsListViewController = ItemsListViewController() 
                itemsListViewController.loadInSafari(urlString: redirectURL)
            }
            
            var finalItems = [Item]()
            for itemJSON in itemsArray {
                if let item = itemFromJSONObject(json: itemJSON) {
                    finalItems.append(item)
                }
                
            }
            
            if finalItems.count == 0 && itemsArray.count > 0 {
                // We weren't able to parse any of the photos. Maybe the JSON format for photos has changed.
                return .Failure(ItemError.InvalidJSONData)
            }
            return .Success(finalItems)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    static func itemFromJSONObject(json: [String : AnyObject]) -> Item? {
        guard
            let itemID = json["code"] as? String,
            let itemURL = json["url"] as? String,
            let itemImagesArray = json["currentVariantProduct"]?["images"] as? [[String: AnyObject]],
            let itemImageURL = itemImagesArray[0]["url"] as? String,
            let itemBrandName = json["brand"]?["name"] as? String,
            let itemName = json["name"] as? String,
            let itemPrice = json["sellingPrice"]?["value"] as? Double
            
            else {
                return nil
        }
        return Item(itemID: itemID, itemURL: itemURL, itemImageURL: itemImageURL, itemBrandName: itemBrandName, itemName: itemName, itemPrice: itemPrice)
    }
}
