//
//  CellDetailViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-11.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class CellDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    var arrayOfMenuItems: [MenuItem] = []
    
    
    // TESTING PROP:
    var browsingImage: UIImage!
    var browsingName: String!
    
    var imageList:[String] = ["turkey.jpg", "meal.jpg", "meal.jpg","meal.jpg","meal.jpg","meal.jpg","meal.jpg"]

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = arrayOfMenuItems.count
        mealName.text = arrayOfMenuItems[0].title
        //MARK: CollectionView Layout
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        layout.sideItemAlpha = 0
        layout.sideItemScale = 1
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
    
    
    
    
    //MARK: CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfMenuItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CellSwipe
        cell.cellImage.image = UIImage(named: imageList[indexPath.row])
        return cell
    }
    
    
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(collectionView.contentOffset.x/self.collectionView.frame.size.width)
    }


 

}



//MARK: Cell Class
class CellSwipe: UICollectionViewCell {
    @IBOutlet weak var cellImage: UIImageView!
}






