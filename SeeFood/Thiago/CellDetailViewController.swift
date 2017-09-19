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
   var arrayOfReviews: [Review] = []
  var selectedCellIndex = IndexPath()
  var blurEffect: UIBlurEffect!
  var blurEffectView: UIVisualEffectView!
  @IBOutlet weak var blurBackgroundView: UIView!
  @IBOutlet weak var tagsONOFFLabel: UILabel!
  @IBOutlet weak var switchOnOffTagsOutlet: UISwitch!
  
  
  // TESTING PROP:
  var browsingImage: UIImage!
  var browsingName: String!
  
  
  // Tags
  var listOfTags: [UILabel] = []
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    self.mealName.text = self.arrayOfMenuItems[selectedCellIndex[1]].title
    //MARK: CollectionView Layout
    let layout = UPCarouselFlowLayout()
    layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    layout.sideItemAlpha = 0
    layout.sideItemScale = 1
    layout.scrollDirection = .horizontal
    collectionView.collectionViewLayout = layout
//    collectionView.scrollToItem(at: selectedCellIndex, at: .right, animated: true)
    pageControl.currentPage = Int(collectionView.contentOffset.x/self.collectionView.frame.size.width)
    
    
    //MARK: Blur BG
    blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = self.collectionView.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurEffectView.alpha = 0.9
    blurBackgroundView.addSubview(blurEffectView)
   
   queryReviews()
  }
  
   
   
   func queryReviews(){
      ParseManager.shared.queryReviewFor(self.arrayOfMenuItems[selectedCellIndex[1]]) { (reviews: Array<Review>?) in
         self.arrayOfReviews = reviews!
         DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.pageControl.numberOfPages = self.arrayOfReviews.count
         }
      }
   }
  
  
  
  //MARK: CollectionView Methods
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.arrayOfReviews.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CellSwipe
   
          self.listOfTags.removeAll()
          for view in cell.cellImage.subviews { view.removeFromSuperview() }
          ParseManager.shared.queryTagsFor(self.arrayOfReviews[indexPath.row], completionHandler: { (tags:Array<Tag>?) in
            guard let tags = tags else { return }
            for tag in tags
            {
              self.createTag(tag, imageView: cell.cellImage)
            }
          })
          DispatchQueue.main.async {
            do {
              cell.cellImage.image = try UIImage(data: Data(contentsOf: URL(string:self.arrayOfReviews[indexPath.row].url)!))
            } catch {
              print(error.localizedDescription)
            }
            cell.cellBGImage.image = cell.cellImage.image
            cell.cellBGImage.alpha = 0.6
          }
   
    return cell
  }
  
  @IBAction func backButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  
  //MARK: ScrollView Methods
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pageControl.currentPage = Int(collectionView.contentOffset.x/self.collectionView.frame.size.width)
    self.mealName.text = self.arrayOfMenuItems[selectedCellIndex.row].title
  }
  
  
  
  @IBAction func switchOnOFFTags(_ sender: UISwitch) {
    if sender.isOn {
      tagsONOFFLabel.isHidden = false
      for tag in listOfTags { tag.isHidden = false }
    }
    else {
      tagsONOFFLabel.isHidden = true
      for tag in listOfTags { tag.isHidden = true }
    }
  }
  
  
  func createTag(_ tag:Tag, imageView:UIImageView)
  {
    
    let imageRect = getImageRect(imageView: imageView)
    let tagLabel = UILabel()
    let font = UIFont.systemFont(ofSize: 15)
    tagLabel.font = font
    tagLabel.text = tag.title
    tagLabel.textAlignment = .center
    tagLabel.sizeToFit()
    tagLabel.frame.size = CGSize(width: tagLabel.frame.size.width + 10, height: tagLabel.frame.size.height + 5)
    tagLabel.center = CGPoint(x: tag.centerX * imageRect.width + imageRect.origin.x, y: tag.centerY * imageRect.height + imageRect.origin.y)
    
    tagLabel.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
    tagLabel.layer.borderWidth = 1
    tagLabel.layer.borderColor = UIColor.black.cgColor
    tagLabel.layer.cornerRadius = 5
    
    tagLabel.isHidden = tagsONOFFLabel.isHidden
    
    listOfTags.append(tagLabel)
    imageView.addSubview(tagLabel)
  }
  
  func getImageRect(imageView:UIImageView) -> CGRect
  {
    guard let image = imageView.image else { return CGRect.zero }
    let ratio = image.size.width/image.size.height
    let newHeight = view.frame.width / ratio
    let newWidth = view.frame.width
    
//    if newHeight > view.frame.height
//    {
//      newHeight = view.frame.height
//      newWidth = newHeight * ratio
//    }
    
    let screenSizeX = imageView.frame.width
    let screenSizeY = imageView.frame.height
    
    let imageOriginX = (screenSizeX - newWidth) / 2
    let imageOriginY = (screenSizeY - newHeight) / 2
    
    return CGRect(x: imageOriginX, y: imageOriginY, width: newWidth, height: newHeight)
  }
  
}


//MARK: Cell Class
class CellSwipe: UICollectionViewCell {
  @IBOutlet weak var cellImage: UIImageView!
  @IBOutlet weak var cellBGImage: UIImageView!
}






