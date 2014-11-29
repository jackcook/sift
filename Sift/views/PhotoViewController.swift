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

    @IBOutlet var barTitle: UINavigationItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var photoView: UIView!
    var hidden = false
    
    var assets = [PSAsset]()
    var delete = [PSAsset]()
    var share = [PSAsset]()
    
    var current = 0
    var total = 0
    
    var currentImage: UIImageView!
    var nextImage: UIImageView!
    
    var photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    var imageManager = PHImageManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.16, green: 0.5, blue: 0.73, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.photoView.backgroundColor = UIColor.blackColor()
        
        //if (defaults.dictionaryForKey(BindingsDefault) == nil) {
            var bindings = ["Swipe Left": "Next Photo",
                "Swipe Right": "Previous Photo",
                "Swipe Down": "Delete Photo",
                "Swipe Up": "Share",
                "Double Tap": "Quick Share",
                "Shake Device": "Undo"]
            defaults.setObject(bindings, forKey: BindingsDefault)
        //}
        
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        
        fetchResult.enumerateObjectsUsingBlock { (phasset, idx, stop) -> Void in
            var asset = PSAsset()
            asset.asset = phasset as PHAsset
            var requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Fast
            self.imageManager.requestImageForAsset(phasset as PHAsset, targetSize: UIScreen.mainScreen().bounds.size, contentMode: PHImageContentMode.AspectFit, options: requestOptions) { (image, info) -> Void in
                if (image.size.width > 100 && info["PHImageFileURLKey"] != nil) {
                    asset.image = image
                    asset.name = (info["PHImageFileURLKey"]! as NSURL).lastPathComponent
                    asset.index = idx
                    self.assets.append(asset)
                    if (idx == 0) {
                        var img = self.assets[0].image
                        self.currentImage = UIImageView(image: img)
                        self.currentImage.frame = CGRectMake((device.size.width - img.size.width) / 2, (device.size.height - img.size.height) / 2, device.width, img.size.height)
                        self.photoView.insertSubview(self.currentImage, belowSubview: self.navigationController!.navigationBar)
                        self.navigationController?.navigationBar.topItem?.title = self.assets[self.current].name
                    }
                    self.total += 1
                }
            }
        }
        
        var sgrl = UISwipeGestureRecognizer(target: self, action: "swipe:")
        sgrl.direction = UISwipeGestureRecognizerDirection.Left
        self.photoView.addGestureRecognizer(sgrl)
        
        var sgrr = UISwipeGestureRecognizer(target: self, action: "swipe:")
        sgrr.direction = UISwipeGestureRecognizerDirection.Right
        self.photoView.addGestureRecognizer(sgrr)
        
        var sgrd = UISwipeGestureRecognizer(target: self, action: "swipe:")
        sgrd.direction = UISwipeGestureRecognizerDirection.Down
        self.photoView.addGestureRecognizer(sgrd)
        
        var sgru = UISwipeGestureRecognizer(target: self, action: "swipe:")
        sgru.direction = UISwipeGestureRecognizerDirection.Up
        self.photoView.addGestureRecognizer(sgru)
        
        var tap = UITapGestureRecognizer(target: self, action: "tap:")
        tap.numberOfTapsRequired = 1
        self.photoView.addGestureRecognizer(tap)
        
        var dtap = UITapGestureRecognizer(target: self, action: "tap:")
        dtap.numberOfTapsRequired = 2
        self.photoView.addGestureRecognizer(dtap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func swipe(sender: UISwipeGestureRecognizer) {
        switch (sender.direction) {
        case UISwipeGestureRecognizerDirection.Left:
            performAction(PSGesture.SwipeLeft)
        case UISwipeGestureRecognizerDirection.Right:
            performAction(PSGesture.SwipeRight)
        case UISwipeGestureRecognizerDirection.Down:
            performAction(PSGesture.SwipeDown)
        case UISwipeGestureRecognizerDirection.Up:
            performAction(PSGesture.SwipeUp)
        default:
            NSLog("wat")
        }
    }
    
    func tap(sender: UITapGestureRecognizer) {
        switch (sender.numberOfTapsRequired) {
        case 1:
            UIApplication.sharedApplication().setStatusBarHidden(self.hidden ? false : true, withAnimation: UIStatusBarAnimation.Fade)
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.navigationController!.navigationBar.alpha = self.hidden ? 1 : 0
            }, completion: { (done) -> Void in
                self.hidden = !self.hidden
            })
        case 2:
            performAction(PSGesture.DoubleTap)
        default:
            NSLog("\(sender.numberOfTapsRequired)")
        }
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        if (delete.count > 0) {
            var todelete = [PHAsset]()
            for asset in delete {
                todelete.append(asset.asset)
            }
            
            photoLibrary.performChanges({ () -> Void in
                PHAssetChangeRequest.deleteAssets(todelete)
            }, completionHandler: { (success, error) -> Void in
                if (success) {
                    self.delete = [PSAsset]()
                }
                
                self.sharePhotos()
            })
        } else {
            sharePhotos()
        }
    }
    
    func sharePhotos() {
        if (self.share.count > 0) {
            var toshare = [UIImage]()
            for asset in self.share {
                toshare.append(asset.image)
            }
            
            var activityController = UIActivityViewController(activityItems: toshare, applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        performAction(PSGesture.Shake)
    }
    
    func performAction(gesture: PSGesture) {
        var bindings = defaults.dictionaryForKey(BindingsDefault) as [String: String]
        var action = stringToAction(bindings[gestureToString(gesture)]!)
        switch (action) {
        case PSAction.NextPhoto:
            nextPhoto()
        case PSAction.PreviousPhoto:
            previousPhoto()
        case PSAction.DeletePhoto:
            deletePhoto()
        case PSAction.QuickShare:
            quickShare()
        case PSAction.Share:
            sharePhoto()
        case PSAction.Undo:
            undo()
        default:
            NSLog("wat")
        }
    }
    
    func nextPhoto() {
        changePhoto(true)
    }
    
    func previousPhoto() {
        changePhoto(false)
    }
    
    func changePhoto(direction: Bool) {
        var l = direction
        
        if (l ? current + 1 == total : current == 0) {
            return
        }
        
        current += l ? 1 : -1
        var img = assets[current].image
        nextImage = UIImageView(image: img)
        nextImage.frame = CGRectMake(l ? device.width : -device.width, (device.size.height - img.size.height) / 2, img.size.width, img.size.height)
        self.photoView.insertSubview(self.nextImage, belowSubview: self.navigationController!.navigationBar)
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.nextImage.frame = CGRectMake(0, self.nextImage.frame.origin.y, device.width, self.nextImage.frame.size.height)
            self.currentImage.frame = CGRectMake(l ? -device.width : device.width, self.currentImage.frame.origin.y, self.currentImage.frame.size.width, self.currentImage.frame.size.height)
        }) { (done) -> Void in
            self.navigationController?.navigationBar.topItem?.title = self.assets[self.current].name
            self.currentImage.removeFromSuperview()
            self.currentImage = self.nextImage
            self.nextImage = nil
        }
    }
    
    func deletePhoto() {
        delete.append(assets[current])
        assets.removeAtIndex(current)
        
        var l = true
        if (current + 1 == total) {
            l = false
            current -= 1
        }
        
        var img = assets[current].image
        nextImage = UIImageView(image: img)
        nextImage.frame = CGRectMake(l ? device.width : -device.width, (device.size.height - img.size.height) / 2, img.size.width, img.size.height)
        self.photoView.insertSubview(self.nextImage, belowSubview: self.navigationController!.navigationBar)
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.nextImage.frame = CGRectMake(0, self.nextImage.frame.origin.y, device.width, self.nextImage.frame.size.height)
            self.currentImage.frame = CGRectMake(0, device.height, self.currentImage.frame.size.width, self.currentImage.frame.size.height)
        }) { (done) -> Void in
            self.navigationController?.navigationBar.topItem?.title = self.assets[self.current].name
            self.currentImage.removeFromSuperview()
            self.currentImage = self.nextImage
            self.nextImage = nil
            self.total -= 1
        }
    }
    
    func quickShare() {
        var image = self.assets[current].image
        var activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    func sharePhoto() {
        share.append(assets[current])
        assets.removeAtIndex(current)
        
        var l = true
        if (current + 1 == total) {
            l = false
            current -= 1
        }
        
        var img = assets[current].image
        nextImage = UIImageView(image: img)
        nextImage.frame = CGRectMake(l ? device.width : -device.width, (device.size.height - img.size.height) / 2, img.size.width, img.size.height)
        self.photoView.insertSubview(self.nextImage, belowSubview: self.navigationController!.navigationBar)
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.nextImage.frame = CGRectMake(0, self.nextImage.frame.origin.y, device.width, self.nextImage.frame.size.height)
            self.currentImage.frame = CGRectMake(0, -self.currentImage.frame.size.height, self.currentImage.frame.size.width, self.currentImage.frame.size.height)
        }) { (done) -> Void in
            self.navigationController?.navigationBar.topItem?.title = self.assets[self.current].name
            self.currentImage.removeFromSuperview()
            self.currentImage = self.nextImage
            self.nextImage = nil
            self.total -= 1
        }
    }
    
    func undo() {
        if (self.delete.count > 0) {
            var deleted = delete[delete.count - 1]
            assets.insert(deleted, atIndex: current)
            
            delete.removeAtIndex(delete.count - 1)
            
            var img = deleted.image
            nextImage = UIImageView(image: img)
            nextImage.frame = CGRectMake(0, device.height + (device.height - img.size.height) / 2, img.size.width, img.size.height)
            self.photoView.insertSubview(self.nextImage, belowSubview: self.navigationController!.navigationBar)
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.nextImage.frame = CGRectMake(self.nextImage.frame.origin.x, (device.size.height - img.size.height) / 2, self.nextImage.frame.size.width, self.nextImage.frame.size.height)
                self.currentImage.frame = CGRectMake(device.width, self.currentImage.frame.origin.y, self.currentImage.frame.size.width, self.currentImage.frame.size.height)
            }) { (done) -> Void in
                self.navigationController?.navigationBar.topItem?.title = self.assets[self.current].name
                self.currentImage.removeFromSuperview()
                self.currentImage = self.nextImage
                self.nextImage = nil
            }
        }
    }
}
