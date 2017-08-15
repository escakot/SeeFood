//
//  DetailViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: Properties
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var defaultPhoto: UIImageView!
    @IBOutlet weak var defaultLabel: UILabel!
    
    
    var restaurant: RestaurantData!
    var parseRestaurant: Restaurant!
    var arrayOfMenuItems: [MenuItem] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantNameLabel.text = restaurant.name
        
        //MARK: Query Restaurant
        ParseManager.shared.queryRestaurantWith(id: restaurant.placeID) { (savedRestaurant:Restaurant?) in
            if savedRestaurant == nil {
                print("No Retaurants with id: \(self.restaurant.placeID)")
                ParseManager.shared.createRestaurantProfileWith(id: self.restaurant.placeID, name: self.restaurant.name, completionHandler: { (created:Bool) in
                    print("Restaurant Created Status: \(created)")
                    self.defaultPhoto.isHidden = false
                    self.defaultLabel.isHidden = false
                })
            }
            else{
                self.parseRestaurant = savedRestaurant
                print("Restaurant found: \(self.parseRestaurant.name)")
                
                //MARK: Query Items
                ParseManager.shared.queryMenuItemsFor(self.parseRestaurant) { (array: Array<MenuItem>?) in
                    if (array?.isEmpty)!{
                        self.defaultPhoto.isHidden = false
                        self.defaultLabel.isHidden = false
                        print("There are no Menu Items for \(self.parseRestaurant.name)")
                    }
                    else{
                        self.arrayOfMenuItems = array!
                        DispatchQueue.main.async {
                            self.mainCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

   
   
    
   
    
    //MARK: CollectionView Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfMenuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        cell.cellImage.image = UIImage(named: "meal.jpg")
        
        
        return cell
    }
    
    
    
    
    //MARK: IBActions
    
    @IBAction func addButton(_ sender: UIButton) {
        ParseManager.shared.createMenuItemFor(self.parseRestaurant, title: "Salmon") { (item:MenuItem) in
            self.arrayOfMenuItems.append(item)
            print("Menu item created: \(item.title)")
            DispatchQueue.main.async {
                self.mainCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func swipeToDismissView(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToCellDetail"{
            let vc = segue.destination as! CellDetailViewController
//            let index = self.mainCollectionView.indexPathsForSelectedItems
            vc.arrayOfMenuItems = self.arrayOfMenuItems
        }
    }
    
    
    

}
