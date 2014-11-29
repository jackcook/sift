//
//  Common.swift
//  PhotoSort
//
//  Created by Jack Cook on 10/25/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

var device = UIScreen.mainScreen().bounds
var defaults = NSUserDefaults.standardUserDefaults()

let BindingsDefault = "BindingsDefault"

enum PSGesture: String {
    case SwipeLeft = "Swipe Left"
    case SwipeRight = "Swipe Right"
    case SwipeUp = "Swipe Up"
    case SwipeDown = "Swipe Down"
    case DoubleTap = "Double Tap"
    case Shake = "Shake Device"
    case None = "None"
}

func gestureToString(gesture: PSGesture) -> String {
    return gesture.rawValue as String
}

func stringToGesture(value: String) -> PSGesture {
    switch (value) {
    case "Swipe Left":
        return PSGesture.SwipeLeft
    case "Swipe Right":
        return PSGesture.SwipeRight
    case "Swipe Up":
        return PSGesture.SwipeUp
    case "Swipe Down":
        return PSGesture.SwipeDown
    case "Double Tap":
        return PSGesture.DoubleTap
    case "Shake Device":
        return PSGesture.Shake
    case "None":
        return PSGesture.None
    default:
        return PSGesture.None
    }
}

enum PSAction: String {
    case NextPhoto = "Next Photo"
    case PreviousPhoto = "Previous Photo"
    case DeletePhoto = "Delete Photo"
    case QuickShare = "Quick Share"
    case Share = "Share"
    case Undo = "Undo"
    case None = "None"
}

func actionToString(action: PSAction) -> String {
    return action.rawValue as String
}

func stringToAction(value: String) -> PSAction {
    switch (value) {
    case "Next Photo":
        return PSAction.NextPhoto
    case "Previous Photo":
        return PSAction.PreviousPhoto
    case "Delete Photo":
        return PSAction.DeletePhoto
    case "Quick Share":
        return PSAction.QuickShare
    case "Share":
        return PSAction.Share
    case "Undo":
        return PSAction.Undo
    case "None":
        return PSAction.None
    default:
        return PSAction.None
    }
}
