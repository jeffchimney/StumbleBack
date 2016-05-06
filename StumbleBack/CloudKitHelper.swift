//
//  CloudKitHelper.swift
//  StumbleBack
//
//  Created by Jeff Chimney on 2016-05-04.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitHelper {
    var container : CKContainer
    var publicDB : CKDatabase
    let privateDB : CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    func saveDeviceIdRecord(deviceId : String) {
        let deviceIdRecordName = CKRecordID(recordName: deviceId)
        let deviceIdRecord = CKRecord(recordType: "User", recordID: deviceIdRecordName)
        
        publicDB.fetchRecordWithID(deviceIdRecordName, completionHandler: { record, error in
            if let fetchError = error {
                print("Record was not found, so one was created.")
                deviceIdRecord.setValue(deviceId, forKey: "DeviceId")
                self.publicDB.saveRecord(deviceIdRecord, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            } else {
                record!.setObject(deviceId, forKey: "DeviceId")
                self.publicDB.saveRecord(record!, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            }
            
        })
    }
    
    func savePersonalSettings(deviceId: String, weight: String, height: String, comfortableDistance: Double, difficultDistance: Double, impossibleDistance: Double, heightSystem: String, weightSystem: String, distanceSystem: String) {
        let deviceIdRecordName = CKRecordID(recordName: deviceId)
        let deviceIdRecord = CKRecord(recordType: "User", recordID: deviceIdRecordName)
        
        publicDB.fetchRecordWithID(deviceIdRecordName, completionHandler: { record, error in
            if let fetchError = error {
                print("Record was not found, so one was created.")
                deviceIdRecord.setValue(comfortableDistance, forKey: "ComfortableWalk")
                deviceIdRecord.setValue(difficultDistance, forKey: "DifficultWalk")
                deviceIdRecord.setValue(impossibleDistance, forKey: "ImpossibleWalk")
                deviceIdRecord.setValue(weight, forKey: "Weight")
                deviceIdRecord.setValue(height, forKey: "Height")
                deviceIdRecord.setValue(heightSystem, forKey: "HeightSystem")
                deviceIdRecord.setValue(weightSystem, forKey: "WeightSystem")
                deviceIdRecord.setValue(distanceSystem, forKey: "DistanceSystem")
                self.publicDB.saveRecord(deviceIdRecord, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            } else {
                record!.setObject(comfortableDistance, forKey: "ComfortableWalk")
                record!.setObject(difficultDistance, forKey: "DifficultWalk")
                record!.setObject(impossibleDistance, forKey: "ImpossibleWalk")
                record!.setObject(weight, forKey: "Weight")
                record!.setObject(height, forKey: "Height")
                record!.setObject(heightSystem, forKey: "HeightSystem")
                record!.setObject(weightSystem, forKey: "WeightSystem")
                record!.setObject(distanceSystem, forKey: "DistanceSystem")
                self.publicDB.saveRecord(record!, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            }
            
        })
    }
    
    func loadDistancesFromCloudForId(deviceId: String) -> CKRecord {
        let deviceIdRecordName = CKRecordID(recordName: deviceId)
        var result: CKRecord
        
        publicDB.fetchRecordWithID(deviceIdRecordName, completionHandler: { (results, error) -> Void in
            if error != nil {
                print(error)
            } else {
                print(results)
                result = results!
            }
            
        })
        return result
    }
}