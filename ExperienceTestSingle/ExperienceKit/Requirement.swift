//
//  Requirement.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 12/8/15.
//  Copyright © 2015 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import Foundation
import CoreLocation

enum Condition {
    case MinSpeed, MaxSpeed, TimeElapsed, TimeRemaining, InRegion
    // time elapsed and remaining refer to experience time, not real time (which would include pauses, etc.)
}

class Requirement : NSObject {
    var canInsertImmediately: Bool? = false
    var conditions: [Condition]
    var speed: CLLocationSpeed?
    var seconds: NSTimeInterval?
    var region: CLCircularRegion?
    
    init(conditions:[Condition], speed:CLLocationSpeed?=nil, seconds:NSTimeInterval?=nil, region:CLCircularRegion?=nil, canInsertImmediately:Bool?=false) {
        self.conditions = conditions
        self.speed = speed
        self.seconds = seconds
        self.region = region
        
        self.canInsertImmediately = canInsertImmediately
    }
    
    // TODO ensure every condition has a matching value, otherwise crash
    
    
}