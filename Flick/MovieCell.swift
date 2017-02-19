//
//  MovieCell.swift
//  Flick
//
//  Created by Nguyen Trong Khoi on 2/15/17.
//  Copyright © 2017 Nguyen Trong Khoi. All rights reserved.
//

import UIKit
import AFNetworking

class MovieCell: UITableViewCell {

 
    @IBOutlet weak var movieThumbImage: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var overviewLable: UILabel!
    
    
    func resetCell(){
        
        self.titleLable.text = ""
        self.overviewLable.text = ""
        
    }
    
    func setupCell(movieItem : Movie)
    {
        self.titleLable.text = movieItem.title
        self.overviewLable.text = movieItem.overview
        self.movieThumbImage.setImageWith(URL.init(string: movieItem.imageUrl)!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
