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
    
    var heightSystems = ["Metric","Imperial"]
    var heights = [String]()
    
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
        for i in 3 ... 9 {
            for j in 0...11 {
                heights[heightIndex] = "\(i)' \(j)''"
                heightIndex += 1
            }
        }
    }
    
    func userDidSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == systemHeightPickerView {
            return heightSystems.count
        } else if pickerView == heightPickerView {
            return heights.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == systemHeightPickerView {
            return heightSystems[row]
        } else if pickerView == heightPickerView {
            return heights[row]
        }
    }
}