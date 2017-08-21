//
//  AddReviewViewController.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse
import Toucan
import Clarifai
import Stevia

class AddReviewViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var foodImageView: UIImageView!
  @IBOutlet weak var menuItemTextField: UITextField!
  @IBOutlet weak var foodImageViewHeight: NSLayoutConstraint!
  
  var restaurant: Restaurant!
  var menuItem: MenuItem?
  var foodImage: UIImage!
  let clarifaiAPI = "c2b0351a3e40478ca234a70c36fa864f"
  let tagStackView = UIStackView()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    if menuItem != nil
    {
      menuItemTextField.text = menuItem!.title
      menuItemTextField.isEnabled = false
    }
    
//    setImageViewSize(image: foodImage)
//    foodImageView.image = Toucan.Resize.resizeImage(foodImage, size: foodImageView.frame.size)
//    setImageViewSize(image: UIImage(named: "chickenRice.jpg")!)
//    foodImageView.image = Toucan.Resize.resizeImage(UIImage(named:"chickenRice.jpg")!, size: foodImageView.frame.size)
    
    
//    let clarifai = ClarifaiApp.init(apiKey: clarifaiAPI)
//    let clarifaiImage = ClarifaiImage.init(image: foodImage)!
//    clarifai?.getModelByID("bd367be194cf45149e75f01d59f77ba7", completion: { (model, error) in
//      if error == nil
//      {
//        model!.predict(on: [clarifaiImage], completion: { (outputs:[ClarifaiOutput]?, outputError) in
//          if outputError == nil
//          {
////            print(String(format: "Outputs: %@", outputs![0]))
//            let responseData = (outputs![0].responseDict as! [String:AnyObject])["data"] as! [String:AnyObject]
//            let possibleItems = responseData["concepts"] as! [[String:AnyObject]]
//            for item in possibleItems
//            {
//              self.createTag(name: item["name"] as! String)
//            }
//          }
//        })
//      }
//    })
    view.sv([tagStackView])
    view.layout(
    foodImageView.frame.maxY + 40,
    tagStackView.fillHorizontally(),
    10)
    
    let tempArray = ["Chicken", "Rice", "Vegetables", "Beef"]
    for food in tempArray
    {
      createTag(name: food)
    }
    
    resizeTagStackView()
    view.addSubview(tagStackView)
  }
  
  
  // MARK: - Button Methods
  @IBAction func postButton(_ sender: UIBarButtonItem)
  {
    guard PFUser.current() != nil else {
      dismiss(animated: true)
      return
    }
    let image = foodImageView.image!
    if let menuItem = menuItem
    {
      ParseManager.shared.addReviewFor(menuItem, at: restaurant, image: image, completionHandler: {
      })
    } else {
      let title = menuItemTextField.text!
      ParseManager.shared.createMenuItemFor(restaurant, title: title, completionHandler: { (savedMenuItem) in
        ParseManager.shared.addReviewFor(savedMenuItem, at: self.restaurant, image: image, completionHandler: {
          self.dismiss(animated: true)
        })
      })
    }
    print("saved")
  }
  @IBAction func cancelButton(_ sender: UIBarButtonItem)
  {
    dismiss(animated: true)
  }
  
  func setImageViewSize(image:UIImage)
  {
    let ratio = image.size.width/image.size.height
    let newHeight = view.frame.width / ratio
    foodImageViewHeight.constant = newHeight
    foodImageView.frame.size = CGSize(width: view.frame.width, height: newHeight)
  }
  
  func createTag(name:String)
  {
    
    let tagLabel = UILabel()
    let font = UIFont.systemFont(ofSize: 10)
    tagLabel.font = font
    tagLabel.text = name
    tagLabel.sizeToFit()
    
    let closeTagButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    closeTagButton.setImage(image: UIImage(named: "close-icond.png"), inFrame: CGRect(x: 0, y: 0, width: 20, height: 20), forState: .normal)
    closeTagButton.tap { closeTagButton.superview?.removeFromSuperview() }
    
    let stack = UIStackView.init(arrangedSubviews: [tagLabel, closeTagButton])
    stack.isUserInteractionEnabled = true
    stack.spacing = 5
    stack.setNeedsUpdateConstraints()
    stack.updateConstraintsIfNeeded()
    stack.setNeedsLayout()
    stack.layoutIfNeeded()
    stack.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    
    let tagPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panMoveTag))
    stack.addGestureRecognizer(tagPanGesture)
    stack.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
    stack.center = CGPoint(x: view.center.x, y: view.center.y + 200)
    
    tagStackView.addArrangedSubview(stack)
  }
  
  func panMoveTag(sender:UIPanGestureRecognizer)
  {
    let translation = sender.translation(in: view)
    sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x,
                                  y: sender.view!.center.y + translation.y)
    sender.setTranslation(CGPoint.zero, in: view)
  }
  
  func resizeTagStackView()
  {
    tagStackView.setNeedsUpdateConstraints()
    tagStackView.updateConstraintsIfNeeded()
    tagStackView.setNeedsLayout()
    tagStackView.layoutIfNeeded()
    tagStackView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
  }
}

extension UIButton{
  
  func setImage(image: UIImage?, inFrame frame: CGRect?, forState state: UIControlState){
    self.setImage(image, for: state)
    
    if let frame = frame{
      self.imageEdgeInsets = UIEdgeInsets(
        top: frame.minY - self.frame.minY,
        left: frame.minX - self.frame.minX,
        bottom: self.frame.maxY - frame.maxY,
        right: self.frame.maxX - frame.maxX
      )
    }
  }
  
}
