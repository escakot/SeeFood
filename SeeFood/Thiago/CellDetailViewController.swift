//
//  CellDetailViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-11.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

class CellDetailViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealPrice: UILabel!
    @IBOutlet weak var mealDescription: UITextView!
    
    var menutesting: Menutest?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    

 

}



class Menutest {
    var name: String!
    var description: String!
    var image: UIImage?
    
    init(name: String, description: String, image: UIImage) {
        self.name = name
        self.description = description
        self.image = image
    }
}



