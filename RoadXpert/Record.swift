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
import CoreML
import Firebase
import FirebaseDatabase

class Record: UIViewController, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    var motion = CMMotionManager()
    var start: CLLocation?
    var secondtoLast: CLLocation?
    var last: CLLocation?
    var totalDistance = 0.0
    var distanceTemp = 0.0
    var currLatitude = 0.0
    var currLongitude = 0.0
    var ref: DatabaseReference!
    var date = ""
    
    var currData = [Double]()
    var data = [[[Double]]]()
    var tempArray = [[Double]]()
    var finalOutput = [[Double]]()
    
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
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var watchLabel: UILabel!
    var counter = 0.0
    var counterTemp = 0.0
    var timer = Timer()
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var stack: UIStackView!
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
        
        print("DATE: ")
        print(self.date)
      
        
        print("DATA: ")
        print(data)
        print(data.count)
        if data.count > 0 {
            for i in 0...data.count-1 {
                var latitudes = [Double](repeating: 0.0, count: 150)
                var longitudes = [Double](repeating: 0.0, count: 150)
                for j in 0...data[i].count-1 {
                    latitudes[j] = data[i][j][3]
                    longitudes[j] = data[i][j][4]
                    data[i][j] = Array(data[i][j].dropLast(2))
                }
                var iriInput = data[i]
                let iriOutput = calcIRI(iriInput)[0].doubleValue // Single double value
                let size = Double(latitudes.count)
                let latOut = latitudes.reduce(0, +)/size //lat avg of 150x3
                let longOut = longitudes.reduce(0, +)/size //long avg of 150x3
                
                print("DATA SIZE:")
                    print(data.count)
                print("IRI OUTPUT:")
                print(iriOutput)
              
                finalOutput.append([iriOutput, latOut, longOut])
                
            }
            print("********FINAL OUTPUT********")
            print(finalOutput)
            
            writeToTxtFile()
            let dateSplit = date.split(separator: " ")
            let today = String(dateSplit[0])
            let time = String(dateSplit[1])
            // Send to firebase.
            if let userID = Auth.auth().currentUser?.uid {
                self.ref.child("users").child(userID).child(today).child(time).setValue(["finalOutput": finalOutput,
                                                                                         "Route": map!])
            
            }
           
           
        }
    }
    /*
     Write output to a text file for more storage.
     */
    func writeToTxtFile() {
        let file = "finalOutput.txt" //this is the file. we will write to and read from it

        let text = finalOutput.description //just a text

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(file)

            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {print("Error")}
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true) // 0.1 * 150 (seg lengths) = 1.5 seconds
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
       print("DATE: ")
       let today = Date()
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       print(dateFormatter.string(from: today))
       date = dateFormatter.string(from: today)
    
       
   
        ref = Database.database().reference()
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            map.delegate = self
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
        if (self.speed >= 0) {
        self.speedLabel.text = String(self.speed)
        }
        if (distanceTemp >= 8.05 || self.counterTemp >= 1.5) || (distanceTemp >= 8.05 && self.counterTemp >= 1.5) { //8.05 m or/and 1.5 sec reached.
            print("COUNTER TEMP: ")
            print(counterTemp)
            counterTemp = 0.0
            distanceTemp = 0.0
            
            // 8.05m or 1.5 sec for resizing.
            var innerTemp = [Double](repeating: 0.0, count: 5)
            var outputTemp = [[Double]](repeating: innerTemp, count: 150) //150 x 3 or less than 150 x 3
            if (tempArray.count > 0) {
                for i in 0...tempArray.count-1 {
                        // Speed is accurate for data.
                        print(String(speed) + " SPEED")
                        self.currLatitude = tempArray[i][3]
                        self.currLongitude = tempArray[i][4]
                        outputTemp[i] = Array(tempArray[i]) //outputTemp = IRI input
                }
                data.append(outputTemp)
                
                
                
                //finalOutput.append([currLatitude, currLongitude, iriOutput])
                
                // IRI/model prediction here
                // Final output (IRI, latitude, longitude)
                
            print("OUTPUT TEMP:")
            print(outputTemp)
            print("OUTPUT TEMP COUNT: ")
            print(outputTemp.count)
            tempArray = [[Double]]() // Clear curr data for next use.
            }
            
            
        } else {
        self.currData = [self.speed/25, self.yAccel, self.xGyro, self.latitude, self.longitude]
        print("CURRENT DATA")
        print(self.currData)
        // Constantly add data to the temp array of data until 8.05m or 1.5 sec.
        if (self.speed >= 25) { // Accurate speed.
        
            tempArray.append(currData)
     
            print(totalDistance)
            
        }
        }
    }
    
    func calcIRI(_ input: [[Double]]) -> MLMultiArray {
        do {
            let model: m3 = try m3(configuration: MLModelConfiguration())
            let iriInput = convertToMLArray(input)
            let iriOutput = try model.prediction(input1: iriInput) // Prediction.
            return iriOutput.output1
            //print("IRI OUTPUT: ")
            //print(iriOutput.output1)
            // more code here
        } catch {
            print("ERROR:")
            print(error)
            exit(0)
        }
    }
    
    /*
        Convert x, 150,3 array to a multi array type for Core Model.
     */
    func convertToMLArray(_ input: [[Double]]) -> MLMultiArray {
        let finalData = input.reduce([], +) //result is of type [Double] with x, <= 150, 3 elements
        guard let mlMultiArray = try? MLMultiArray(shape:[1, NSNumber(value: input.count), 3], dataType:MLMultiArrayDataType.int32) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for (index, element) in finalData.enumerated() {
            mlMultiArray[index] = NSNumber(value: element)
        }
        return mlMultiArray
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
                secondtoLast = location
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
      
        secondtoLast = last
        last = location
        let lastCoords = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let coordinates = [CLLocationCoordinate2D(latitude: (secondtoLast?.coordinate.latitude)!, longitude: (secondtoLast?.coordinate.longitude)!),
                           lastCoords]

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
        map.centerCoordinate = lastCoords
        map.region = MKCoordinateRegion(center: lastCoords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        
        print("LocationManager didUpdateLocations: \(dateFormatter.string(from: location.timestamp)); \(location.coordinate.latitude), \(location.coordinate.longitude)")
        self.longitude = location.coordinate.longitude
        self.latitude = location.coordinate.latitude
        let distance = last!.distance(from: secondtoLast!)
        print("Distance: ")
        print(distance)
        print("Time elapsed: ")
    
        //let timeElapsed = (last?.timestamp.timeIntervalSince(secondtoLast!.timestamp))!
      //  print(timeElapsed)
        self.speed = location.speed * 2.23 //distance/timeElapsed //location.speed
        print(" CURRENT SPEED = " + String(self.speed))
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
     Display the user's take route on map in real time.
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
            if let polyline = overlay as? MKPolyline {
                let testlineRenderer = MKPolylineRenderer(polyline: polyline)
                testlineRenderer.strokeColor = .blue
                testlineRenderer.lineWidth = 2.0
                return testlineRenderer
            }
            fatalError("Something wrong...")
            //return MKOverlayRenderer()
        }
    
    /*
     Configure device motion.
     */
    func myDeviceMotion(){
        print("Start DeviceMotion")
        motion.deviceMotionUpdateInterval  = 0.01
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
        motion.gyroUpdateInterval = 0.01
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
        motion.accelerometerUpdateInterval = 0.01
        motion.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            print(data as Any)
            if let trueData =  data {
                self.view.reloadInputViews()
                print("Accelerometer")
                print(String(self.speed) + " CURRENT SPEED")
                self.XAccel = trueData.acceleration.x
                self.yAccel = trueData.acceleration.y + 0.98
                self.zAccel = trueData.acceleration.z
            }
        }

        return
    }
    
  }
