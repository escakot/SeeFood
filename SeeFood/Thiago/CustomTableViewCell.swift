//
//  CustomTableViewCell.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var cellLogoImage: UIImageView!
    
    @IBOutlet weak var cellRestaurantTitle: UILabel!
    
    @IBOutlet weak var cellRatingsImage: UIImageView!
    
    @IBOutlet weak var cellPhotoCountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
