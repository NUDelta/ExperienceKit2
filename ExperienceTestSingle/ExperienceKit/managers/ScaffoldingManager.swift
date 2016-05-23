//
//  ScaffoldingManager.swift
//  ExperienceTestSingle
//
//  Created by Hyung-Soon on 5/12/16.
//  Copyright © 2016 Hyung-Soon. All rights reserved.
//

import Foundation
import Parse

class ScaffoldingManager: NSObject {

    var curPulledObject: PFObject?
    var _experienceManager: ExperienceManager
    var insertableMomentBlocks: [MomentBlockSimple] = []
    init(experienceManager: ExperienceManager, insertableMomentBlocks: [MomentBlockSimple]=[] ) {
        self._experienceManager = experienceManager
        self.insertableMomentBlocks = insertableMomentBlocks
        super.init()
    }
    
    func getPossibleInsertion(withInformation: Any?) -> MomentBlockSimple? {
        //parse out user defined filters
        var label: String?
        if let infoDict = withInformation as? [String : String] {
            label = infoDict["label"]
        }
        //query possible scaffolding opportunities within x meters
        var curGeoPoint = PFGeoPoint(location: _experienceManager.dataManager!.currentLocation!)
        var query = PFQuery(className: "WorldObject")
        var geoQuery = query.whereKey("location", nearGeoPoint: curGeoPoint, withinKilometers: 0.01)
        let count = geoQuery.countObjects()
        if count <= 0 {
            return nil
        }
        //make sure object aligns with user defined parameters
        var object: PFObject?
        if (label != nil) {
            object = geoQuery.whereKey("label", equalTo: label!).getFirstObject()
        }
        else {
            return nil
        }
        print("geoquery result: \(geoQuery)")
        print("query result: \(object)")
        curPulledObject = object //save pulled object for potential reuse
        
        //get best MomentBlock for insertion (from pool)
        let bestMomentBlock = getBestMomentBlock(label!)
        if bestMomentBlock != nil {
            print("--possible insertion:\(bestMomentBlock!.title)--")
            return bestMomentBlock
        }
        return nil
    }
    
    //TODO) ALSO NEED TO RANK THE OBJECTS THAT WERE PULLED 
    //(IN CASE THERE ARE MULTIPLE THAT MATCH THE CONDITIONS)
    
    //rank the possible insertable MomentBlocks
    func getBestMomentBlock(label:String) -> MomentBlockSimple? {
        for momentBlock in insertableMomentBlocks {
            if ( momentBlock.requirement?.objectLabel == label ) {
                return momentBlock
            }
        }
        return nil
    }
    
}