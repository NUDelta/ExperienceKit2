//
//  ContinuousMoment.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/9/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//
import Foundation

//conditional branching of moments based upon a true/false function
class ContinuousMoment: Moment{
    var conditionFunc: ()->Bool
    
    init(title:String?=nil, conditionFunc:()->Bool){
        self.conditionFunc = conditionFunc
        
        super.init(title: title ?? "continuous-moment")
    }
    
    override func play(){
        conditionFunc()
        super.play()
    }
    
    override func pause(){
        //nothing
        super.pause()
    }
    
    override func finished(){
        //nothing
        super.finished()
    }
}