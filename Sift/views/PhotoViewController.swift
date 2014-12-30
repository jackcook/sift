//
//  PhotoViewController.swift
//  PhotoSort
//
//  Created by Jack Cook on 11/22/14.
//  Copyright (c) 2014 Jack Cook. All rights reserved.
//

import Photos
import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet var topBar: UIImageView!
    @IBOutlet var photoTitle: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var trashButton: UIButton!
    
    @IBOutlet var photoView: PhotoView!
    var hidden = false
    
    var assets = [PSAsset]()
    var current: PSAsset!
    
    var undoStack = [PSAsset]()
    
    var currentImage: UIImageView!
    var nextImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.16, green: 0.5, blue: 0.73, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        photoView.backgroundColor = UIColor.blackColor()
        
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        
        fetchResult.enumerateObjectsUsingBlock { (phasset, idx, stop) -> Void in
            var asset = PSAsset()
            asset.asset = phasset as PHAsset
            var requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Fast
            PHImageManager.defaultManager().requestImageForAsset(phasset as PHAsset, targetSize: UIScreen.mainScreen().bounds.size, contentMode: PHImageContentMode.AspectFit, options: requestOptions) { (image, info) -> Void in
                if image.size.width > 100 && info["PHImageFileURLKey"] != nil {
                    asset.image = image
                    asset.name = (info["PHImageFileURLKey"]! as NSURL).lastPathComponent
                    asset.status = .Normal
                    self.assets.append(asset)
                    
                    if idx == 0 {
                        var img = self.assets[0].image
                        self.currentImage = UIImageView(image: img)
                        self.currentImage.frame = CGRectMake((deviceSize.width - img.size.width) / 2, (deviceSize.height - img.size.height) / 2, deviceSize.width, img.size.height)
                        self.photoView.loadAsset(self.assets[0], fromSide: .Up, dismissToSide: .Up)
                        self.photoTitle?.text = self.assets[0].name
                    }
                }
            }
        }
        
        var sgrl = UISwipeGestureRecognizer(target: self, action: "nextPhoto")
        sgrl.direction = UISwipeGestureRecognizerDirection.Left
        photoView.addGestureRecognizer(sgrl)
        
        var sgrr = UISwipeGestureRecognizer(target: self, action: "previousPhoto")
        sgrr.direction = UISwipeGestureRecognizerDirection.Right
        photoView.addGestureRecognizer(sgrr)
        
        var sgrd = UISwipeGestureRecognizer(target: self, action: "deletePhoto")
        sgrd.direction = UISwipeGestureRecognizerDirection.Down
        photoView.addGestureRecognizer(sgrd)
        
        var sgru = UISwipeGestureRecognizer(target: self, action: "sharePhoto")
        sgru.direction = UISwipeGestureRecognizerDirection.Up
        photoView.addGestureRecognizer(sgru)
        
        var tap = UITapGestureRecognizer(target: self, action: "toggleUI")
        tap.numberOfTapsRequired = 1
        photoView.addGestureRecognizer(tap)
        
        var dtap = UITapGestureRecognizer(target: self, action: "quickShare")
        dtap.numberOfTapsRequired = 2
        photoView.addGestureRecognizer(dtap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func toggleUI() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.topBar.alpha = self.hidden ? 1 : 0
            self.photoTitle.alpha = self.hidden ? 1 : 0
            self.shareButton.alpha = self.hidden ? 1 : 0
            self.trashButton.alpha = self.hidden ? 1 : 0
        }, completion: { (done) -> Void in
            self.hidden = !self.hidden
        })
    }
    
    @IBAction func deleteButton() {
        var todelete = [PHAsset]()
        
        for asset in assets {
            if asset.status == .Delete {
                todelete.append(asset.asset)
            }
        }
        
        if todelete.count > 0 {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                PHAssetChangeRequest.deleteAssets(todelete)
            }, completionHandler: { (success, error) -> Void in
                if success {
                    var i = 0
                    for asset in todelete {
                        self.assets.removeObject(asset)
                    }
                }
            })
        }
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        var toshare = [UIImage]()
        
        for asset in assets {
            if asset.status == .Share {
                toshare.append(asset.image)
            }
        }
        
        var activityController = UIActivityViewController(activityItems: toshare, applicationActivities: nil)
        self.presentViewController(activityController, animated: true) { () -> Void in
            for asset in self.assets {
                self.assets.getObject(asset, block: { (a) -> () in
                    a.status = .Normal
                })
            }
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        undo()
    }
    
    func nextPhoto() {
        current = assets.nextAssetWithStatus(.Normal)
        photoView.loadAsset(current, fromSide: .Right, dismissToSide: .Left)
        photoTitle.text = current.name
    }
    
    func previousPhoto() {
        current = assets.previousAssetWithStatus(.Normal)
        photoView.loadAsset(current, fromSide: .Left, dismissToSide: .Right)
        photoTitle.text = current.name
    }
    
    func deletePhoto() {
        assets.getObject(current) { (obj) -> () in
            obj.status = .Delete
        }
        
        undoStack.append(current)
        
        current = assets.nextAssetWithStatus(.Normal)
        photoView.loadAsset(current, fromSide: .Right, dismissToSide: .Down)
        photoTitle.text = current.name
    }
    
    func quickShare() {
        var activityController = UIActivityViewController(activityItems: [current.image], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    func sharePhoto() {
        assets.getObject(current) { (obj) -> () in
            obj.status = .Share
        }
        
        undoStack.append(current)
        
        current = assets.nextAssetWithStatus(.Normal)
        photoView.loadAsset(current, fromSide: .Right, dismissToSide: .Up)
        photoTitle.text = current.name
    }
    
    func undo() {
        var insert = undoStack.last!
        
        assets.getObject(insert, block: { (object) -> () in
            object.status = .Normal
        })
        
        current = assets.previousAssetWithStatus(.Normal)
        photoView.loadAsset(current, fromSide: insert.status == .Delete ? .Down : .Up, dismissToSide: .Right)
        photoTitle.text = current.name
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
