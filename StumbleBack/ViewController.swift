//
//  ViewController.swift
//  StumbleBack
//
//  Created by Jeff Chimney on 2016-04-25.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var stumbleButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stumbleButton.layer.zPosition = 1
    }
}

