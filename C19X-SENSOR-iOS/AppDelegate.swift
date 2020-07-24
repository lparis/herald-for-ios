//
//  AppDelegate.swift
//  
//
//  Created  on 24/07/2020.
//  Copyright © 2020 . All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SensorDelegate {
    private let logger = ConcreteLogger(subsystem: "App", category: "AppDelegate")
    var window: UIWindow?
    var database: Database?
    var sensor: Sensor?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logger.debug("application:didFinishLaunchingWithOptions")
        
        if #available(iOS 10.0, *) {
            database = ConcreteDatabase()
        } else {
            database = nil
        }
        sensor = SensorArray()
        sensor?.add(delegate: self)
        sensor?.start()
        
        return true
    }
    
    // MARK:- UIApplicationDelegate
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        logger.debug("applicationDidBecomeActive")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logger.debug("applicationWillResignActive")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        logger.debug("applicationWillEnterForeground")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.debug("applicationDidEnterBackground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        logger.debug("applicationWillTerminate")
    }
    
    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
        logger.info(sensor.rawValue + ",didDetect=" + didDetect.description)
    }
    
    func sensor(_ sensor: SensorType, didRead: TargetPayloadData, fromTarget: TargetIdentifier) {
        logger.info(sensor.rawValue + ",didRead=" + didRead.base64EncodedString() + ",fromTarget=" + fromTarget.description)
    }
    
    func sensor(_ sensor: SensorType, didMeasureProximity: ProximityData, fromTarget: TargetIdentifier) {
        logger.info(sensor.rawValue + ",didMeasureProximity=" + didMeasureProximity.description + ",fromTarget=" + fromTarget.description)
    }
    
    func sensor(_ sensor: SensorType, didVisit: LocationData) {
        logger.info(sensor.rawValue + ",didVisit=" + didVisit.description)
    }
    

}

