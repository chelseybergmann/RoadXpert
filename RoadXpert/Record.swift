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

class Record: UIViewController {
   // Declare a CLLocationManager object at the ViewController level to prevent the instance from being released by system.
    let locationManager = CLLocationManager()
    var motion = CMMotionManager()
    var start: CLLocation?
    var last: CLLocation?
    var totalDistance = 0.0
    var distanceTemp = 0.0
    
    var currData = [Double]()
    var data = [[Double]]()
    var tempArray = [[Double]]()
    
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    
    var speed = 0.0
    var xGyro = 0.0
    var yGyro = 0.0
    var zGyro = 0.0

    var XAccel = 0.0
    var yAccel = 0.0
    var zAccel = 0.0
    
    var xDevi = 0.0
    var yDevi = 0.0
    var zDevi = 0.0
    
    @IBOutlet weak var watchLabel: UILabel!
    var counter = 0.0
    var counterTemp = 0.0
    var timer = Timer()
    
    init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /*
     Ends the trip by stopping all motion and location control.
     */
    @IBAction func endTrip(_ sender: Any) {
        self.locationManager.stopUpdatingLocation()
        self.motion.stopDeviceMotionUpdates()
        self.motion.stopGyroUpdates()
        self.motion.stopAccelerometerUpdates()
        self.timer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true) // 0.1 * 150 (seg lengths) = 1.5 seconds
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
      //locationManager = CLLocationManager()
      // Step 3: initalise and configure CLLocationManager
        
        // Step 4: request authorization
        //locationManager.requestWhenInUseAuthorization()
        // or
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
           
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
      
            myDeviceMotion()
            myGyroscope()
            myAccelerometer()
        }
    }
    
    /*
     Controls timer and data array.
     */
    @objc
    func stopWatch() {
        self.counter += 0.01
        self.counterTemp += 0.01
        self.watchLabel.text = String(format: "%.2f", self.counter)
        
        if (distanceTemp >= 8.05 || self.counterTemp >= 1.5) {
            print("COUNTER TEMP: ")
            print(counterTemp)
            counterTemp = 0.0
            // 8.05m or 1.5 sec for resizing.
            var outputTemp = [[Double](repeating:0.0, count: 3)] //150 x 3 or less than 150 x 3
            if (speed > 0) {
            for i in 0...tempArray.count-1 {
                outputTemp.append(Array(tempArray[i][0..<3]))
            }
        }
            print("OUTPUT TEMP:")
            print(outputTemp)
            print("OUTPUT TEMP COUNT: ")
            print(outputTemp.count)
            // IRI/model prediction here
            // Final output (IRI, latitude, longitude)
            tempArray = [[Double]]()
        }
        if (self.speed >= 0) { // Accurate speed.
            self.currData = [self.speed/25, self.yAccel, self.xGyro, self.latitude, self.longitude]
            tempArray.append(currData)
            data.append(currData)
            print(totalDistance)
            print("CURRENT DATA")
            print(self.currData)
        }
    }
}
    
  // Step 5: Implement the CLLocationManagerDelegate to handle the callback from CLLocationManager
  extension Record: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      switch status {
      case .denied: // Setting option: Never
        print("LocationManager didChangeAuthorization denied")
      case .notDetermined: // Setting option: Ask Next Time
        print("LocationManager didChangeAuthorization notDetermined")
      case .authorizedWhenInUse: // Setting option: While Using the App
        print("LocationManager didChangeAuthorization authorizedWhenInUse")
        
        // Stpe 6: Request a one-time location information
        locationManager.requestLocation()
      case .authorizedAlways: // Setting option: Always
        print("LocationManager didChangeAuthorization authorizedAlways")
        
        // Stpe 6: Request a one-time location information
        locationManager.requestLocation()
      case .restricted: // Restricted by parental control
        print("LocationManager didChangeAuthorization restricted")
      default:
        print("LocationManager didChangeAuthorization")
      }
    }

    // Step 7: Handle the location information
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print("LocationManager didUpdateLocations: numberOfLocation: \(locations.count)")
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      
      locations.forEach { (location) in
        guard last != nil else {
                last = location
                return
        }
        if (start == nil) {
            start = location
        }
        if self.speed >= 0 {
            let velocity_temp = self.speed;
            totalDistance = totalDistance + (velocity_temp/100)
            distanceTemp = distanceTemp + (velocity_temp/100)
            print("TOTAL DISTANCE")
            print(totalDistance)
        }
        last = location
     
        
        print("LocationManager didUpdateLocations: \(dateFormatter.string(from: location.timestamp)); \(location.coordinate.latitude), \(location.coordinate.longitude)")
        self.longitude = location.coordinate.longitude
        self.latitude = location.coordinate.latitude
        
        self.speed = location.speed
        print(String(self.speed) + " CURRENT SPEED")
      }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("LocationManager didFailWithError \(error.localizedDescription)")
      if let error = error as? CLError, error.code == .denied {
         // Location updates are not authorized.
        // To prevent forever looping of `didFailWithError` callback
         locationManager.stopMonitoringSignificantLocationChanges()
         return
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
                print("Device Motion")
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
                print("gyroscope")
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
                print("Accelerometer")
                print(String(self.speed) + " CURRENT SPEED")
                self.XAccel = trueData.acceleration.x
                self.yAccel = trueData.acceleration.y
                self.zAccel = trueData.acceleration.z
            }
        }

        return
    }
    
  }
