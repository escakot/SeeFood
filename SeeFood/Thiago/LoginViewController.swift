//
//  LoginViewController.swift
//  SeeFood
//
//  Created by Thiago Hissa on 2017-08-08.
//  Copyright © 2017 Errol Thiago. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{
    
    //MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var myWebView: UIWebView!
    
    
    
    
    
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
        
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string:"Username",
        attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
        attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.2)])
        
    }
    
    
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        self.myWebView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.performSegue(withIdentifier: "SegueToMain", sender: nil)
        })
    }

   

    

}
