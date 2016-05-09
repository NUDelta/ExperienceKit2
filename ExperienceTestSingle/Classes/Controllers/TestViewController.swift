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
        
        /*
         *
         * MARK: Sprinting MomentBlockSimples
         *
         */
        print("[MissionViewController] init experiences")
        
        let findHydrantInstruct = Sound(fileNames: ["radio_static", "our_monitors_show", "radio_static"])
        let findHydrantCollector = SensorCollector(lengthInSeconds: 30, dataLabel: "fire_hydrant", sensors: [.Location, .Speed])
        let findFireHydrant = MomentBlockSimple(moments: [findHydrantInstruct, findHydrantCollector, Sound(fileNames: ["radio_static", "you've_thrown_off","radio_static"])], title: "Sprint to hydrant")
        
        
        let passTenTreesInstruct = Sound(fileNames: ["radio_static", "weve_noticed_increased", "radio_static"])
        let passTenTreesCollector = SensorCollector(lengthInSeconds: 25, dataLabel: "tree", sensors: [.Location, .Speed])
        let passTenTrees = MomentBlockSimple(moments: [passTenTreesInstruct, passTenTreesCollector, Sound(fileNames: ["radio_static","you_should_be","radio_static"])], title: "Sprint past ten trees")
        
        let sprintToBuildingInstruct = Sound(fileNames: ["radio_static", "the_radars_on", "radio_static"])
        let sprintToBuildingCollector = SensorCollector(lengthInSeconds: 20, dataLabel: "tall_building", sensors: [.Location, .Speed])
        let sprintToBuilding = MomentBlockSimple(moments: [sprintToBuildingInstruct, sprintToBuildingCollector, Sound(fileNames: ["radio_static","building_confirmed","radio_static"])], title: "Sprint to tall building")
        
        let sprintingMomentBlockSimples = [findFireHydrant, sprintToBuilding, passTenTrees]
        
        // Construct the experience based on selected mission
        var momentBlocks: [MomentBlock] = []
        if missionTitle == "Intel Mission" {
            
            let MomentBlock1 = MomentBlock(moments: [Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static", "vignette_transition"]), Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
                               title: "MomentBlock1", MomentBlockSimpleInsertionIndices: [2], MomentBlockSimplePool: sprintingMomentBlockSimples)
            let MomentBlock2 = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
                               title: "MomentBlock2", MomentBlockSimpleInsertionIndices: [1], MomentBlockSimplePool: sprintingMomentBlockSimples)
            let MomentBlock3 = MomentBlock(moments: [Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition","mission_completed"])],
                               title: "MomentBlock3", MomentBlockSimpleInsertionIndices: [1], MomentBlockSimplePool: sprintingMomentBlockSimples)
            
            momentBlocks = [MomentBlock1, MomentBlock2, MomentBlock3]
        }
        
        
        experienceManager = ExperienceManager(title: missionTitle, momentBlocks: momentBlocks)
        
        //[TEST CONDITIONS]
        if (true)
        {
            let testInstruct = Sound(fileNames: ["radio_static", "the_radars_on", "radio_static"], isInterruptable: true) //isInterruptable, thus test MomentBlockSimples can be inserted through the opportunity manager
            let testCollector = SensorCollector(lengthInSeconds: 20, dataLabel: "test_collector", sensors: [.Location, .Speed])
            let testCollector1 = SensorCollector(lengthInSeconds: 20, dataLabel: "test_collector", sensors: [.Location, .Speed])
            
            var lat: CLLocationDegrees = 37.785834
            var long: CLLocationDegrees = -122.406417
            lat = 39
            long = -130
            
            let momentblock_opportunity0 = MomentBlockSimple(moments: [testInstruct, testCollector, Sound(fileNames: ["radio_static","our_monitors_show","radio_static"])], title: "momentblock_opportunity0",
                                               requirement: Requirement(conditions:[Condition.InRegion],
                                                region: CLCircularRegion(center: CLLocationCoordinate2DMake(lat, long), radius: CLLocationDistance(10.0), identifier: "region")))
            
            lat = 38
            long = -122
            //note: classes are passed as references
            //that's why testCollector gets modified twice.
            let momentblock_opportunity1 = MomentBlockSimple(moments: [sprintToBuildingInstruct, testCollector1, Sound(fileNames: ["radio_static","our_monitors_show","radio_static"])], title: "momentblock_opportunity1",
                                               requirement: Requirement(conditions:[Condition.InRegion],
                                                region: CLCircularRegion(center: CLLocationCoordinate2DMake(lat, long), radius: CLLocationDistance(10.0), identifier: "region"),
                                                canInsertImmediately: true))
            
//            let MomentBlock_test = MomentBlock(moments: [Interim(lengthInSeconds: 5), Interim(lengthInSeconds:2, canEvaluateOpportunity: true), Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static", "vignette_transition"]), Interim(lengthInSeconds: 90), Sound(fileNames: ["vignette_transition"])],
//                               title: "momentblock_main")

            let MomentBlock_test = MomentBlock(moments: [
                Interim(lengthInSeconds: 5),
                SensorCollector(lengthInSeconds: 10, dataLabel: "collector_for_cond", sensors: [.Location, .Speed, .MotionActivity]),
                ConditionalMoment(
                    moment_true: Sound(fileNames: ["radio_static", "intel_team_intro", "radio_static", "vignette_transition"]),
                    moment_false: Sound(fileNames: ["radio_static","our_monitors_show","radio_static"]),
                    conditionFunc: {() -> Bool in
                        if let speed = self.experienceManager.dataManager?.currentLocation?.speed
                        where speed <= 1.2 {
                            return true
                        }
                        return false
                })
                ],title: "momentblock_main")
            
            momentBlocks = [ MomentBlock_test ]
            
            //set up opportunity manager
            experienceManager = ExperienceManager(title: missionTitle, momentBlocks: momentBlocks)
            experienceManager.opportunityManager = OpportunityManager(MomentBlockSimplePool: [momentblock_opportunity0])
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
        
        //self.experienceManager.start()
        
        //[speech synthesizer test]
        //let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance = AVSpeechUtterance(string: "hello there, this is a test. We have detected enemy signals around your area. keep your sprinting pace, and continue on until further instructions.")
        
        //speechUtterance.rate = 0.25 //speed of speech
        //speechUtterance.pitchMultiplier = 1.25
        speechUtterance.volume = 0.75
        //speechUtterance.
        
        //print(AVSpeechSynthesisVoice.speechVoices())
        
        let voice = AVSpeechSynthesisVoice(language: "en-za")
        speechUtterance.voice = voice
        //speechSynthesizer.speakUtterance(speechUtterance)
        
    }
    
    func judgeTrue() -> Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateData() {
        locLabel.text = "\(experienceManager.dataManager?.currentLocation)"
        speedLabel.text = "speed:\(experienceManager.dataManager?.currentLocation?.speed)"
        activityLabel.text = "\(experienceManager.dataManager?.currentMotionActivityState)"
        
        //print("delegated!!")
    }
    
    // MARK: Actions
    
    
}