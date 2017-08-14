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
  @IBOutlet weak var menuItemTextField: UITextField!
  @IBOutlet weak var foodImageViewHeight: NSLayoutConstraint!
  
  var restaurant: Restaurant!
  var menuItem: MenuItem?
  var foodImage: UIImage!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Temporary Setup
    //    ParseManager.shared.userSignUp(username: "errol", password: "errol") { (string) in
    ParseManager.shared.userLogin(username: "errol", password: "errol") { (success: Bool) in
      if success
      {
        print("Login Successful")
      } else {
        print("Login Failed")
      }
    }
    //    }
    
    //    ParseManager.shared.createRestaurantProfileWith(name: "Anoush", coordinates: PFGeoPoint(latitude: 0.0, longitude: 0.0)) { (success) in
    //      if success
    //      {
    ParseManager.shared.queryRestaurantWith(name: "Anoush", coordinates: PFGeoPoint(latitude: 0.0, longitude: 0.0)) { (restaurant) in
      guard restaurant != nil else {
        print("Error query restaurant")
        return
      }
      self.restaurant = restaurant
      print("Restaurant: \(restaurant!.name)")
    }
    //      }
    //    }
    
    // Do any additional setup after loading the view.
    if menuItem != nil
    {
      menuItemTextField.text = menuItem!.title
      menuItemTextField.isEnabled = false
    }
    
    //    foodImageView.image = foodImage
    //    foodImageView.image = UIImage(named: "chickenRice.jpg")
    //    setImageViewSize(image: UIImage(named: "chickenRice.jpg")!)
    setImageViewSize(image: UIImage(named: "beef-stirfry.jpg")!)
    foodImageView.image = UIImage(named: "beef-stirfry.jpg")
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
  
  func setImageViewSize(image:UIImage)
  {
    let ratio = image.size.width/image.size.height
    let newHeight = view.frame.width / ratio
    foodImageViewHeight.constant = newHeight
    foodImageView.frame.size = CGSize(width: view.frame.width, height: newHeight)
  }
}
