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
    
    var weight = ""
    var height = ""
    var easyDistance = ""
    var hardDistance = ""
    var impossibleDistance = ""
    
    var heightSystems = ["ft","cms"]
    var weightSystems = ["lbs", "kgs"]
    var distanceSystems = ["mi","kms"]
    var heightsImperial = [String]()
    var heightsMetric = [String]()
    var weightsImperial = [String]()
    var weightsMetric = [String]()
    var distances = [String]()
    
    var currentlySelectedSystem = "ft"
    var currentlySelectedWeightSystem = "lbs"
    var currentlySelectedDistanceSystem = "mi"
    
    @IBOutlet var weightPickerView: UIPickerView!
    @IBOutlet weak var heightPickerView: UIPickerView!
    @IBOutlet weak var easyPicker: UIPickerView!
    @IBOutlet weak var hardPicker: UIPickerView!
    @IBOutlet weak var impossiblePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuViewController.userDidSwipe(_:)))
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        self.view.addGestureRecognizer(swipeLeftRecognizer)
        
        heightPickerView.dataSource = self
        weightPickerView.dataSource = self
        easyPicker.dataSource = self
        hardPicker.dataSource = self
        impossiblePicker.dataSource = self
        
        heightPickerView.delegate = self
        weightPickerView.delegate = self
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
        
        var i = 0.0
        while (i < 5.9) {
            i += 0.1
            distances.append(String(format: "%.1f", i))
        }
    }
    
    func userDidSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
        
            if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[1] {
                return heightsMetric.count
            } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[0] {
                return heightsMetric.count
            } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[1] {
                return weightsMetric.count
            } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[0] {
                return weightsImperial.count
            } else if pickerView == easyPicker {
                return distances.count
            } else if pickerView == hardPicker {
                return distances.count
            } else if pickerView == impossiblePicker {
                return distances.count
            } else {
                return 1 // something went wrong
            }
        } else {
            return 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[1] {
                if row == 0 {
                    height = heightsMetric[row]
                }
                return heightsMetric[row]
            } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[0] {
                if row < heightsImperial.count {
                    if row == 0 {
                        height = heightsImperial[row]
                    }
                    return heightsImperial[row]
                } else {
                    return "-" // this is just a placehoder because the metric picker is bigger than the imperial picker
                }
            } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[1] {
                if row == 0 {
                    weight = weightsMetric[row]
                }
                return String(format: "%.1f", Double(weightsMetric[row])!)
            } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[0] {
                if row == 0 {
                    weight = weightsImperial[row]
                }
                return weightsImperial[row]
            } else if pickerView == easyPicker || pickerView == hardPicker || pickerView == impossiblePicker {
                if row == 0 {
                    easyDistance = distances[row]
                    hardDistance = distances[row]
                    impossibleDistance = distances[row]
                }
                return distances[row]
            } else {
                return "Something went wrong"
            }
        } else {
            if pickerView == heightPickerView {
                return heightSystems[row]
            } else if pickerView == weightPickerView {
                return weightSystems[row]
            } else if pickerView == easyPicker {
                return distanceSystems[row]
            } else if pickerView == hardPicker {
                return distanceSystems[row]
            } else if pickerView == impossiblePicker {
                return distanceSystems[row]
            } else {
                return "Something went wrong"
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 1 {
            if pickerView == heightPickerView {
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
            } else if pickerView == weightPickerView  {
                if row == 1 && component == 1 {
                    currentlySelectedWeightSystem = weightSystems[1]
                    weightPickerView.selectRow(88, inComponent: 0, animated: true)
                } else if row == 0 && component == 1{
                    currentlySelectedWeightSystem = weightSystems[0]
                    weightPickerView.selectRow(100, inComponent: 0, animated: true)
                }
            } else if pickerView == easyPicker {
                if row == 1 {
                    currentlySelectedDistanceSystem = distanceSystems[1]
                    hardPicker.selectRow(1, inComponent: 1, animated: true)
                    impossiblePicker.selectRow(1, inComponent: 1, animated: true)
                } else {
                    currentlySelectedDistanceSystem = distanceSystems[0]
                    hardPicker.selectRow(0, inComponent: 1, animated: true)
                    impossiblePicker.selectRow(0, inComponent: 1, animated: true)
                }
            } else if pickerView == hardPicker {
                if row == 1 {
                    currentlySelectedDistanceSystem = distanceSystems[1]
                    easyPicker.selectRow(1, inComponent: 1, animated: true)
                    impossiblePicker.selectRow(1, inComponent: 1, animated: true)
                } else {
                    currentlySelectedDistanceSystem = distanceSystems[0]
                    easyPicker.selectRow(0, inComponent: 1, animated: true)
                    impossiblePicker.selectRow(0, inComponent: 1, animated: true)
                }
            } else if pickerView == impossiblePicker {
                if row == 1 {
                    currentlySelectedDistanceSystem = distanceSystems[1]
                    hardPicker.selectRow(1, inComponent: 1, animated: true)
                    easyPicker.selectRow(1, inComponent: 1, animated: true)
                } else {
                    currentlySelectedDistanceSystem = distanceSystems[0]
                    hardPicker.selectRow(0, inComponent: 1, animated: true)
                    easyPicker.selectRow(0, inComponent: 1, animated: true)
                }
            }
        } else { // component == 0
            if pickerView == easyPicker {
                if row > hardPicker.selectedRowInComponent(0) {
                    hardPicker.selectRow(row, inComponent: 0, animated: true)
                    hardDistance = distances[row]
                }
                if row > impossiblePicker.selectedRowInComponent(0) {
                    impossiblePicker.selectRow(row, inComponent: 0, animated: true)
                    impossibleDistance = distances[row]
                }
                easyDistance = distances[row]
                //print("EasyDistance  " + easyDistance + " " + currentlySelectedDistanceSystem)
            }
            if pickerView == hardPicker {
                if row > impossiblePicker.selectedRowInComponent(0) {
                    impossiblePicker.selectRow(row, inComponent: 0, animated: true)
                    impossibleDistance = distances[row]
                }
                hardDistance = distances[row]
                //print("HardDistance  " + hardDistance + " " + currentlySelectedDistanceSystem)
            }
            if pickerView == impossiblePicker {
                impossibleDistance = distances[row]
                //print("ImpossibleDistance  " + impossibleDistance + " " + currentlySelectedDistanceSystem)
            }
            if pickerView == weightPickerView {
                if weightSystems[0] == weightSystems[weightPickerView.selectedRowInComponent(1)] {
                    weight = weightsImperial[row]
                }
                if weightSystems[1] == weightSystems[weightPickerView.selectedRowInComponent(1)] {
                    weight = weightsMetric[row]
                }
                //print("Weight " + weight + " " + currentlySelectedWeightSystem)
            }
            if pickerView == heightPickerView {
                if heightSystems[0] == heightSystems[heightPickerView.selectedRowInComponent(1)] {
                    height = heightsImperial[row]
                }
                if heightSystems[1] == heightSystems[heightPickerView.selectedRowInComponent(1)] {
                    height = heightsMetric[row]
                }
                //print("Height " + height + " " + currentlySelectedSystem)
            }
        }
    }
    @IBAction func saveUserInfo(sender: AnyObject) {
        
        let easyDistanceDouble = Double(easyDistance)
        let hardDistanceDouble = Double(hardDistance)
        let impossibleDistanceDouble = Double(impossibleDistance)
        
        cloudKitHelper.savePersonalSettings(deviceId, weight: weight, height: height, comfortableDistance: easyDistanceDouble!, difficultDistance: hardDistanceDouble!, impossibleDistance: impossibleDistanceDouble!, heightSystem: currentlySelectedSystem, weightSystem: currentlySelectedWeightSystem, distanceSystem: currentlySelectedDistanceSystem)
    }
    @IBAction func cancelChanges(sender: AnyObject) {
    // go back to menu page
    }
}