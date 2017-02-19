//
//  Movie.swift
//  Flick
//
//  Created by Nguyen Trong Khoi on 2/15/17.
//  Copyright © 2017 Nguyen Trong Khoi. All rights reserved.
//

import Foundation
import UIKit

class Movie{
    
    let title:String
    let overview: String
    let imageUrl: String
    let imageBigUrl: String
    
    init(title: String , overview : String , imageUrl : String , imagebigUrl : String){
        self.title = title
        self.overview = overview
        self.imageUrl = imageUrl
        self.imageBigUrl = imagebigUrl
    }
    
    
    class func getMoviesList(link: URL, callback: @escaping ([[String : AnyObject]]) -> (Void) , callbackError : @escaping(String) -> (Void) ) {
        var items = [[String : AnyObject]]()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
       
        URLSession.shared.dataTask(with: link) { (data, response, error) in
            if error != nil {
                callbackError((error?.localizedDescription)!)
            } else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    items = json["results"] as! [[String : AnyObject]]
                } catch _ {
                   callbackError("Parse Json False")
                }
                 callback(items)
            }
            
        }.resume()
    }
    
    
    class func object(at: Int, fromList: Array<[String : AnyObject]>, callback: @escaping ((Movie, Int) -> Void))  {
        let  baseUrl = "https://image.tmdb.org/t/p/w300"
        let  baseBigUrl = "https://image.tmdb.org/t/p/w500"

        DispatchQueue.global(qos: .userInteractive).async(execute: {
            let item = fromList[at]
            let title  = item["title"] as! String
            let overview = item["overview"] as! String
            let imageUrl = "\(baseUrl)\(item["poster_path"] as! String)"
            let imageBigUrl = "\(baseBigUrl)\(item["poster_path"] as! String)"
            let movie = Movie.init(title: title, overview: overview, imageUrl: imageUrl, imagebigUrl: imageBigUrl)
            
            callback(movie, at)
        })
    }

    
}
