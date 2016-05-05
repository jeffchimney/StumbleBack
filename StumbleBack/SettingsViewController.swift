//
//  SettingsViewController.swift
//  StumbleBack
//
//  Created by Jeff Chimney on 2016-04-29.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var cloudKitHelper = CloudKitHelper()
    var deviceId: String = ""
    
    var heightSystems = ["ft","cms"]
    var weightSystems = ["lbs", "kgs"]
    var distanceSystems = ["mi","kms"]
    var heightsImperial = [String]()
    var heightsMetric = [String]()
    var weightsImperial = [String]()
    var weightsMetric = [String]()
    
    var currentlySelectedSystem = "ft"
    var currentlySelectedWeightSystem = "lbs"
    var currentlySelectedDistanceSystem = "mi"
    
    @IBOutlet var systemWeightPickerView: UIPickerView!
    @IBOutlet var weightPickerView: UIPickerView!
    @IBOutlet weak var systemHeightPickerView: UIPickerView!
    @IBOutlet weak var heightPickerView: UIPickerView!
    @IBOutlet weak var distanceSystemPickerView: UIPickerView!
    @IBOutlet weak var easyPicker: UIPickerView!
    @IBOutlet weak var hardPicker: UIPickerView!
    @IBOutlet weak var impossiblePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuViewController.userDidSwipe(_:)))
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        self.view.addGestureRecognizer(swipeLeftRecognizer)
        
        systemHeightPickerView.dataSource = self
        heightPickerView.dataSource = self
        systemWeightPickerView.dataSource = self
        weightPickerView.dataSource = self
        distanceSystemPickerView.dataSource = self
        easyPicker.dataSource = self
        hardPicker.dataSource = self
        impossiblePicker.dataSource = self
        
        systemHeightPickerView.delegate = self
        heightPickerView.delegate = self
        systemWeightPickerView.delegate = self
        weightPickerView.delegate = self
        distanceSystemPickerView.delegate = self
        easyPicker.delegate = self
        hardPicker.delegate = self
        impossiblePicker.delegate = self
        
        for i in 3 ... 8 {
            for j in 0...11 {
                heightsImperial.append("\(i)' \(j)''")
            }
        }
        for i in 100 ... 300 {
            heightsMetric.append("\(i)")
        }
        
        
        for i in 70 ... 400 {
            weightsImperial.append("\(i)")
            weightsMetric.append("\(Double(i) * 0.454)")
        }
    }
    
    func userDidSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == systemHeightPickerView {
            return heightSystems.count
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[1] {
            return heightsMetric.count
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[0] {
            return heightsMetric.count
        } else if pickerView == systemWeightPickerView {
            return weightSystems.count
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[1] {
            return weightsMetric.count
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[0] {
            return weightsImperial.count
        } else {
            return 1 // something went wrong
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == systemHeightPickerView {
            return heightSystems[row]
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[1] {
            return heightsMetric[row]
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[0] {
            if row < heightsImperial.count {
                return heightsImperial[row]
            } else {
                return "-" // this is just a placehoder because the metric picker is bigger than the imperial picker
            }
        } else if pickerView == systemWeightPickerView {
            return weightSystems[row]
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[1] {
            return String(format: "%.1f", Double(weightsMetric[row])!)
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[0] {
            return weightsImperial[row]
        }else {
            return "Something went wrong"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == systemHeightPickerView {
            if(row == 1) {
                currentlySelectedSystem = heightSystems[1]
                heightPickerView.selectRow(75, inComponent: 0, animated: true)
            } else {
                heightPickerView.selectRow(30, inComponent: 0, animated: true)
                currentlySelectedSystem = heightSystems[0]
            }
        } else if pickerView == heightPickerView {
            if currentlySelectedSystem == heightSystems[0] {
                if row > heightsImperial.count {
                    heightPickerView.selectRow(heightsImperial.count-1, inComponent: 0, animated: true)
                }
            }
        } else if pickerView == systemWeightPickerView  {
            if(row == 1) {
                currentlySelectedWeightSystem = weightSystems[1]
                weightPickerView.selectRow(88, inComponent: 0, animated: true)
            } else {
                currentlySelectedWeightSystem = weightSystems[0]
                weightPickerView.selectRow(100, inComponent: 0, animated: true)
            }
        }
    }
}