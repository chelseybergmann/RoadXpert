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
    let motionControl = Motion() // Control & get motion variables.
    var timer: Timer!
    
    // IRI chart variables.
    var label = UILabel()
    var lineChart: LineChart!
    var data = [[[CGFloat]]]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        view.backgroundColor = UIColor.white
        
        // Create "Start" and "Records" buttons.
        let button1 = UIButton()
        button1.setTitle("Record", for: .normal)
        button1.setTitleColor(UIColor.black, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        button1.frame = CGRect(x: -10, y: 450, width: 150, height: 50)
        button1.addTarget(self, action: #selector(record(button:)), for: .touchUpInside)
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
     Record the trip. Gets motion variables and displays IRI.
     */
    @objc func record(button :UIButton!) {
        if (button.currentTitle == "Record") {
            
            button.setTitle("End Trip", for: .normal)
         
        
            /************IRI VIEW *************/
            motionControl.turnOnMotion() // Being processing motion.
            self.lineChart = motionControl.showIRI() // Display real-time IRI.
            var views: [String: AnyObject] = [:]
            
            label.text = "IRI"
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = NSTextAlignment.center
            self.view.addSubview(label)
            views["label"] = label
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label]", options: [], metrics: nil, views: views))
            
            self.view.addSubview(lineChart)
            views["chart"] = lineChart
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
            /********************************************/
            
            let date = Date() // Get current date
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd.yy"
            let result = formatter.string(from: date)
            
            let calendar = Calendar.current // Get current time.
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let time = String(hour) + ":" + String(minutes)
            
           // Add date and time to history of trips, a singleton.
           History().addCell(date: result, time: time)
            
        // Add to firebase. ****
            
            // End Trip.
        } else {
            motionControl.turnOffMotion()
            data = motionControl.getData()
            print(data)
        }
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
