//
//  UsageDataManager.swift
//  SwiftRater
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit

let SwiftRaterInvalid: Int = -1
let rateOrder: [Int] = [10, 30, 60, 100, 150, 210, 280, 360, 450]

class UsageDataManager {
    
    var daysUntilPrompt: Int = SwiftRaterInvalid
    var usesUntilPrompt: Int = SwiftRaterInvalid
    var daysBeforeReminding: Int = SwiftRaterInvalid
    
    var showLaterButton: Bool = true
    var debugMode: Bool = false
    
    static private let keySwiftRaterFirstUseDate = "keySwiftRaterFirstUseDate"
    static private let keySwiftRaterUseCount = "keySwiftRaterUseCount"
    static private let keySwiftRaterSignificantEventCount = "keySwiftRaterSignificantEventCount"
    static private let keySwiftRaterSignificantUsesUntilPrompt = "keySwiftRaterSignificantUsesUntilPrompt"
    static private let keySwiftRaterRateDone = "keySwiftRaterRateDone"
    static private let keySwiftRaterTrackingVersion = "keySwiftRaterTrackingVersion"
    static private let keySwiftRaterReminderRequestDate = "keySwiftRaterReminderRequestDate"
    
    static var shared = UsageDataManager()
    
    let userDefaults = UserDefaults.standard
    
    private init() {
        let defaults = [
            UsageDataManager.keySwiftRaterFirstUseDate: 0,
            UsageDataManager.keySwiftRaterUseCount: 0,
            UsageDataManager.keySwiftRaterSignificantEventCount: 0,
            UsageDataManager.keySwiftRaterSignificantUsesUntilPrompt: significantUsesUntilPrompt,
            UsageDataManager.keySwiftRaterRateDone: false,
            UsageDataManager.keySwiftRaterTrackingVersion: "",
            UsageDataManager.keySwiftRaterReminderRequestDate: 0
            ] as [String : Any]
        let ud = UserDefaults.standard
        ud.register(defaults: defaults)
    }
    
    var isRateDone: Bool {
        get {
            return userDefaults.bool(forKey: UsageDataManager.keySwiftRaterRateDone)
        }
        set {
            userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterRateDone)
            userDefaults.synchronize()
        }
    }
    
    var trackingVersion: String {
        get {
            return userDefaults.string(forKey: UsageDataManager.keySwiftRaterTrackingVersion) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterTrackingVersion)
            userDefaults.synchronize()
        }
    }
    
    private var firstUseDate: TimeInterval {
        get {
            let value = userDefaults.double(forKey: UsageDataManager.keySwiftRaterFirstUseDate)
            
            if value == 0 {
                // store first launch date time
                let firstLaunchTimeInterval = Date().timeIntervalSince1970
                userDefaults.set(firstLaunchTimeInterval, forKey: UsageDataManager.keySwiftRaterFirstUseDate)
                return firstLaunchTimeInterval
            } else {
                return value
            }
        }
    }
    
    private var reminderRequestToRate: TimeInterval {
        get {
            return userDefaults.double(forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
        }
        set {
            userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
            userDefaults.synchronize()
        }
    }
    
    private var usesCount: Int {
        get {
            return userDefaults.integer(forKey: UsageDataManager.keySwiftRaterUseCount)
        }
        set {
            userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterUseCount)
            userDefaults.synchronize()
        }
    }
    
    private var significantEventCount: Int {
        get {
            return userDefaults.integer(forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
        }
        set {
            userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
            userDefaults.synchronize()
        }
    }
    
    var significantUsesUntilPrompt: Int {
        get {
            let count = userDefaults.integer(forKey: UsageDataManager.keySwiftRaterSignificantUsesUntilPrompt)
            
            return count == 0 ? rateOrder[0] : count
        }
        set {
            userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterSignificantUsesUntilPrompt)
            userDefaults.synchronize()
        }
    }
    
    var ratingConditionsHaveBeenMet: Bool {
        guard !debugMode else { // if debug mode, return always true
            printMessage(message: " In debug mode")
            return true
        }
        guard !isRateDone else { // if already rated, return false
            printMessage(message: " Already rated")
            return false }
        
        // check if the user has done enough significant events
        if significantUsesUntilPrompt != SwiftRaterInvalid {
            printMessage(message: " will check significantUsesUntilPrompt")
            guard significantEventCount < significantUsesUntilPrompt else { return true }
        }
        
        return false
    }
    
    func reset() {
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterFirstUseDate)
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterUseCount)
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
        userDefaults.set(false, forKey: UsageDataManager.keySwiftRaterRateDone)
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
        userDefaults.synchronize()
    }
    
    func incrementUseCount() {
        usesCount = usesCount + 1
    }
    
    func incrementSignificantUseCount() {
        significantEventCount = significantEventCount + 1
    }
    
    func getUseCount() -> Int {
        return usesCount
    }
    
    func getSignificantUseCount() -> Int {
        return significantEventCount
    }
    
    func setRateDoneIfNeeded() {
        if rateOrder.last == significantEventCount {
            isRateDone = true
        }
    }
    
    func saveReminderRequestDate() {
        let index = significantUsesUntilPrompt == rateOrder.last ? rateOrder.endIndex - 1 : (rateOrder.index(of: significantUsesUntilPrompt) ?? -1) + 1
        significantUsesUntilPrompt = index != rateOrder.count - 1 ? rateOrder[index] : rateOrder[rateOrder.count - 1]
        reminderRequestToRate = Date().timeIntervalSince1970
    }
    
    private func printMessage(message: String) {
        if SwiftRater.showLog {
            print("[SwiftRater] \(message)")
        }
    }
}

