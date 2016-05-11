//
//  ViewController.swift
//  StumbleBack
//
//  Created by Jeff Chimney on 2016-04-25.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//
// CustomSegue class is at the bottom

import UIKit
import MapKit
import CloudKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, HandleMapSearch {
    
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    
    var timer = NSTimer()
    var uiTimer = NSTimer()
    var circleTimer = NSTimer()
    
    @IBOutlet weak var menuSlider: UIImageView!
    @IBOutlet weak var tabBar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let stumbleButton = UIButton(type: UIButtonType.Custom)
    
    var comfortableDistance: CLLocationDistance = 0
    var difficultDistance: CLLocationDistance  = 0
    var wontWalkFartherThanDistance: CLLocationDistance  = 0
    
    var transitionOperator = TransitionOperator()
    
    var innerCircle: MKCircle = MKCircle()
    var middleCircle: MKCircle = MKCircle()
    var outerCircle: MKCircle = MKCircle()
    
    var innerOverlay:MKOverlay = MKCircle()
    var middleOverlay:MKOverlay = MKCircle()
    var outerOverlay:MKOverlay = MKCircle()
    //var deviceId = ""
    
    var cloudKitHelper = CloudKitHelper()
    var drunkLevel = 0
    
    
    // ---------------------------------------------------------------------
    // ------------------ DID LOAD/LAYOUT SUBVIEWS  (SETUP) ----------------
    // ---------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // user info
        let deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        //print(deviceId)
        cloudKitHelper.saveDeviceIdRecord(deviceId)
        
        // Assign our search table view controller to handle to searches
        let searchResultsViewController = storyboard!.instantiateViewControllerWithIdentifier("SearchTableViewController") as! SearchTableViewController
        resultSearchController = UISearchController(searchResultsController: searchResultsViewController)
        resultSearchController?.searchResultsUpdater = searchResultsViewController
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Where you stumblin' to?"
        navigationItem.titleView = resultSearchController?.searchBar
        
        // set up search bar appearance
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        //hook up table view controller to the map view
        searchResultsViewController.mapView = mapView
        
        searchResultsViewController.handleMapSearchDelegate = self
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            mapView.mapType = MKMapType(rawValue: 0)!
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        }
        
        menuSlider.image = UIImage(named: "menuSlider")
        menuSlider.userInteractionEnabled = true
        
        // add taprecognizerto backgroundImage to return to main view
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.userDidSwipe(_:)))
        //Add the recognizer to your view.
        menuSlider.addGestureRecognizer(swipeRecognizer)
        
        var height = cloudKitHelper.getHeight(deviceId)
        print(height)
        print("Hi")
        
        //var comfortableWalkDistance: CKRecordValue = result["DeviceId"]!
        //print(comfortableWalkDistance)
        
        //this wont always be hard coded.
        comfortableDistance = 1000
        difficultDistance = 2000
        wontWalkFartherThanDistance = 2500
        
        drunkLevel = Int(arc4random_uniform(4))
        
        /* for drunk level 1, UI is green
        if drunkLevel == 0 {
            tabBar.barTintColor = UIColor.greenColor()
            navigationController?.navigationBar.barTintColor = UIColor.greenColor()
        } else if drunkLevel == 1 {
            // for drunk level 2
            tabBar.barTintColor = UIColor.yellowColor()
            navigationController?.navigationBar.barTintColor = UIColor.yellowColor()
        } else if drunkLevel == 2 {
            // for drunk level 3
            tabBar.barTintColor = UIColor.orangeColor()
            navigationController?.navigationBar.barTintColor = UIColor.orangeColor()
        } else {
            // for drunk level 4
            tabBar.barTintColor = UIColor.redColor()
            navigationController?.navigationBar.barTintColor = UIColor.redColor()
        } */
        
        updateUIColor()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateWalkingRadiusBasedOnLocation), userInfo: nil, repeats: true)
        uiTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateUIColor), userInfo: nil, repeats: true)
        circleTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateCircleColor), userInfo: nil, repeats: true)
    }
    
    var viewLayedOutSubviews = false
    // layout subviews that rely on screen size constraints
    override func viewDidLayoutSubviews() {
        // set up center button
        let stumbleImage = UIImage(named: "stumble")
        stumbleButton.frame = CGRectMake(0, 0, 75, 75)
        stumbleButton.setImage(stumbleImage, forState: .Normal)
        stumbleButton.addTarget(self, action: #selector(ViewController.stumblePressed(_:)), forControlEvents: .TouchUpInside)
        
        stumbleButton.center.x = tabBar.center.x
        stumbleButton.center.y = tabBar.center.y - self.view.frame.height/40
        
        self.view.addSubview(stumbleButton)
        viewLayedOutSubviews = true
    }
    
    var loading = false
    func stumblePressed(sender: UIButton) {
        // stumble
        loading = true
        if loading {
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
                sender.transform = CGAffineTransformRotate(sender.transform, CGFloat(M_PI_2))
            }) { (finished) -> Void in
                self.stumblePressed(sender)
            }
        }
    }
    
    func finishedLoading() {
        loading = false
    }
    
    // ---------------------------------------------------------------------
    // ----------------------- NAVIGATION FUNCTIONS ------------------------
    // ---------------------------------------------------------------------
    
    func userDidSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == UISwipeGestureRecognizerDirection.Right {
            loading = false
            performSegueWithIdentifier("presentNav", sender: self)
        }
    }
    
    func presentNavigation(){
        performSegueWithIdentifier("presentNav", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        toViewController.transitioningDelegate = transitionOperator
    }
    
    // update UIColor based on time of day
    func updateUIColor() {
        let currentCodeInt: Int = getHexValueForCurrentTime()
        tabBar.barTintColor = UIColor(netHex: currentCodeInt)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: currentCodeInt)
    }
    
    func getHexValueForCurrentTime() -> Int {
        var date = NSDate()
        var calendar = NSCalendar.currentCalendar()
        var components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
        var hour = components.hour
        var minutes = components.minute
        var seconds = components.second
        
        var currentCode = "\(hour)\(minutes)\(seconds)"
        if (hour < 10) && (minutes < 10) && (seconds < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let hourString = "0\(hour)"
            let minutesString = "0\(minutes)"
            let secondsString = "0\(seconds)"
            currentCode = "\(hourString)\(minutesString)\(secondsString)"
        } else if (hour < 10) && (minutes < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let hourString = "0\(hour)"
            let minutesString = "0\(minutes)"
            currentCode = "\(hourString)\(minutesString)\(seconds)"
        } else if (hour < 10) && (seconds < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let hourString = "0\(hour)"
            let secondsString = "0\(seconds)"
            currentCode = "\(hourString)\(minutes)\(secondsString)"
        } else if (minutes < 10) && (seconds < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let minutesString = "0\(minutes)"
            let secondsString = "0\(seconds)"
            currentCode = "\(hour)\(minutesString)\(secondsString)"
        } else if (hour < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let hourString = "0\(hour)"
            currentCode = "\(hourString)\(minutes)\(seconds)"
        } else if (minutes < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let minutesString = "0\(minutes)"
            currentCode = "\(hour)\(minutesString)\(seconds)"
        } else if (seconds < 10) {
            date = NSDate()
            calendar = NSCalendar.currentCalendar()
            components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
            hour = components.hour
            minutes = components.minute
            seconds = components.second
            
            let secondsString = "0\(seconds)"
            currentCode = "\(hour)\(minutes)\(secondsString)"
        }
        let currentCodeInt: Int = Int(currentCode)!
        return currentCodeInt
    }
    
    // --------------------------------------------------------------
    // ----------------------- MAP FUNCTIONS ------------------------
    // --------------------------------------------------------------
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        // ste the name of the UIImage to the button you'd like to show up when a pin is pressed.
        button.setBackgroundImage(UIImage(named: "stumble"), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            print("You selected a pin")
        }
    }
    
    // set up map location and zoom
    let regionRadius: CLLocationDistance = 5000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //locationManager delegate method
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let locValue : CLLocationCoordinate2D = manager.location!.coordinate;
        //var span = MKCoordinateSpanMake(0.075, 0.075)
        //let long = locValue.longitude;
        //let lat = locValue.latitude;
        centerMapOnLocation(locations.last!)
        
        locationManager.stopUpdatingLocation();
    }
    //locationManager delegate method
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            
            if overlay == innerCircle {
                innerOverlay = overlay
                let circleRenderer = MKCircleRenderer(circle: overlay)
                let currentColor = getHexValueForCurrentTime()
                circleRenderer.fillColor = UIColor(netHex: currentColor)
                circleRenderer.alpha = 0.5
                return circleRenderer
            } else if overlay == middleCircle {
                middleOverlay = overlay
                let circleRenderer = MKCircleRenderer(circle: overlay)
                let currentColor = getHexValueForCurrentTime()
                circleRenderer.fillColor = UIColor(netHex: currentColor)
                circleRenderer.alpha = 0.25
                return circleRenderer
            } else if overlay == outerCircle {
                outerOverlay = overlay
                let circleRenderer = MKCircleRenderer(circle: overlay)
                let currentColor = getHexValueForCurrentTime()
                circleRenderer.fillColor = UIColor(netHex: currentColor)
                circleRenderer.alpha = 0.125
                return circleRenderer
            }
        }
        let defaultCircle = MKCircleRenderer()
        return defaultCircle
    }
    
    func updateCircleColor() {
        if let renderer = mapView.rendererForOverlay(innerOverlay) as? MKCircleRenderer {
            let colorValue = getHexValueForCurrentTime()
            renderer.fillColor = UIColor(netHex: colorValue)
            renderer.alpha = 0.5
        }
        if let renderer = mapView.rendererForOverlay(middleOverlay) as? MKCircleRenderer {
            let colorValue = getHexValueForCurrentTime()
            renderer.fillColor = UIColor(netHex: colorValue)
            renderer.alpha = 0.25
        }
        if let renderer = mapView.rendererForOverlay(outerOverlay) as? MKCircleRenderer {
            let colorValue = getHexValueForCurrentTime()
            renderer.fillColor = UIColor(netHex: colorValue)
            renderer.alpha = 0.125
        }
    }
    
    func updateWalkingRadiusBasedOnLocation() {
        let userLocLat = mapView.userLocation.coordinate.latitude
        let userLocLong = mapView.userLocation.coordinate.longitude
        let userLoc = CLLocationCoordinate2DMake(userLocLat, userLocLong)
        
        let radius1 = CLLocationDistance(comfortableDistance)
        let radius2 = CLLocationDistance(difficultDistance)
        let radius3 = CLLocationDistance(wontWalkFartherThanDistance)
        
        innerCircle = MKCircle(centerCoordinate: userLoc, radius: radius1)
        middleCircle = MKCircle(centerCoordinate: userLoc, radius: radius2)
        outerCircle = MKCircle(centerCoordinate: userLoc, radius: radius3)
        
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(innerCircle)
        mapView.addOverlay(middleCircle)
        mapView.addOverlay(outerCircle)
    }
    
    // Map Search Pin Drop
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let distanceInMeters = locationManager.location?.distanceFromLocation(placemark.location!)
        if (distanceInMeters <= comfortableDistance) {
            print("Easy Peasy")
        } else if distanceInMeters <= difficultDistance && distanceInMeters > comfortableDistance {
            print("Go Ahead")
        } else if distanceInMeters <= wontWalkFartherThanDistance && distanceInMeters > difficultDistance {
            print("Uhh...good luck.")
        } else {
            print("Don't fucking do it.")
        }
    }
    
    @IBAction func homeButton(sender: AnyObject) {
        tabBar.barTintColor = UIColor.blueColor()
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
