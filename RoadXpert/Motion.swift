import UIKit
import CoreMotion
import CoreLocation
import MapKit

class Motion: UIViewController , CLLocationManagerDelegate {
    var motionControl = false // Collect motion data while true.
    
    let fc = 10.0 // LPF cutoff freq
    let fch = 0.5 // HPF cut off
    var tempArray = [[CGFloat]]();
    
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
    
    var latitude = CLLocationDegrees()
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
    var data = [[[CGFloat]]]()
    //Initialize a 150,5 inner array.
    var inner = [[CGFloat]](repeating: [0.0], count: 150)// Seg length.
    var size = 0
    
    //declare blank timer variable
    var timer = Timer()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.wdwd = [Double]()
        tempArray = [[CGFloat]]();
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        // Request location.
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true) // 0.1 * 150 (seg lengths) = 1.5 seconds
       
        
        /*** Collect trip data *****/
        while motionControl {
            timer.fire()
            
            let currData = [CGFloat(self.speed)/CGFloat(self.velMax),CGFloat(self.yAccel),CGFloat(self.xGyro),CGFloat(self.latitude),CGFloat(self.longitude)]
            
            // Execute motion.
            myDeviceMotion()
            myGyroscope()
            myAccelerometer()
            
            // Resize array at 8.05 meters or 1.50 seconds (in timerAction()).
            if (totalDistance.truncatingRemainder(dividingBy: 8.05) == 0) {
               // Add to (150, 5) array.
                if (size < 150) {
                    inner[size] = currData
                    size += 1
                    
                // Add to (x, 150, 5) data array.
                } else {
                    data.append(inner)
                    inner = [[CGFloat]](repeating: [0.0], count: 150)// Set inner to blank (150, 5).
                    size = 0
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /*
     * Purpose: Return (x, 150, 5) data array.
     */
    func getData() -> [[[CGFloat]]] {
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
    func turnOffMotion() {
        motionControl = false;
    }
    
    /*
     * Purpose: Add to data every 0.1 seconds.  When 1.5 seconds is reached, it is added to the (x, 150, 5) array and the window is resized and a new (150, 5) array is generated.
     */
    @objc func timerAction(){
        let currData = [CGFloat(self.speed)/CGFloat(self.velMax),CGFloat(self.yAccel),CGFloat(self.xGyro),CGFloat(self.latitude),CGFloat(self.longitude)]
        
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
                inner = [[CGFloat]](repeating: [0.0], count: 150)// Set inner to blank (150, 5).
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
        
        let data = [CGFloat(self.speed)/CGFloat(self.velMax),CGFloat(self.yAccel),CGFloat(self.xGyro),CGFloat(self.latitude),CGFloat(self.longitude)]
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

