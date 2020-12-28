//
//  Start.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 12/28/20.
//

import Foundation
import UIKit
import Firebase

class Login: UIViewController {
    var handle = Auth.auth()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
          // ...
        } as! Auth

        
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
