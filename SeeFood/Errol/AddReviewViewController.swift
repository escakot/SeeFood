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
  
  @IBAction func postButton(_ sender: UIBarButtonItem)
  {
    guard let currentUser = PFUser.current() else {
      dismiss(animated: true)
      return
    }
    if menuItem == nil
    {
      guard var priceString = priceTextField.text else {
        return
      }
      priceString.remove(at: priceString.startIndex)
      guard let value = Float(priceString) else {
        return
      }
      menuItem = MenuItem(restaurant: restaurant, title: menuItemTextField.text!, comment: commentTextView.text, price: value)
      menuItem!.saveInBackground(block: { (bool, error) in
        if error != nil {
          print(error!.localizedDescription)
          return
        }
        let imageData = UIImagePNGRepresentation(self.foodImageView.image!)
        guard let pfImage = PFFile(name: "image.png", data: imageData!) else
        {
          return
        }
        let review = Review(user: currentUser, image: pfImage, comment: self.commentTextView.text, rating: self.rating, menuItem: self.menuItem!, restaurant: self.restaurant)
        review.saveInBackground()
      })
    } else {
        let imageData = UIImagePNGRepresentation(self.foodImageView.image!)
        guard let pfImage = PFFile(name: "image.png", data: imageData!) else
        {
          return
        }
        let review = Review(user: currentUser, image: pfImage, comment: self.commentTextView.text, rating: self.rating, menuItem: self.menuItem!, restaurant: self.restaurant)
        review.saveInBackground()
    }
    print("saved")
//    dismiss(animated: true)
  }
  @IBAction func cancelButton(_ sender: UIBarButtonItem)
  {
//    dismiss(animated: true)
  }
  
  
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
}
