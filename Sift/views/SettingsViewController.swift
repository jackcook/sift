//
//  SettingsViewController.swift
//  PhotoSort
//
//  Created by Jack Cook on 11/23/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var gestures = [PSGesture.SwipeLeft, PSGesture.SwipeRight, PSGesture.SwipeDown, PSGesture.SwipeUp, PSGesture.DoubleTap, PSGesture.Shake, PSGesture.None]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset.top = -64
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Gestures"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        var bindings = defaults.dictionaryForKey(BindingsDefault) as [String: String]
        
        var value = gestureToString(gestures[indexPath.row])
        cell.textLabel?.text = value
        cell.detailTextLabel?.text = bindings[value]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var actions = ["Next Photo", "Previous Photo", "Delete Photo", "Quick Share", "Share", "Undo", "None"]
        ActionSheetStringPicker.showPickerWithTitle("Pick an Action", rows: actions, initialSelection: 0, doneBlock: { (picker, index, value) -> Void in
            var cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.detailTextLabel?.text = value as? String
            
            var bindings = defaults.dictionaryForKey(BindingsDefault) as [String: String]
            bindings[gestureToString(self.gestures[indexPath.row])] = value as? String
            defaults.setObject(bindings, forKey: BindingsDefault)
        }, cancelBlock: { (picker) -> Void in
            
        }, origin: self.view)
    }
}