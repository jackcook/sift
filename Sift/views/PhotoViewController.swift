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
    var delete = [PSAsset]()
    var share = [PSAsset]()
    
    var current = 0
    
    var currentImage: UIImageView!
    var nextImage: UIImageView!
    
    var photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    var imageManager = PHImageManager.defaultManager()
    
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
            self.imageManager.requestImageForAsset(phasset as PHAsset, targetSize: UIScreen.mainScreen().bounds.size, contentMode: PHImageContentMode.AspectFit, options: requestOptions) { (image, info) -> Void in
                if image.size.width > 100 && info["PHImageFileURLKey"] != nil {
                    asset.image = image
                    asset.name = (info["PHImageFileURLKey"]! as NSURL).lastPathComponent
                    asset.index = idx
                    self.assets.append(asset)
                    if idx == 0 {
                        var img = self.assets[0].image
                        self.currentImage = UIImageView(image: img)
                        self.currentImage.frame = CGRectMake((deviceSize.width - img.size.width) / 2, (deviceSize.height - img.size.height) / 2, deviceSize.width, img.size.height)
                        self.photoView.loadAsset(self.assets[0], fromSide: .Up, dismissToSide: .Up)
                        self.photoTitle?.text = self.assets[self.current].name
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
        
        var dtap = UITapGestureRecognizer(target: self, action: "deleteButton")
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
        if delete.count > 0 {
            var todelete = [PHAsset]()
            for asset in delete {
                todelete.append(asset.asset)
            }
            
            photoLibrary.performChanges({ () -> Void in
                PHAssetChangeRequest.deleteAssets(todelete)
            }, completionHandler: { (success, error) -> Void in
                if success {
                    self.delete = [PSAsset]()
                }
            })
        }
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        if share.count > 0 {
            var toshare = [UIImage]()
            for asset in share {
                toshare.append(asset.image)
            }
            
            var activityController = UIActivityViewController(activityItems: toshare, applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        undo()
    }
    
    func nextPhoto() {
        if current + 1 == assets.count {
            return
        }
        
        current += 1
        
        photoView.loadAsset(assets[current], fromSide: .Right, dismissToSide: .Left)
        photoTitle.text = assets[current].name
    }
    
    func previousPhoto() {
        if current == 0 {
            return
        }
        
        current -= 1
        
        photoView.loadAsset(assets[current], fromSide: .Left, dismissToSide: .Right)
        photoTitle.text = assets[current].name
    }
    
    func deletePhoto() {
        delete.append(assets[current])
        assets.removeAtIndex(current)
        
        var l = true
        if current == assets.count {
            l = false
            current -= 1
        }
        
        photoView.loadAsset(assets[current], fromSide: l ? .Right : .Left, dismissToSide: .Down)
        photoTitle.text = assets[current].name
    }
    
    func quickShare() {
        var image = assets[current].image
        var activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    func sharePhoto() {
        share.append(assets[current])
        assets.removeAtIndex(current)
        
        var l = true
        if current == assets.count {
            l = false
            current -= 1
        }
        
        photoView.loadAsset(assets[current], fromSide: l ? .Right : .Left, dismissToSide: .Up)
        photoTitle.text = assets[current].name
    }
    
    func undo() {
        if delete.count > 0 {
            var deleted = delete[delete.count - 1]
            assets.insert(deleted, atIndex: current)
            
            delete.removeAtIndex(delete.count - 1)
            
            photoView.loadAsset(assets[current], fromSide: .Down, dismissToSide: .Right)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
