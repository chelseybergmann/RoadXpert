//
//  Start.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 12/13/20.
//
import UIKit
import Foundation
import CoreMotion
import CoreLocation
import MapKit

class Record: UIViewController, CLLocationManagerDelegate {
    var motionControl = false // Collect motion data while true.
    
    let fc = 10.0 // LPF cutoff freq
    let fch = 0.5 // HPF cut off
    var tempArray = [[Double]]();
    
    var motion = CMMotionManager()
    let locationManager = CLLocationManager()
    var startLocation: CLLocation?
    var last: CLLocation?
    var distanceTraveled = CLLocationDistance() // Between two locations
    var totalDistance = 0.0
    
    var speed = 0.0
    var speeds = [[Double]]()
    var numSegments = 0
    var index1 = [Double]() // Will be size of numSegments.
    var index2 = [Double](repeating: 0.0, count: 150)
    var index3 = [Double](repeating: 0.0, count: 5)
    var wdwd = [Double]()
   
    
    let segpts = 150 // 1.5sec
    let fs = 100 // Sample rate, Hz
    let segLength = 8.05 // meters
    let velMax = 25 // m/s
    
    var latitude = 0.0
    var longitude = CLLocationDegrees()
    
    var xGyro = 0.0
    var yGyro = 0.0
    var zGyro = 0.0

    var XAccel = 0.0
    var yAccel = 0.0
    var zAccel = 0.0
    
    var xDevi = 0.0
    var yDevi = 0.0
    var zDevi = 0.0
    
    // Initialize a (x,150,5) array.
    var data = [[[Double]]]()
    //Initialize a 150,5 inner array.
    var inner = [[Double]](repeating: [0.0], count: 150)// Seg length.
    var size = 0
    var output = [[Double]]()
    
    // Models.
    let model2 = m2()
    let model3 = m3()
    
    // Stop watch.
    var stopwatch = Timer()
    var counter = 0.00
    @IBOutlet weak var watchLabel: UILabel!
    
    //declare blank timer variable
    var timer = Timer()
    @IBOutlet weak var tripHistoryBtn: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        self.wdwd = [Double]()
        tempArray = [[Double]]()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        // Request location.
        if CLLocationManager.locationServicesEnabled() {
            print("Location enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            
        
        stopwatch = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true) // 0.1 * 150 (seg lengths) = 1.5 seconds
       
        // Execute motion.
        myDeviceMotion()
        myGyroscope()
        myAccelerometer()
            
            turnOnMotion()
        /*** Collect trip data *****/
       // while motionControl {
            //timer.fire()
            
            let currData = [(self.speed/Double(self.velMax)),(self.yAccel),(self.xGyro),(self.latitude),(self.longitude)]
            
           print(currData)
           
            // Resize array at 8.05 meters or 1.50 seconds (in timerAction()).
            if (totalDistance.truncatingRemainder(dividingBy: 8.05) == 0) {
               // Add to (150, 5) array.
                if (size < 150) {
                    //var iriInput =
                    inner[size] = currData
                    size += 1
                    
                // Add to (x, 150, 5) data array.
                } else {
                    data.append(inner)
                    inner = [[Double]](repeating: [0.0], count: 150)// Set inner to blank (150, 5).
                    size = 0
                }
            }
       // }
    }
        // Core model.
    
        
    }
        /*
         * Purpose: Return (x, 150, 5) data array.
         */
        func getData() -> [[[Double]]] {
            return data
        }
        /*
         * Purpose: Start collecting trip data.
         */
        func turnOnMotion() {
            motionControl = true;
        }
    
    /*
         * Purpose: Stop collecting trip data.
         */
    @IBAction func turnOffMotion(_ sender: Any) {
        motionControl = false;
        tripHistoryBtn.isHidden = false
        stopwatch.invalidate()
        print("turned off motion")
    }
    
        /*
         * Purpose: Add to data every 0.1 seconds.  When 1.5 seconds is reached, it is added to the (x, 150, 5) array and the window is resized and a new (150, 5) array is generated.
         */
        @objc func timerAction(){
            let currData = [(self.speed/Double(self.velMax)),self.yAccel,self.xGyro, self.latitude, self.longitude]
            
            // Add to (150,5) array.
            if (size < 150) {
                if (totalDistance.truncatingRemainder(dividingBy: 8.05) != 0) { // 1.5 seconds came first.
                    inner[size] = currData
                    size += 1
                }
                
            // Add to (x,150,5) array.
            } else { // 150 data sets - resize array. Append to data. Generate a new (150, 5) array.
                if (totalDistance.truncatingRemainder(dividingBy: 8.05) != 0) {
                    data.append(inner)
                    inner = [[Double]](repeating: [0.0], count: 150)// Set inner to blank (150, 5).
                    size = 0
                }
            }
            
        }
        
        
        /*
         * Purpose: Get current speed.
         * @return a double
         */
        func getSpeed() -> Double {
            return self.speed;
        }
        
        func processLocation(_ current:CLLocation) {
            guard last != nil else {
                    last = current
                    return
            }
            if (startLocation == nil) {
                startLocation = current
            }
     
           distanceTraveled =  last!.distance(from: current)
           totalDistance += distanceTraveled
            self.speed = current.speed
            if (self.speed < 0) {
                self.speed = distanceTraveled / (current.timestamp.timeIntervalSince(last!.timestamp))
                print(self.speed)
            }
          
            last = current
         
            let velocity_temp = self.speed;
            totalDistance = totalDistance + (velocity_temp/100)
            
            let data = [(self.speed)/Double((self.velMax)), (self.yAccel),(self.xGyro),(self.latitude),(self.longitude)]
            tempArray.append(data);
            print(distanceTraveled)
            print(tempArray)
            
         
        }
            
        
        /*
         Manage location.
         */
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let trueData: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(trueData.latitude)\(trueData.longitude)")
            self.latitude = trueData.latitude
            self.longitude = trueData.longitude
          
            for location in locations {
                self.latitude = trueData.latitude
                self.longitude = trueData.longitude
                processLocation(location)
        }

        }
        
        /*
         Configure device motion.
         */
        func myDeviceMotion(){
            print("Start DeviceMotion")
            motion.deviceMotionUpdateInterval  = 0.1
            motion.startDeviceMotionUpdates(to: OperationQueue.current!) {
                (data, error) in
                print(data as Any)
                if let trueData =  data {
                    
                    self.view.reloadInputViews()
                    self.xDevi = trueData.attitude.pitch // Pitch
                    self.yDevi = trueData.attitude.roll // Roll
                    self.zDevi = trueData.attitude.yaw // Yaw
                }
            }
            return
        }

        /*
         Configure the gyroscope.
         */
        func myGyroscope(){
            print("Start Gyroscope")
            motion.gyroUpdateInterval = 0.1
            motion.startGyroUpdates(to: OperationQueue.current!) {
                (data, error) in
                print(data as Any)
                if let trueData =  data {
                    
                    self.view.reloadInputViews()
                    self.xGyro = trueData.rotationRate.x
                    self.yGyro = trueData.rotationRate.y
                    self.zGyro = trueData.rotationRate.z
                }
            }
            return
        }
        
        /*
         Configure the accelerometer.
         */
        func myAccelerometer() {
            print("Start Accelerometer")
            motion.accelerometerUpdateInterval = 0.1
            motion.startAccelerometerUpdates(to: OperationQueue.current!) {
                (data, error) in
                print(data as Any)
                if let trueData =  data {
                    
                    self.view.reloadInputViews()
                    self.XAccel = trueData.acceleration.x
                    self.yAccel = trueData.acceleration.y
                    self.zAccel = trueData.acceleration.z
                }
            }

            return
        }
    
    @objc func updateTimer() {
        counter = counter + 0.01
        watchLabel.text = String(format: "%.2f", counter)
    }
    
    }



