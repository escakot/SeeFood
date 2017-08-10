//
//  AddReviewViewController.swift
//  SeeFood
//
//  Created by Errol Cheong on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Parse

class AddReviewViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var foodImageView: UIImageView!
  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet weak var menuItemTextField: UITextField!
  @IBOutlet weak var star1ImageView: UIImageView!
  @IBOutlet weak var star2ImageView: UIImageView!
  @IBOutlet weak var star3ImageView: UIImageView!
  @IBOutlet weak var star4ImageView: UIImageView!
  @IBOutlet weak var star5ImageView: UIImageView!
  @IBOutlet weak var ratingStack: UIStackView!
  @IBOutlet weak var priceTextField: UITextField!
  
  var rating = 0
  var restaurant: Restaurant!
  var menuItem: MenuItem?
  var foodImage: UIImage!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    //Temporary Setup
    ParseManager.shared.userLogin(username: "usernameErrol", password: "errol12345") { (success: Bool) in
      if !success
      {
        return
      }
    }
    
    // Do any additional setup after loading the view.
    ratingStack.isUserInteractionEnabled =  true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRatingTap(sender:)))
    ratingStack.addGestureRecognizer(tapGesture)
    
    if menuItem != nil
    {
      menuItemTextField.text = menuItem!.title
      menuItemTextField.isEnabled = false
    }
    
//    foodImageView.image = foodImage
    foodImageView.image = UIImage(named: "chickenRice.JPG")
    priceTextField.delegate = self
  }
  
  
  // MARK: - Button Methods
  @IBAction func postButton(_ sender: UIBarButtonItem)
  {
    guard PFUser.current() == nil else {
      dismiss(animated: true)
      return
    }
    let image = foodImageView.image!
    let comment = commentTextView.text
    if let menuItem = menuItem
    {
      ParseManager.shared.addReviewFor(menuItem, at: restaurant, image: image, comment:comment, rating: rating, completionHandler: { 
      })
    } else {
      let title = menuItemTextField.text!
      let price = getPriceFloat()
      let coordinates = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
      ParseManager.shared.createMenuItemFor(restaurant, title: title, price: price, coordinates: coordinates, completionHandler: { (savedMenuItem) in
        ParseManager.shared.addReviewFor(savedMenuItem, at: self.restaurant, image: image, comment:comment, rating: self.rating, completionHandler: {
        })
      })
    }
    print("saved")
//    dismiss(animated: true)
  }
  @IBAction func cancelButton(_ sender: UIBarButtonItem)
  {
//    dismiss(animated: true)
  }
  
  
  // MARK: - Gesture Recognizer Methods
  func handleRatingTap(sender:UITapGestureRecognizer)
  {
    let location = sender.location(in: ratingStack)
    if star1ImageView.frame.contains(location)
    {
      rating = rating == 1 ? 0 : 1
    }
    if star2ImageView.frame.contains(location)
    {
      rating = rating == 2 ? 0 : 2
    }
    if star3ImageView.frame.contains(location)
    {
      rating = rating == 3 ? 0 : 3
    }
    if star4ImageView.frame.contains(location)
    {
      rating = rating == 4 ? 0 : 4
    }
    if star5ImageView.frame.contains(location)
    {
      rating = rating == 5 ? 0 : 5
    }
    updateRating()
  }
  
  
  func updateRating()
  {
    star1ImageView.image = rating >= 1 ? UIImage(named: "Star-Filled") : UIImage(named:"Star")
    star2ImageView.image = rating >= 2 ? UIImage(named: "Star-Filled") : UIImage(named:"Star")
    star3ImageView.image = rating >= 3 ? UIImage(named: "Star-Filled") : UIImage(named:"Star")
    star4ImageView.image = rating >= 4 ? UIImage(named: "Star-Filled") : UIImage(named:"Star")
    star5ImageView.image = rating >= 5 ? UIImage(named: "Star-Filled") : UIImage(named:"Star")
  }
  
  // MARK: - UITextField Delegate
  func textFieldDidBeginEditing(_ textField: UITextField)
  {
    textField.text = ""
  }
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    guard textField.text != "" else {
      return
    }
    guard let value = Float(textField.text!) else {
      textField.text = ""
      return
    }
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    textField.text = formatter.string(from: NSNumber(value: value))
  }
  
  func getPriceFloat() -> Float
  {
    var priceString = priceTextField.text!
    guard priceString != "", priceString[priceString.startIndex] == "$" else
    {
      return 0.0
    }
    priceString.remove(at: priceString.startIndex)
    return Float(priceString)!
  }
}
