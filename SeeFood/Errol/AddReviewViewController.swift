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
import MLPAutoCompleteTextField
import IQKeyboardManager

class AddReviewViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MLPAutoCompleteTextFieldDataSource {
  
  var foodImageView: UIImageView!
  var menuItemTextField: MLPAutoCompleteTextField!
  var restaurant: Restaurant!
  var foodImage: UIImage!
  let clarifaiAPI = "c2b0351a3e40478ca234a70c36fa864f"
  let tagsView = ArrangedTagView()
  
  var listOfMenuItems: [MenuItem] = []
  var menuItemSuggestions: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    //MenuItemTextField
    menuItemTextField = MLPAutoCompleteTextField()
    menuItemTextField.placeholder = "Menu Item Title"
    menuItemTextField.textAlignment = .center
    menuItemTextField.delegate = self
    menuItemTextField.autoCompleteDataSource = self
    menuItemTextField.maximumNumberOfAutoCompleteRows = 3
    menuItemTextField.autoCompleteTableBackgroundColor = UIColor.init(white: 1.0, alpha: 1.0)
    
    menuItemSuggestions = listOfMenuItems.map({ (menuItem:MenuItem) -> String in
      return menuItem.title
    })
    
    //FoodImageView
    foodImageView = UIImageView()
    foodImageView.contentMode = .scaleAspectFit
    foodImageView.isUserInteractionEnabled = true
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
    
//    let foodTemp = ["chicken", "rice", "vegetables", "cilantro", "chili sauce", "sauce", "plate", "meat"]
//    for food in foodTemp
//    {
//      self.createTag(name: food, predictedTag: true)
//    }
    
    view.sv([foodImageView, menuItemTextField,tagsView])
    view.layout(
      self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height,
      foodImageView.centerHorizontally(),
      menuItemTextField.fillHorizontally() ~ 30,
      10,
      |-10-tagsView-10-|,
      10
    )
    
    // MARK: - Add New Tag Button
    let addTagButton = UIButton(type: .roundedRect)
    addTagButton.setTitle("+ Tag", for: .normal)
    addTagButton.titleLabel!.font = UIFont.systemFont(ofSize: 20)
    addTagButton.addTarget(self, action: #selector(addNewTag), for: .touchUpInside)
    addTagButton.sizeToFit()
    view.sv([addTagButton])
    view.layout(
      addTagButton-15-| ~ 30,
      15
    )
  }
  
  
  // MARK: - Button Methods
  @IBAction func postButton(_ sender: UIBarButtonItem)
  {
    guard !(menuItemTextField.text!.isEmpty) else
    {
      let alert = UIAlertController(title: "Missing Title", message: "Menu item title is required to post", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    let image = foodImageView.image!
    if menuItemSuggestions.contains(menuItemTextField.text!)
    {
      let chosenMenuItemIndex = menuItemSuggestions.index(of: menuItemTextField.text!)!
      let menuItem = listOfMenuItems[chosenMenuItemIndex]
      ParseManager.shared.addReviewFor(menuItem, at: restaurant, image: image, completionHandler: { (savedReview) in
        let createdTags = self.createTagsToParseFor(review: savedReview)
        ParseManager.shared.addTagsFor(savedReview, tags: createdTags, completionHandler: { 
          OperationQueue.main.addOperation({
            self.dismiss(animated: true)
          })
        })
      })
    } else {
      let title = menuItemTextField.text!
      ParseManager.shared.createMenuItemFor(restaurant, title: title, completionHandler: { (savedMenuItem) in
        ParseManager.shared.addReviewFor(savedMenuItem, at: self.restaurant, image: image, completionHandler: { (savedReview) in
          let createdTags = self.createTagsToParseFor(review: savedReview)
          ParseManager.shared.addTagsFor(savedReview, tags: createdTags, completionHandler: {
            OperationQueue.main.addOperation({
              self.dismiss(animated: true)
            })
          })
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
    var newHeight = view.frame.width / ratio
    var newWidth = view.frame.width
    
    if newHeight > view.frame.height/3 * 1.75
    {
      newHeight = view.frame.height/3 * 1.75
      newWidth = newHeight * ratio
    }
    
    foodImageView.frame.size = CGSize(width: newWidth, height: newHeight)
  }
  
  
  // MARK: - Tagging Methods
  
  func createTag(name:String, predictedTag:Bool)
  {
    let tag = TagStackView.init(tagName: name, predicted: predictedTag)
    
    let tagPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panMoveTag))
    tag.addGestureRecognizer(tagPanGesture)
    
    tagsView.addArrangedSubview(tag)
  }
  
  @objc func panMoveTag(sender:UIPanGestureRecognizer)
  {
    let translation = sender.translation(in: view)
    sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x,
                                  y: sender.view!.center.y + translation.y)
    sender.setTranslation(CGPoint.zero, in: view)
    
    if sender.state == .ended
    {
      var frameInView = tagsView.convert(sender.view!.frame, to: self.view)
      if tagsView.subviews.contains(sender.view!)
      {
        if foodImageView.frame.contains(frameInView)
        {
          _ = moveTag(tag: sender.view!, fromView: tagsView, toView: foodImageView)
        } else {
          let oldTag = sender.view! as! TagStackView
          oldTag.center = oldTag.oriCenter
        }
      } else if foodImageView.subviews.contains(sender.view!) {
        frameInView = foodImageView.convert(sender.view!.frame, to: self.view)
        if !foodImageView.frame.contains(frameInView)
        {
          let newTag = moveTag(tag: sender.view!, fromView: foodImageView, toView: tagsView)
          newTag.center = newTag.oriCenter
        }
      }
    }
  }
  
  
  func moveTag(tag:UIView, fromView:UIView, toView:UIView) -> TagStackView
  {
    let frameInView = fromView.convert(tag.frame, to: self.view)
    let frameInImage = view.convert(frameInView, to: foodImageView)
    let oldTag = tag as! TagStackView
    let newTag = TagStackView(tagName: oldTag.tagLabel.text!, predicted: oldTag.isPredicted)
    newTag.frame = frameInImage
    newTag.oriCenter = oldTag.oriCenter
    newTag.oriOrigin = oldTag.oriOrigin
    let tagPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panMoveTag))
    newTag.addGestureRecognizer(tagPanGesture)
    if toView is ArrangedTagView
    {
      oldTag.removeFromSuperview()
      (toView as! ArrangedTagView).addArrangedSubview(newTag)
    } else {
      (fromView as! ArrangedTagView).deleteArrangeSubview(oldTag)
      toView.addSubview(newTag)
    }
    return newTag
  }
  
  @objc func addNewTag()
  {
    self.tagsView.isInitialLoad = false
    let textFieldAlert = UIAlertController(title: "New Tag", message: "" , preferredStyle: .alert)
    textFieldAlert.addTextField { (textField) in
      textField.placeholder = "tag name"
      textField.textAlignment = .center
    }
    textFieldAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    textFieldAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
      guard let tagString = textFieldAlert.textFields!.first!.text, tagString != "" else { return }
      self.createTag(name: tagString.lowercased(), predictedTag: false)
    }))
    present(textFieldAlert, animated: true, completion: nil)
  }
  
  func createTagsToParseFor(review:Review) -> [Tag]
  {
    let tags = foodImageView.subviews as! [TagStackView]
    let imageSize = foodImageView.image!.size
    var tempTags: [Tag] = []
    for tag in tags
    {
      let percentCentX = tag.center.x/imageSize.width
      let percentCentY = tag.center.y/imageSize.height
      let newTag = Tag.init(title: tag.tagLabel.text!, centerX: percentCentX, centerY: percentCentY, review: review)
      tempTags.append(newTag)
    }
    
    return tempTags
  }
  
  // MARK: - Autocomplete MenuItem Textfield
  func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, possibleCompletionsFor string: String!, completionHandler handler: (([Any]?) -> Void)!)
  {
    handler(menuItemSuggestions)
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    IQKeyboardManager.shared().keyboardDistanceFromTextField = 110
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    IQKeyboardManager.shared().keyboardDistanceFromTextField = kIQUseDefaultKeyboardDistance
  }
}
// MARK: - Tag Classes

class TagStackView: UIStackView
{
  var tagLabel: UILabel!
  var tagCloseButton: UIButton!
  var backgroundView: UIView!
  var isPredicted = false
  var oriCenter = CGPoint.zero
  var oriOrigin = CGPoint.zero
  
  convenience init(tagName:String, predicted:Bool) {
    let tempTagLabel = UILabel()
    let tempCloseTagButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    self.init(arrangedSubviews: [tempTagLabel, tempCloseTagButton])
    
    let font = UIFont.systemFont(ofSize: 15)
    tempTagLabel.font = font
    tempTagLabel.text = tagName
    tempTagLabel.sizeToFit()
    
    let closeIcon = UIImage(named: "close-icon.png")!
    tempCloseTagButton.setImage(closeIcon, for: .normal)
    tempCloseTagButton.tap {
      if let tagSuperView = self.superview as? ArrangedTagView
      {
        tagSuperView.deleteArrangeSubview(self)
      } else {
        self.removeFromSuperview()
      }
    }
    
    self.isUserInteractionEnabled = true
    self.spacing = 5
    
    let stackFrame = CGRect(x: 0, y: 0, width: tempTagLabel.frame.width + tempCloseTagButton.frame.width + self.spacing, height: 20)
    let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: tempTagLabel.frame.width + tempCloseTagButton.frame.width + self.spacing + 10, height: 25))
    self.insertSubview(backgroundView, at: 0)
    self.frame = stackFrame

    backgroundView.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
    backgroundView.layer.borderWidth = 1
    backgroundView.layer.borderColor = UIColor.black.cgColor
    backgroundView.layer.cornerRadius = 5
    backgroundView.center = self.center
    
    isPredicted = predicted
    oriCenter = self.center
    tagLabel = tempTagLabel
    tagCloseButton = tempCloseTagButton
  }
}

class ArrangedTagView: UIView
{
  let padding: CGFloat = 20
  var xStack: CGFloat = 15
  var yStack: CGFloat = 15
  var screenWidth:CGFloat = 414
  var isInitialLoad = true
  
  func addArrangedSubview(_ view:TagStackView)
  {
//    let height = self.frame.height
    screenWidth = self.superview!.frame.width
    
    if xStack + view.frame.width + padding > screenWidth
    {
      yStack = yStack + view.frame.height + padding
      xStack = padding
    }
    if ((yStack + ((view.frame.height + padding) * 2) > self.frame.height) && isInitialLoad)
    {
      return
    }
    
    let viewFrame = CGRect(x: xStack, y: yStack, width: view.frame.width, height: view.frame.height)
    view.frame = viewFrame
    view.oriCenter = view.center
    view.oriOrigin = view.frame.origin
    self.addSubview(view)
    
    xStack = xStack + view.frame.width + padding
  }
  
  func deleteArrangeSubview(_ view:TagStackView)
  {
    guard subviews.contains(view) else { return }
    let viewIndex = subviews.index(of: view)!
    
    xStack = view.oriOrigin.x
    yStack = view.oriOrigin.y
    
    view.removeFromSuperview()
    
    for (index, subview) in subviews.enumerated()
    {
      guard index >= viewIndex else { continue }
      if xStack + subview.frame.width + padding > screenWidth
      {
        yStack = yStack + view.frame.height + padding
        xStack = padding
      }
      let tagView = subview as! TagStackView
      tagView.frame.origin.x = xStack
      tagView.frame.origin.y = yStack
      tagView.oriCenter = tagView.center
      tagView.oriOrigin = tagView.frame.origin
      xStack = xStack + subview.frame.width + padding
    }
  }
}
