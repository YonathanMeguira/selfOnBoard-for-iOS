//
//  ViewController.swift
//  selfOnBoard
//
//  Created by if_found_call_0586288454 on 05/08/5777 AM.
//  Copyright © 5777 AM Yonathan. All rights reserved.
//

import UIKit
import Spring

class ViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var serverLabel: UITextField!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 5
    }
    
    
    @IBAction func login(_ sender: Any) {
        login()
    }
    func userIsLoggedIn() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let testVC = storyBoard.instantiateViewController(withIdentifier: "test1") as! testViewController
        self.present(testVC, animated: true, completion: nil)
    }
    func wrongLogin(){
        loginBtn.setTitle("Wrong user", for: .normal)
        loginBtn.backgroundColor = UIColor.red
        
    }
    
    
    
    func login(){
        
        loginBtn.layer.animation(forKey: "fall")

        loginBtn.loadingIndicator(true)
        let parameters = ["UserName": usernameLabel.text, "Password": passwordLabel.text] as! Dictionary<String, String>
        
        //create the url with URL
        let loginUrl = URL(string: "http://" + serverLabel.text! + ":4580/api/users/login")
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: loginUrl!)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                self.loginBtn.loadingIndicator(false)
                print("error")
                return
            }
            
            guard let data = data else {
                self.loginBtn.loadingIndicator(false)
                print("no data")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        // check for http errors
                        // Back to the main thread: DispatchQueue.main
                        // With this change, our code is both better and worse.
                        // It's better because it no longer blocks the main thread while the JSON downloads from Whitehouse.gov.
                        // It's worse because we're pushing work to the background thread, and any further code called in that work
                        // will also be on the background thread.
                        DispatchQueue.main.async(execute: self.wrongLogin)
                        self.loginBtn.loadingIndicator(false)
                    }else{
                        DispatchQueue.main.async(execute: self.userIsLoggedIn)
                       self.loginBtn.loadingIndicator(false)

                    }
                }
                
            } catch let error {
                print(error.localizedDescription)
                
            }
        })
        task.resume()
    }
    
    
    
    
}

// extensions of any element have to be OUTSIDE of the class other wise error : "statement only valid at file scope"

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            //self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.setTitle("", for: .normal)
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}




