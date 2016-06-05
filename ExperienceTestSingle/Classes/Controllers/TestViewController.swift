//
//  TestViewController.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 4/17/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import MediaPlayer
import CoreLocation
import Parse

class TestViewController: UIViewController, MKMapViewDelegate, ExperienceManagerDelegate, DataManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
    var missionTitle: String = "Intel Mission"
    var experienceManager:ExperienceManager!
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    

    @IBAction func triggeredControlButton(sender: UIButton) {
        print("triggered!")
        self.experienceManager.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("test controller")
        
        experienceManager = ExperienceManager(title: missionTitle, momentBlocks: [])
        
        ///////////////////////////////////////////////////
        //[TEST CONDITIONS]
        ///////////////////////////////////////////////////
        if (true)
        {
            /////////////////////////////////////////////
            //[ TEST SCAFFOLDING: INPUT POSSIBILITIES ]
            /////////////////////////////////////////////
            var scaffoldingManager = ScaffoldingManager(
                experienceManager: experienceManager)
            
            let momentblock_hydrant = MomentBlockSimple(moments: [
                //instruction
                SynthVoiceMoment(content: "there is a a fire hydrant 3 meters ahead"),
                ], title: "scaffold_fire_hydrant",
                   requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                    objectLabel: "fire_hydrant"))
            let momentblock_tree = MomentBlockSimple(moments: [
                //instruction
                SynthVoiceMoment(content: "there is a a tree within 3 second walking distance. if you feel comfortable, walk to it and stand for 10 seconds. if you would rather not, continue your path"),
                //wait for person to make decisive action
                Interim(lengthInSeconds: 2),
                //branch: stationary, then push location, if not
                ConditionalMoment(
                    momentBlock_true: MomentBlockSimple(
                        moments: [SynthVoiceMoment(content: "detected stop - tree recorded")],
                        title: "detected:true"
                    ),
                    momentBlock_false: MomentBlockSimple(
                        moments: [SynthVoiceMoment(content: "you're moving - no tree I see")],
                        title: "detected:false"
                    ),
                    conditionFunc: {() -> Bool in
                        if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                            //true condition: user is stationary
                            where speed <= 1.2 {
                            let curEvaluatingObject = scaffoldingManager.curPulledObject!
                            self.experienceManager.dataManager?.updateWorldObject(curEvaluatingObject, information: [], validated: true)
                            return true
                        }
                        //false condition: user keeps moving
                        let curEvaluatingObject = scaffoldingManager.curPulledObject!
                        self.experienceManager.dataManager?.updateWorldObject(curEvaluatingObject, information: [], validated: false)
                        return false
                }),
                SynthVoiceMoment(content: "good job - now move on"),
                ], title: "scaffold_tree",
                   requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                    objectLabel: "tree"))
            
            
            //[scaffolding: variation]
            let momentblock_tree_var0 = MomentBlockSimple(moments: [
                //instruction
                SynthVoiceMoment(content: "there is a a tree 3 meters ahead. does it have green leaves?"),
                ConditionalMoment(
                    momentBlock_true: MomentBlockSimple(
                        moments: [
                            SynthVoiceMoment(content: "detected stop - green leaves recorded"),
                            SynthVoiceMoment(content: "this is a great find")
                        ],
                        title: "detected:true"
                    ),
                    momentBlock_false: MomentBlockSimple(
                        moments: [
                            SynthVoiceMoment(content: "you're moving - no green leaves I see"),
                            SynthVoiceMoment(content: "we have noted the absence")
                        ],
                        title: "detected:false"
                    ),
                    conditionFunc: {() -> Bool in
                        if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                            //true condition: user is stationary
                            where speed <= 1.2 {
                            self.experienceManager.dataManager?.pushWorldObject(["label": "tree_leaves_green", "interaction" : "scaffold_tree_leaves_green", "variation" : "1"])
                            return true
                        }
                        //false condition: user keeps moving
                        self.experienceManager.dataManager?.pushWorldObject(["label": "tree_leaves_green(false)", "interaction" : "scaffold_tree_leaves_green", "variation" : "1"])
                        return false
                }),
                SynthVoiceMoment(content: "good job - now move on"),
                ], title: "scaffold_tree_var0",
                   requirement: Requirement(conditions:[Condition.InRegion, Condition.ExistsObject],
                    objectLabel: "tree", variationNumber: 0))
            
            scaffoldingManager.insertableMomentBlocks = [momentblock_hydrant, momentblock_tree, momentblock_tree_var0]
            
            //////////////////////
            //[ TEST EXPERIENCE ]
            ///////////////////////
            let MomentBlock_test = MomentBlock(moments: [
                //instruction
                SynthVoiceMoment(content: "let's start the game"),
                //moment that waits 5 seconds (added to give location a chance to update)
                Interim(lengthInSeconds: 2),
                //moment that collects sensor data
                SensorCollector(lengthInSeconds: 5, dataLabel: "collector_for_cond", sensors: [.Location, .Speed, .MotionActivity]),
                //instruction
                SynthVoiceMoment(content: "we are going to check opportunities for 10 seconds"),
                //keep pulling opportunities
                OpportunityPoller(objectFilters:["label": "tree"], lengthInSeconds: 10.0, pollEveryXSeconds: 2.0, scaffoldingManager: scaffoldingManager),
                //instruction
                SynthVoiceMoment(content: "we sense a fire hydrant in the area. remain if true, move if false"),
                //branch: stationary, then push location, if not
                ConditionalMoment(
                    momentBlock_true: MomentBlockSimple(
                        moments: [SynthVoiceMoment(content: "you're stationary - hydrant recorded")],
                        title: "detected:true"
                    ),
                    momentBlock_false: MomentBlockSimple(
                        moments: [SynthVoiceMoment(content: "you're moving - no fire I see")],
                        title: "detected:false"
                    ),
                    conditionFunc: {() -> Bool in
                        if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                            //true condition: user is stationary
                            where speed <= 1.2 {
                            self.experienceManager.dataManager?.pushWorldObject(["label": "fire_hydrant", "interaction" : "scaffold_fire_hydrant", "variation" : "0"])
                            return true
                            }
                        //false condition: user keeps running
                        self.experienceManager.dataManager?.pushWorldObject(["label": "fire_hydrant(false)", "interaction" : "scaffold_fire_hydrant", "variation" : "0"])
                        return false
                }),
                //instruction
                SynthVoiceMoment(content: "move at least 3 meters away from your current distance to move on"),
                //moment that saves current context
                FunctionMoment(execFunc: {()->Void in
                    self.experienceManager.saveCurrentContext()
                }),
                //moment that continues as long as distance from saved location <= 1m
                ContinuousMoment(
                    conditionFunc: {() -> Bool in
                        let loc_cur = MKMapPointForCoordinate(self.experienceManager.getCurrentSavedContext()!.location!)
                        let dis = MKMetersBetweenMapPoints(
                            loc_cur,
                            MKMapPointForCoordinate(self.experienceManager.currentContext.location!)
                        )
                        print("dis from start:\(dis)")
                        if dis <= 3 {
                            //keep looping
                            //perhaps play a sound effect of some sort (ex. beep)
                            print("...continuing moment")
                            return true
                        }
                        print("...finishing moment")
                        return false
                }),
                //instruction
                SynthVoiceMoment(content: "start moving away to move on"),
                //moment that continues as long as speed <= 1
                ContinuousMoment(
                    conditionFunc: {() -> Bool in
                        let speed = self.experienceManager.currentContext.speed
                        print("cur speed:\(speed)")
                        if speed <= 1 {
                            //keep looping
                            print("...continuing moment")
                            return true
                        }
                        print("...finishing moment")
                        return false
                }),
                //instruction
                SynthVoiceMoment(content: "you have finished the game"),
                ],title: "momentblock_main")
            
            let momentBlocks = [ MomentBlock_test ]
            experienceManager = ExperienceManager(title: missionTitle, momentBlocks: momentBlocks)
            
            //UPDATE EXPERIENCEMANAGER REFERENCES
            scaffoldingManager._experienceManager = experienceManager
            ConditionalMoment.experienceManager = experienceManager
        }
        
        experienceManager.delegate = self
        experienceManager.dataManager?.delegate = self
        
        // Set up the map view
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading // don't use heading for now, annoying to always calibrate compass + UI unnecessary
        mapView.showsUserLocation = true
        
        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)
            try self.audioSession.setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func judgeTrue() -> Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateData() {
        //print("did update data")
        let curContext = experienceManager.currentContext
        locLabel.text = "lat:\(curContext.location?.latitude)\nlon:\(curContext.location?.longitude)"
        speedLabel.text = "speed:\(experienceManager.currentContext.speed)"
        activityLabel.text = "\(experienceManager.dataManager?.currentMotionActivityState)"
        
        //print("delegated!!")
    }
    
    // MARK: Actions
    
    
}