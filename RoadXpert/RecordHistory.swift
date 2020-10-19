//
//  RecordHistory.swift
//  RoadXpert
//  Purpose: Records or shows trip history.
//  Created by Chelsey Bergmann on 10/14/20.
//

import UIKit
import CoreMotion

class RecordHistory: UIViewController {
    let motion = CMMotionManager()
    var timer: Timer!

    
    //var motion = CMMotionManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        view.backgroundColor = UIColor.white
        
        // Create "Start" and "Records" buttons.
        let button1 = UIButton()
        button1.setTitle("Record", for: .normal)
        button1.setTitleColor(UIColor.black, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        button1.frame = CGRect(x: -10, y: 450, width: 150, height: 50)
        button1.addTarget(self, action: #selector(record(_:)), for: .touchUpInside)
        let button2 = UIButton()
        button2.setTitle("Trip History", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        button2.frame = CGRect(x: 170, y: 450, width: 150, height: 50)
        button2.addTarget(self, action: #selector(showHistory(_:)), for: .touchUpInside)
        self.view.addSubview(button1)
        self.view.addSubview(button2)
    }
    
    
    
    /*
     Record the trip.
     */
    @objc func record(_ :UIButton!) {
        calculateIRI()
        
        
        let date = Date() // Get current date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yy"
        let result = formatter.string(from: date)
        
        let calendar = Calendar.current // Get current time.
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let time = String(hour) + ":" + String(minutes)
        
       // Add date and time to history of trips.
       History().addCell(date: result, time: time)
        
    }
    
    /*
     Navigate to trip history.
     */
    @objc func showHistory(_ :UIButton!) {
        let newViewController = TripHistory()
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    /*
        Calculate the IRI and display window.
     */
     
    func calculateIRI() {
        var segpts = 150 // 1.5sec
        var fs = 100 // Sample rate, Hz
        var segLength = 8.05 // meters
        var velMax = 25 // m/s
    }  
}
