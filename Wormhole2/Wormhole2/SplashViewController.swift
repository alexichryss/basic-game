//
//  SplashViewController.swift
//  Wormhole2
//
//  Created by Alexi Chryssanthou on 5/27/18.
//  Copyright © 2018 Alexi Chryssanthou. All rights reserved.
//

import UIKit
import StoreKit

class SplashViewController: UIViewController {
  
  // MARK: - Properties

  var autoDismiss = false
  
  // MARK: - IBOutlets

    @IBOutlet var tapContinueGesture: UITapGestureRecognizer!
    
  // MARK: - IBActions
  
    @IBAction func tapContinue(_ sender: UITapGestureRecognizer) {
        print("Splash screen tapped.")
        self.dismiss(animated: false, completion: nil)
    }

  // MARK: - Lifecyle
    
  override func viewWillAppear(_ animated: Bool) {
    print("Splash screen will appear.")

    let count = UserDefaults.standard.integer(forKey: "launch_count")
    print("App has been launched \(count) times.", terminator: " ")
    switch count {
    case 0..<5:
        print("Too early for a review.")
    case 5:
        print("Time for a review.")
        SKStoreReviewController.requestReview()
    default:
        print("Already asked for a review.")
    }
  }
  
}
