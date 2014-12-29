//
//  ArrayUtils.swift
//  Sift
//
//  Created by Jack Cook on 12/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import Foundation

private var idx = 0

extension Array {
    
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if (index) != nil {
            self.removeAtIndex(index!)
        }
    }
    
    func getObject<U: Equatable>(object: U, block: (U) -> ()) {
        for objectToCompare in self {
            if object == objectToCompare as? U {
                block(objectToCompare as U)
            }
        }
    }
    
    /* ONLY USE WITH PSASSET ARRAYS */
    
    func nextAssetWithStatus(status: PSStatus) -> PSAsset {
        if idx + 1 >= self.count {
            idx = 0
            return self.first as PSAsset
        }
        
        idx += 1
        var next = self[idx] as PSAsset
        
        while next.status != status {
            idx += 1
            next = self[idx] as PSAsset
        }
        
        return next
    }
    
    func previousAssetWithStatus(status: PSStatus) -> PSAsset {
        if idx == 0 {
            idx = self.count - 1
            return self.last as PSAsset
        }
        
        idx -= 1
        var previous = self[idx] as PSAsset
        
        while previous.status != status {
            idx -= 1
            previous = self[idx] as PSAsset
        }
        
        return previous
    }
}
