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
    
    
    var restaurant: Restaurant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantNameLabel.text = restaurant.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        defaultPhoto.isHidden = false
        defaultLabel.isHidden = false
    }
    
    
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    


    
    
    //MARK: CollectionView Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        cell.cellImage.image = UIImage(named: "meal.jpg")
        
        
        return cell
    }
    
    
    
    
    @IBAction func swipeToDismissView(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToCellDetail"{
           // let index = self.mainCollectionView.indexPathsForSelectedItems
            let vc = segue.destination as! CellDetailViewController
            
            vc.browsingImage = UIImage(named: "meal.jpg")
            vc.browsingName = restaurant.name
        }
    }
    
    
    

}
