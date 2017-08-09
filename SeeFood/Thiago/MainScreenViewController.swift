//
//  MainScreenViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var mapListButton: UIButton!
    
    @IBOutlet weak var mainTable: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    
    
    
    @IBAction func switchMapListButton(_ sender: UIButton) {
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 3,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
//                        sender.transform = sender.transform.rotated(by: CGFloat(Double.pi/4))
                        if self.mainTable.isHidden {
                            self.mainTable.isHidden = false
                        }
                        else{
                            self.mainTable.alpha = 0
                        }
                        self.view.layoutIfNeeded()
        }, completion: nil)

        
    }
    
    
    
    
    
    
    
    
    
    //MARK: TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.cellLogoImage.image = UIImage(named: "defaultrestlogo.png")
        cell.cellRestaurantTitle.text = "La Banane"
        cell.cellRatingsImage.image = UIImage(named: "")
        cell.cellPhotoCountLabel.text = "0 Photos"
        
        return cell
    }

    
    
    
    
    
}
