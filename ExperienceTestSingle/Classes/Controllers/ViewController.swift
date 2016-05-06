//
//  ViewController.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 4/17/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("asdf")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func triggeredHeadToMission(sender: AnyObject) {
        print("triggering head to mission")
        let vc:UIViewController = storyboard!.instantiateViewControllerWithIdentifier("TestVC")
        if let missionController = vc as? TestViewController,
            btn = sender as? UIButton,
            missionTitle = btn.titleLabel?.text {
//            missionController.missionTitle = missionTitle
//            missionController.musicOn = musicSwitch.on
            print(missionTitle, missionController)
            //self.navigationController!.pushViewController(missionController, animated: true)
        }
    }
}

