//
//  MovieDetailViewController.swift
//  Flick
//
//  Created by Nguyen Trong Khoi on 2/15/17.
//  Copyright © 2017 Nguyen Trong Khoi. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var fullImageMovie: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var titleOverview: UILabel!
    @IBOutlet weak var movieContentScrollView: UIScrollView!
  
    
    var movie: Movie?
    var imageUrl : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentWidth = movieContentScrollView.bounds.width
        let contentHeight = movieContentScrollView.bounds.height + 80
        movieContentScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        titleLable.text = movie?.title
        titleOverview.text = movie?.overview
        titleOverview.sizeToFit()
        
        
        let imageRequest = URLRequest(url: URL(string: (movie?.imageUrl)!)!)
        
        fullImageMovie.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
        
            self.fullImageMovie.alpha = 0.0
            self.fullImageMovie.image = image
            UIView.animate(withDuration: 1, animations: { () -> Void in
                self.fullImageMovie.alpha = 1.0
                self.fullImageMovie.setImageWith(URL(string: (self.movie?.imageBigUrl)!)!)
                
            })

        }, failure: { (imageRequest, imageResponse, error) -> Void in
        })
        
    }
    
        
}
