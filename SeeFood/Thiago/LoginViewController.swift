//
//  LoginViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-08.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit
import Stevia

class LoginViewController: UIViewController{
  
  //MARK: Properties
  
  @IBOutlet weak var usernameTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var loginButton: UIButton!
  
  @IBOutlet weak var myWebView: UIWebView!
  
  let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
  var resetPasswordView: UIView!
  var resetUsernameTextField: UITextField!
  var resetEmailTextField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //MARK: Background Animation
    
    let htmlPath = Bundle.main.path(forResource: "WebViewContent", ofType: "html")
    let htmlURL = URL(fileURLWithPath: htmlPath!)
    let html = try? Data(contentsOf: htmlURL)
    
    self.myWebView.load(html!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: htmlURL.deletingLastPathComponent())
    self.myWebView.isHidden = true
    
    
    //MARK: Styles
    loginButton.layer.cornerRadius = 20
    
    let border1 = CALayer()
    let border2 = CALayer()
    border1.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
    border1.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - 2.0, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
    
    border2.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
    border2.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - 2.0, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
    
    border1.borderWidth = 0.7
    border2.borderWidth = 0.7
    usernameTextField.layer.addSublayer(border1)
    usernameTextField.layer.masksToBounds = true
    passwordTextField.layer.addSublayer(border2)
    passwordTextField.layer.masksToBounds = true
   usernameTextField.layer.cornerRadius = 5
   passwordTextField.layer.cornerRadius = 5
    
    
    usernameTextField.attributedPlaceholder = NSAttributedString(string:"Username",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
    passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
    
    //Setup AlertController Action
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
    
    //Setup Reset Password View
    resetPasswordView = UIView()
    resetPasswordView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
    resetPasswordView.layer.cornerRadius = 10.0
    let resetLabel = UILabel()
    resetLabel.text = "Reset password using:"
    resetLabel.textAlignment = .center
    let orLabel = UILabel()
    orLabel.text = "OR"
    orLabel.textAlignment = .center
    resetUsernameTextField = UITextField()
    resetUsernameTextField.style(resetStyle)
    resetUsernameTextField.placeholder = "username"
    resetEmailTextField = UITextField()
    resetEmailTextField.style(resetStyle)
    resetEmailTextField.placeholder = "email"
    let recoverButton = UIButton()
    recoverButton.setTitle("Recover Password", for: .normal)
    recoverButton.addTarget(self, action: #selector(submitPasswordRecovery), for: .touchUpInside)
    
    let containerView = UIView()
    
    resetPasswordView.sv([containerView.sv([resetLabel,orLabel,resetUsernameTextField,resetEmailTextField, recoverButton])])
    
    containerView.layout(
      5,
      |-resetLabel-| ~ 20,
      10,
      |-resetUsernameTextField-| ~ 30,
      5,
      |-orLabel-| ~ 20,
      5,
      |-resetEmailTextField-| ~ 30,
      5,
      recoverButton.centerHorizontally(),
      0
    )
    resetPasswordView.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 180)
    resetPasswordView.center = view.center
    resetPasswordView.layout(
      containerView.centerHorizontally().centerVertically()
    )
    resetPasswordView.alpha = 0
  }
  
  func resetStyle(f:UITextField)
  {
    f.borderStyle = .roundedRect
    f.autocapitalizationType = .none
    f.backgroundColor = .white
    f.layer.cornerRadius = 5.0
    f.layer.borderWidth = 1.0
    f.layer.borderColor = UIColor.black.cgColor
    f.textAlignment = .center
  }
  
  
  
  @IBAction func loginButton(_ sender: UIButton) {
   self.myWebView.isHidden = false
    ParseManager.shared.userLogin(username: usernameTextField.text!, password: passwordTextField.text!) { (message:String?) in
      guard let message = message else {
        self.dismiss(animated: true, completion: nil)
        return
      }
      self.myWebView.isHidden = true
      self.alertController.title = "Login Error"
      self.alertController.message = message
      self.present(self.alertController, animated: true, completion: nil)
    }
  }
  
  @IBAction func resetPasswordButton(_ sender: UIButton)
  {
    guard !view.subviews.contains(resetPasswordView) else
    {
      return
    }
    view.addSubview(resetPasswordView)
    UIView.animate(withDuration: 0.6) {
      self.resetPasswordView.alpha = 1.0
    }
  }
  
  func submitPasswordRecovery()
  {
    guard !resetUsernameTextField.text!.isEmpty || !resetEmailTextField.text!.isEmpty else {
      self.myWebView.isHidden = true
      self.alertController.message = "Username and email cannot be empty for password recovery."
      present(alertController, animated: true, completion: nil)
      return
    }
//    ParseManager.shared.userResetPassword(username: resetUsernameTextField.text!, email: resetEmailTextField.text!) { (errorMessage) in
//      self.alertController.title = "Password Recovery"
//      if errorMessage != nil
//      {
        self.alertController.message = "Please check your email for password recovery."
//      } else {
//        self.alertController.message = errorMessage
//      }
//      OperationQueue.main.addOperation({
        self.present(self.alertController, animated: true, completion: nil)
//      })
//    }
    UIView.animate(withDuration: 0.6, animations: {
      self.resetPasswordView.alpha = 0
    }) { (success) in
      self.resetPasswordView.removeFromSuperview()
      self.resetUsernameTextField.text = ""
      self.resetEmailTextField.text = ""
    }
  }
}
