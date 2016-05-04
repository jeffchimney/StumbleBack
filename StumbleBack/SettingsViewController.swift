//
//  SettingsViewController.swift
//  StumbleBack
//
//  Created by Jeff Chimney on 2016-04-29.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UIViewController {
    
    var cloudKitHelper = CloudKitHelper()
    var deviceId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuViewController.userDidSwipe(_:)))
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        self.view.addGestureRecognizer(swipeLeftRecognizer)
    }
    
    func userDidSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        dismissViewControllerAnimated(true, completion: nil)
    }
}