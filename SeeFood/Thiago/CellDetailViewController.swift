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
   var selectedCellIndex = IndexPath()
   var blurEffect: UIBlurEffect!
   var blurEffectView: UIVisualEffectView!
   @IBOutlet weak var blurBackgroundView: UIView!
   
   // TESTING PROP:
   var browsingImage: UIImage!
   var browsingName: String!
   
   
   
   
   
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
      collectionView.scrollToItem(at: selectedCellIndex, at: .right, animated: true)
      pageControl.currentPage = Int(collectionView.contentOffset.x/self.collectionView.frame.size.width)
      
      
      //MARK: Blur BG
      blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
      blurEffectView = UIVisualEffectView(effect: blurEffect)
      blurEffectView.frame = self.collectionView.bounds
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      blurEffectView.alpha = 0.9
      blurBackgroundView.addSubview(blurEffectView)
   }
   
   
   
   
   //MARK: CollectionView Methods
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return arrayOfMenuItems.count
   }
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CellSwipe
      
      ParseManager.shared.queryReviewFor(self.arrayOfMenuItems[indexPath.row]) { (reviews: Array<Review>?) in
         reviews?[0].image.getDataInBackground(block: { (data: Data?, error:Error?) in
            if error == nil {
               DispatchQueue.main.async {
                  cell.cellImage.image = UIImage(data: data!)
                  cell.cellBGImage.image = cell.cellImage.image
                  cell.cellBGImage.alpha = 0.6
               }
            }
            else {
               print(error?.localizedDescription ?? "Error converting UIImage to PFFile")
            }
         })
      }
      return cell
   }
   

   
   
   
   
   
   
   
   @IBAction func backButton(_ sender: UIButton) {
      dismiss(animated: true, completion: nil)
   }

   
   //MARK: ScrollView Methods
   func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      pageControl.currentPage = Int(collectionView.contentOffset.x/self.collectionView.frame.size.width)
   }

   
   
   
   
}





//MARK: Cell Class
class CellSwipe: UICollectionViewCell {
   @IBOutlet weak var cellImage: UIImageView!
   @IBOutlet weak var cellBGImage: UIImageView!
}






