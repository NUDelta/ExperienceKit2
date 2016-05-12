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

    var insertableMomentBlocks: [MomentBlockSimple] = []
    init(insertableMomentBlocks: [MomentBlockSimple] ) {
        self.insertableMomentBlocks = insertableMomentBlocks
        super.init()
    }
    
    func getPossibleInsertion() -> MomentBlockSimple? {
        var query = PFQuery(className: "WorldObject")
        var asdf = query.getFirstObject()
        
        print("query result: \(asdf)")
        let label = asdf?.objectForKey("label") as? String
        if label != nil {
            let bestMomentBlock = getBestMomentBlock(label!)
            if bestMomentBlock != nil {
                print("--possible insertion:\(bestMomentBlock!.title)--")
                return bestMomentBlock
            }
        }
        
        //query.whereKey(key:"location", nearGeoPoint: PFGeoPoint, withinKilometers: 0.1)
        return nil
    }
    
    func getBestMomentBlock(label:String) -> MomentBlockSimple? {
        for momentBlock in insertableMomentBlocks {
            if ( momentBlock.requirement?.objectLabel == label ) {
                return momentBlock
            }
        }
        return nil
    }
    
}