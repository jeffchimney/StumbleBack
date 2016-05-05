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
    
    var heightSystems = ["cms","ft"]
    var weightSystems = ["kgs", "lbs"]
    var heightsImperial = [String]()
    var heightsMetric = [String]()
    var weightsImperial = [Double]()
    var weightsMetric = [Double]()
    
    var currentlySelectedSystem = "cms"
    var currentlySelectedWeightSystem = "kgs"
    
    @IBOutlet var systemWeightPickerView: UIPickerView!
    @IBOutlet var weightPickerView: UIPickerView!
    @IBOutlet weak var systemHeightPickerView: UIPickerView!
    @IBOutlet weak var heightPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuViewController.userDidSwipe(_:)))
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        self.view.addGestureRecognizer(swipeLeftRecognizer)
        
        systemHeightPickerView.dataSource = self
        heightPickerView.dataSource = self
        systemHeightPickerView.delegate = self
        heightPickerView.delegate = self
        
        var heightIndex = 0
        for i in 3 ... 8 {
            for j in 0...11 {
                heightsImperial.append("\(i)' \(j)''")
                heightIndex += 1
            }
        }
        for i in 100 ... 300 {
            heightsMetric.append("\(i)")
        }
        
        
        for i in 70 ... 400 {
            weightsImperial.append(Double(i))
            weightsMetric.append(Double(i) * 0.454)
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
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[0] {
            return heightsMetric.count
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[1] {
            return heightsMetric.count
        } else if pickerView == systemWeightPickerView {
            return weightSystems.count
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[0] {
            return weightsMetric.count
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[1] {
            return weightsMetric.count
        } else {
            return 1 // something went wrong
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == systemHeightPickerView {
            return heightSystems[row]
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[0] {
            return heightsMetric[row]
        } else if pickerView == heightPickerView && currentlySelectedSystem == heightSystems[1] {
            if row < heightsImperial.count {
                return heightsImperial[row]
            } else {
                return "-" // this is just a placehoder because the metric picker is bigger than the imperial picker
            }
        } else if pickerView == systemWeightPickerView {
            return weightSystems[row]
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[0] {
            return "\(weightsMetric[row])"
        } else if pickerView == weightPickerView && currentlySelectedWeightSystem == weightSystems[1] {
            return "\(weightsImperial[row])"
        }else {
            return "Something went wrong"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == systemHeightPickerView {
            if(row == 0) {
                currentlySelectedSystem = heightSystems[0]
                heightPickerView.selectRow(100, inComponent: 0, animated: true)
            } else {
                heightPickerView.selectRow(36, inComponent: 0, animated: true)
                currentlySelectedSystem = heightSystems[1]
            }
        } else if pickerView == heightPickerView {
            if currentlySelectedSystem == heightSystems[1] {
                if row > heightsImperial.count {
                    heightPickerView.selectRow(heightsImperial.count-1, inComponent: 0, animated: true)
                }
            }
        } else if pickerView == systemWeightPickerView  {
            if(row == 0) {
                currentlySelectedWeightSystem = weightSystems[0]
                weightPickerView.selectRow(100, inComponent: 0, animated: true)
            } else {
                weightPickerView.selectRow(100, inComponent: 0, animated: true)
                currentlySelectedWeightSystem = weightSystems[1]
            }
        }
    }
}