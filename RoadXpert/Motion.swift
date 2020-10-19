//
//  Motion.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 10/17/20.
//

import UIKit
import CoreMotion
import CoreLocation
import MapKit

class Motion: UIViewController , CLLocationManagerDelegate {
    var motion = CMMotionManager()
    let locationManager = CLLocationManager()
    var last: CLLocation?
    var speed = 0.0
    var speeds = [Double]()
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
    var longitude = 0.0
    
    var xGyro = 0.0
    var yGyro = 0.0
    var zGyro = 0.0

    var XAccel = 0.0
    var yAccel = 0.0
    var zAccel = 0.0
    
    var xDevi = 0.0
    var yDevi = 0.0
    var zDevi = 0.0
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.wdwd = [Double]()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    

    // Request location access then get motion data.
    override func viewDidAppear(_ animated: Bool) {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        myDeviceMotion()
        myGyroscope()
        myAccelerometer()
        window()
        
    }
    func window() {
        var array = [self.speed/Double(self.velMax), self.yAccel, self.xGyro, self.latitude, self.longitude]
        
        
        
    }
    
    func processLocation(_ current:CLLocation) {
        guard last != nil else {
                last = current
                return
        }
        var distanceTraveled =  last!.distance(from: current)
      
        self.speed = current.speed
        if (self.speed < 0) {
            self.speed = distanceTraveled / (current.timestamp.timeIntervalSince(last!.timestamp))
            print(self.speed)
        }
        last = current
    }
       
    
    /*
     Manage location.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let trueData: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(trueData.latitude) \(trueData.longitude)")
        self.latitude = trueData.latitude
        self.longitude = trueData.longitude
        
        for location in locations {
            processLocation(location)
    }

    }
    
    /*
     Configure device motion.
     */
    func myDeviceMotion(){
        print("Start DeviceMotion")
        motion.deviceMotionUpdateInterval  = 1.5
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
        motion.gyroUpdateInterval = 1.5
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
        motion.accelerometerUpdateInterval = 1.5
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

