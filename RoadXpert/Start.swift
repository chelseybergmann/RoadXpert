//
//  Start.swift
//  RoadXpert
//  The start screen.
//  Created by Chelsey Bergmann on 10/14/20.
//

import UIKit

class Start: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor.white
        
        // Create "Start" and "Records" buttons.
        let button1 = UIButton()
        button1.setTitle("Start", for: .normal)
        button1.setTitleColor(UIColor.black, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        button1.frame = CGRect(x: 130, y: 400, width: 70, height: 50)
        button1.addTarget(self, action: #selector(startSession(_:)), for: .touchUpInside)
        let button2 = UIButton()
        button2.setTitle("Records", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        button2.frame = CGRect(x: 130, y: 450, width: 100, height: 50)
        button2.addTarget(self, action: #selector(showHistory(_:)), for: .touchUpInside)
        button1.center.x = self.view.center.x
        button2.center.x = self.view.center.x
        self.view.addSubview(button1)
        self.view.addSubview(button2)
    }
    
    /*
     Navigate to record/history screen.
     */
    @objc func startSession(_ :UIButton!) {
        let newViewController = RecordHistory()
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    /*
     Navigate to history table.
     */
    @objc func showHistory(_ :UIButton!) {
        let newViewController = History()
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}
