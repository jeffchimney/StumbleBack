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
    
    func savePersonalSettings(deviceId: String, weight: String, height: String, comfortableDistance: Double, difficultDistance: Double, ImpossibleDistance: Double) {
        let deviceIdRecordName = CKRecordID(recordName: deviceId)
        let deviceIdRecord = CKRecord(recordType: "User", recordID: deviceIdRecordName)
        
        publicDB.fetchRecordWithID(deviceIdRecordName, completionHandler: { record, error in
            if let fetchError = error {
                print("Record was not found, so one was created.")
                deviceIdRecord.setValue(comfortableDistance, forKey: "ComfortableDistance")
                deviceIdRecord.setValue(difficultDistance, forKey: "DifficultDistance")
                deviceIdRecord.setValue(ImpossibleDistance, forKey: "ImpossibleDistance")
                deviceIdRecord.setValue(weight, forKey: "Weight")
                deviceIdRecord.setValue(height, forKey: "Height")
                self.publicDB.saveRecord(deviceIdRecord, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            } else {
                record!.setObject(comfortableDistance, forKey: "ComfortableDistance")
                record!.setObject(difficultDistance, forKey: "DifficultDistance")
                record!.setObject(ImpossibleDistance, forKey: "ImpossibleDistance")
                record!.setObject(weight, forKey: "Weight")
                record!.setObject(height, forKey: "Height")
                self.publicDB.saveRecord(record!, completionHandler: {(_,error) -> Void in
                    if (error != nil) {
                        print(error)
                    }
                })
            }
            
        })
    
        //var modifyRecord = CKModifyRecordsOperation(recordsToSave: [deviceIdRecord], recordIDsToDelete: nil)
        //modifyRecord.savePolicy = .AllKeys
        //modifyRecord.qualityOfService = .UserInitiated
        //publicDB.addOperation(modifyRecord)    
    }
}