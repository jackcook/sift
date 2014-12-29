//
//  PhotoView.swift
//  Sift
//
//  Created by Jack Cook on 12/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

class PhotoView: UIView {
    
    var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        nc.addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func orientationChanged(notification: NSNotification) {
        if imageView.image != nil {
            var actualSize = imageView.image!.size
            var size = CGSizeMake(self.bounds.width, self.bounds.width / (actualSize.width / actualSize.height))
            
            if size.height > self.frame.size.height {
                size = CGSizeMake(self.bounds.height, self.bounds.width / (actualSize.width / actualSize.height))
            }
            
            imageView.frame = CGRectMake((self.bounds.width - size.width) / 2, (self.bounds.height - size.height) / 2, size.width, size.height)
        }
    }
    
    func loadAsset(asset: PSAsset, fromSide side: PSSide, dismissToSide dismissSide: PSSide) {
        var newImageView = UIImageView(image: asset.image)
        
        var actualSize = asset.image.size
        var size = CGSizeMake(self.bounds.width, self.bounds.width / (actualSize.width / actualSize.height))
        
        if size.height > self.frame.size.height {
            size = CGSizeMake(self.bounds.height / (actualSize.height / actualSize.width), self.bounds.height)
        }
        
        newImageView.frame = CGRectMake(((self.bounds.width - size.width) / 2), (self.bounds.height - size.height) / 2, size.width, size.height)
        self.addSubview(newImageView)
        
        var newFrame = imageView.frame
        
        if side == .Up {
            newImageView.frame.origin.y = -newImageView.frame.size.height
        } else if side == .Left {
            newImageView.frame.origin.x = -newImageView.frame.size.width
        } else if side == .Down {
            newImageView.frame.origin.y = device.height
        } else if side == .Right {
            newImageView.frame.origin.x = device.width
        }
        
        if dismissSide == .Up {
            newFrame.origin.y = -newFrame.size.height
        } else if dismissSide == .Left {
            newFrame.origin.x = -newFrame.size.width
        } else if dismissSide == .Down {
            newFrame.origin.y = device.height
        } else if dismissSide == .Right {
            newFrame.origin.x = device.width
        }
        
        if imageView.image != nil {
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                newImageView.frame = CGRectMake((self.bounds.width - size.width) / 2, (self.bounds.height - size.height) / 2, size.width, size.height)
                self.imageView.frame = newFrame
            }, completion: { (done) -> Void in
                self.imageView.removeFromSuperview()
                self.imageView = newImageView
            })
        } else {
            imageView = newImageView
            newImageView.frame = CGRectMake((self.bounds.width - size.width) / 2, (self.bounds.height - size.height) / 2, size.width, size.height)
        }
    }
}
