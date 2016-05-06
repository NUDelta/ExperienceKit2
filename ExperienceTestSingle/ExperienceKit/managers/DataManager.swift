//
//  DataManager.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 10/2/15.
//  Copyright © 2015 Scott Cambo. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion
import Parse

/// Sensor types that can be used to specify what kind of data to collect.
/// Each type maps to a class in Parse, see sensorMoment for more detail.
enum Sensor: String {
    case Location = "location",
        Accel = "accel",
        Altitude = "altitude",
        Speed = "speed",
        MotionActivity = "motion_activity"
}

class DataManager : NSObject, CLLocationManagerDelegate {
    
    var experience: Experience?
    var locationManager = CLLocationManager()
    var motionActivityManager = CMMotionActivityManager()
    var sensorMoment: SensorMoment?
    var currentLocation: CLLocation?
    var currentHeading: CLLocationDirection?
    
    init(experience: Experience) {
        super.init()
        
        self.experience = experience
    
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 1 // distance runner must move in meters to call update eventconfi
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingHeading()
    }
    
    // TODO: why is this function running for no reason sometimes..?
//    func recordWorldObject(information: Any?) {
//        print(information)
//        print("  datamanager->recording world object")
//        let worldObject = WorldObject()
//        if let infoDict = information as? [String : String] {
//            worldObject.trigger = infoDict["trigger"]
//            worldObject.label = infoDict["label"]
//            worldObject.MomentBlockSimple = infoDict["MomentBlockSimple"]
//        }
//        worldObject.experience = experience
//        worldObject.location = PFGeoPoint(location: locationManager.location)
//        worldObject.verified = true
//        worldObject.saveInBackground()
//    }
    
    
    func startCollecting(information:Any?){
        self.sensorMoment = SensorMoment()
        self.sensorMoment?.experience = self.experience
        self.sensorMoment?.startDate = NSDate()
        
        if let infoDict = information as? [String : AnyObject],
        sensors = infoDict["sensors"] as? [String],
        MomentBlockSimple = infoDict["MomentBlockSimple"] as? String,
        label = infoDict["label"] as? String {
            self.sensorMoment?.sensors = sensors
            self.sensorMoment?.MomentBlockSimple = MomentBlockSimple
            self.sensorMoment?.label = label
            
            for sensor in sensors {
                switch sensor {
                    // we may not actually check this one because location is always recording
                    //  in case we want to show them their path, etc.
                case Sensor.Location.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.Accel.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.Altitude.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.Speed.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                case Sensor.MotionActivity.rawValue:
                    print(" (DataManager::startCollecting)   recording \(sensor)")
                    
                    if(CMMotionActivityManager.isActivityAvailable()) {
                        self.motionActivityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                            if let data = data {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.saveMotionActivityUpdate(data)
                                }
                            }
                        }
                    }
                    
                default:
                    print(" (DataManager::startCollecting)  data type \(sensor) does not exist")
                }
            }
        }
    }
    
    
    func stopCollecting(){
        print("  stopped recording data")
        self.motionActivityManager.stopActivityUpdates()
        self.sensorMoment?.endDate = NSDate()
        self.sensorMoment?.saveInBackground()
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //this is where DataManager.currentLocation gets updated
        //required for OpportunityManager
        currentLocation = locations[0]
        let locationUpdate = LocationUpdate() //intialise Parse object
        locationUpdate.experience = self.experience
        locationUpdate.location = PFGeoPoint(location: currentLocation)
        locationUpdate.altitude = currentLocation!.altitude
        locationUpdate.speed = currentLocation!.speed
        locationUpdate.horizontalAccuracy = currentLocation!.horizontalAccuracy
        locationUpdate.saveInBackground()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        var h = newHeading.magneticHeading
        let h2 = newHeading.trueHeading // will be -1 if we have no location info
        print("\(h) \(h2) ")
        if h2 >= 0 {
            h = h2
        }
        let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        var dir = "N"
        for (ix, card) in cards.enumerate() {
            if h < 45.0/2.0 + 45.0*Double(ix) {
                dir = card
                break
            }
        }
        //if self.lab.text != dir {
        //    self.lab.text = dir
        //}
        print(dir)
        currentHeading = h
    }
    
    func saveMotionActivityUpdate(data:CMMotionActivity) {
        var activityState = "other"
        if(data.stationary == true) {
            activityState = "stationary"
        } else if (data.walking == true) {
            activityState = "walking"
        } else if (data.running == true) {
            activityState = "running"
        } else if (data.automotive == true) {
            activityState = "automotive"
        } else if (data.cycling == true) {
            activityState = "cycling"
        } else if data.unknown == true {
            activityState = "unknown"
        }
        
        let motionActivityUpdate = MotionActivityUpdate()
        motionActivityUpdate.experience = self.experience
        motionActivityUpdate.location = PFGeoPoint(location: locationManager.location)
        motionActivityUpdate.state = activityState
        motionActivityUpdate.confidence = data.confidence.rawValue
        motionActivityUpdate.saveInBackground()
    }
    

}