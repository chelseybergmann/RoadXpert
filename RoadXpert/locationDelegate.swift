//
//  locationDelegate.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 12/23/20.
//

import CoreLocation

class locationDelegate: NSObject, CLLocationManagerDelegate {
    var last:CLLocation?
    let locationManager = CLLocationManager()
    
    override init() {
        print("hello")
        super.init()
    }
    func processLocation(_ current:CLLocation) {
        guard last != nil else {
            last = current
            return
        }
        var speed = current.speed
        if (speed > 0) {
            print(speed) // or whatever
        } else {
            speed = last!.distance(from: current) / (current.timestamp.timeIntervalSince(last!.timestamp))
            print(speed)
        }
        last = current
    }
    func locationManager(_ manager: CLLocationManager,
                 didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            processLocation(location)
        }
    }
}


