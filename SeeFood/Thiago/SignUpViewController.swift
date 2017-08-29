//
//  SignUpViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-09.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Stevia

class SignUpViewController: UIViewController {
   
   //MARK: Properties
   
   @IBOutlet weak var myWebView: UIWebView!
   
   @IBOutlet weak var usernameTextField: UITextField!
   
   @IBOutlet weak var emailTextField: UITextField!
   
   @IBOutlet weak var passwordTextField: UITextField!
   
   @IBOutlet weak var signupButton: UIButton!
   
   
   let alertController = UIAlertController(title: "Sign Up Error", message: "", preferredStyle: UIAlertControllerStyle.alert)
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      //MARK: Background Animation
      
      let htmlPath = Bundle.main.path(forResource: "WebViewContent", ofType: "html")
      let htmlURL = URL(fileURLWithPath: htmlPath!)
      let html = try? Data(contentsOf: htmlURL)
      
      self.myWebView.load(html!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: htmlURL.deletingLastPathComponent())
      self.myWebView.isHidden = true
      
      //MARK: Styles
      signupButton.layer.cornerRadius = 20
      
      let border1 = CALayer()
      let border2 = CALayer()
      let border3 = CALayer()
      border1.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
      border1.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - 2.0, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
      
      border2.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
      border2.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - 2.0, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
      
      border3.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
      border3.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - 2.0, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
      
      
      border1.borderWidth = 0.7
      border2.borderWidth = 0.7
      border3.borderWidth = 0.7
      
      usernameTextField.layer.addSublayer(border1)
      usernameTextField.layer.masksToBounds = true
      passwordTextField.layer.addSublayer(border2)
      passwordTextField.layer.masksToBounds = true
      emailTextField.layer.masksToBounds = true
      emailTextField.layer.addSublayer(border3)
      usernameTextField.layer.cornerRadius = 5
      passwordTextField.layer.cornerRadius = 5
      emailTextField.layer.cornerRadius = 5
      
      
      usernameTextField.attributedPlaceholder = NSAttributedString(string:"Username",
                                                                   attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
      passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                   attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
      emailTextField.attributedPlaceholder = NSAttributedString(string:"Email",
                                                                   attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
      //UIAlertController Button
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
    
      //Dismiss Controller
      let dismissLoginButton = UIButton()
      dismissLoginButton.setImage(UIImage(named:"x-icon.png"), for: .normal)
      dismissLoginButton.sizeToFit()
      dismissLoginButton.tap { self.dismiss(animated: true, completion: nil) }
      view.sv(dismissLoginButton)
      view.layout(
        UIApplication.shared.statusBarFrame.height + 10,
        dismissLoginButton.width(30)-12-| ~ 30
      )
   }
   
   
   
   
   //MARK: IBActions
   @IBAction func signupButton(_ sender: UIButton) {
      self.myWebView.isHidden = false
      if (usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! || (emailTextField.text?.isEmpty)! {
         print("Error: Empty textfields")
      }
      else {
         ParseManager.shared.userSignUp(username: usernameTextField.text!, password: passwordTextField.text!, email: emailTextField.text!) { (result:String?) in
            guard let result = result else
            {
               OperationQueue.main.addOperation({
                  self.performSegue(withIdentifier: "unwindSegueToMain", sender: nil)
               })
               return
            }
            self.alertController.message = result
            self.myWebView.isHidden = true
            OperationQueue.main.addOperation({
               self.present(self.alertController, animated: true, completion: nil)
            })
         }
      }
      
      //        self.myWebView.isHidden = false
      //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
      //            self.performSegue(withIdentifier: "SegueToMain", sender: nil)
      //        })
   }
   
   
   @IBAction func loginButtonDismissView(_ sender: UIButton) {
      dismiss(animated: true, completion: nil)
   }
   
   
   
   
}
