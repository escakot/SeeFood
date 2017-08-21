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
import TagListView

class AddReviewViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var foodImageView: UIImageView!
  @IBOutlet weak var menuItemTextField: UITextField!
  @IBOutlet weak var foodImageViewHeight: NSLayoutConstraint!
  
  var foodImageView2: UIImageView!
  var menuItemTextField2: UITextField!
  
  var restaurant: Restaurant!
  var menuItem: MenuItem?
  var foodImage: UIImage!
  let clarifaiAPI = "c2b0351a3e40478ca234a70c36fa864f"
  let tagsView = TagStackView()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    if menuItem != nil
    {
      menuItemTextField.text = menuItem!.title
      menuItemTextField.isEnabled = false
    }
    
    foodImageView.isUserInteractionEnabled = false
    setImageViewSize(image: foodImage)
    foodImageView.image = Toucan.Resize.resizeImage(foodImage, size: foodImageView.frame.size)
//    setImageViewSize(image: UIImage(named: "chickenRice.jpg")!)
//    foodImageView.image = Toucan.Resize.resizeImage(UIImage(named:"chickenRice.jpg")!, size: foodImageView.frame.size)
    
    
    let clarifai = ClarifaiApp.init(apiKey: clarifaiAPI)
    let clarifaiImage = ClarifaiImage.init(image: foodImage)!
    clarifai?.getModelByID("bd367be194cf45149e75f01d59f77ba7", completion: { (model, error) in
      if error == nil
      {
        model!.predict(on: [clarifaiImage], completion: { (outputs:[ClarifaiOutput]?, outputError) in
          if outputError == nil
          {
//            print(String(format: "Outputs: %@", outputs![0]))
            let responseData = (outputs![0].responseDict as! [String:AnyObject])["data"] as! [String:AnyObject]
            let possibleItems = responseData["concepts"] as! [[String:AnyObject]]
            for item in possibleItems
            {
              OperationQueue.main.addOperation({ 
                self.createTag(name: item["name"] as! String, predictedTag: true)
              })
            }
          }
        })
      }
    })
    
    
    view.sv([tagsView])
    view.layout(
    foodImageView.frame.maxY + 40,
    |-10-tagsView-10-|,
    10)
    
    view.addSubview(tagsView)
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
  
  func createTag(name:String, predictedTag:Bool)
  {
    let tagLabel = UILabel()
    let font = UIFont.systemFont(ofSize: 10)
    tagLabel.font = font
    tagLabel.text = name
    tagLabel.sizeToFit()
    
    let closeTagButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let closeIcon = UIImage(named: "close-icon.png")!
    closeTagButton.setImage(closeIcon, for: .normal)
//    let horizontalEdge = closeIcon.size.width - 20
//    let verticalEdge = closeIcon.size.height - 20
//    closeTagButton.imageEdgeInsets = UIEdgeInsetsMake(verticalEdge, horizontalEdge, verticalEdge, horizontalEdge)
    closeTagButton.tap { closeTagButton.superview?.removeFromSuperview() }
    
    let stack = UIStackView.init(arrangedSubviews: [tagLabel, closeTagButton])
    stack.isUserInteractionEnabled = true
    stack.spacing = 5
    
    let tagPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panMoveTag))
    stack.addGestureRecognizer(tagPanGesture)
    let stackFrame = CGRect(x: 0, y: 0, width: tagLabel.frame.width + closeTagButton.frame.width + stack.spacing, height: 20)
    let stackView = UIView(frame: CGRect(x: 0, y: 0, width: tagLabel.frame.width + closeTagButton.frame.width + stack.spacing + 10, height: 25))
    stack.insertSubview(stackView, at: 0)
    stack.frame = stackFrame

    stackView.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
    stackView.layer.borderWidth = 1
    stackView.layer.borderColor = UIColor.black.cgColor
    stackView.layer.cornerRadius = 5
    stackView.center = stack.center
    
    tagsView.addArrangedSubview([stack])
  }
  
  func panMoveTag(sender:UIPanGestureRecognizer)
  {
    let translation = sender.translation(in: view)
    sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x,
                                  y: sender.view!.center.y + translation.y)
    sender.setTranslation(CGPoint.zero, in: view)
  }
  
}

class TagStackView: UIView
{
  let padding: CGFloat = 15
  var xStack: CGFloat = 15
  var yStack: CGFloat = 15
  
  func addArrangedSubview(_ views:[UIView])
  {
    let width = self.superview!.frame.width
//    let height = self.frame.height
    
    for view in views
    {
      if xStack + view.frame.width + padding > width
      {
        yStack = yStack + view.frame.height + padding
        xStack = padding
      }
      let viewFrame = CGRect(x: xStack, y: yStack, width: view.frame.width, height: view.frame.height)
      view.frame = viewFrame
      self.addSubview(view)
      
      xStack = xStack + view.frame.width + padding
    }
    
  }
}
