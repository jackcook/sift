//
//  Common.swift
//  PhotoSort
//
//  Created by Jack Cook on 10/25/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import Photos
import UIKit

let nc = NSNotificationCenter.defaultCenter()

var deviceSize = UIScreen.mainScreen().bounds

class PSAsset: NSObject {
    var asset: PHAsset!
    var image: UIImage!
    var name: String!
    var status = PSStatus.Normal
}

enum PSStatus {
    case Normal, Delete, Share
}

enum PSSide {
    case Up, Left, Down, Right
}