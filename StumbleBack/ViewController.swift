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

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    
    @IBOutlet weak var menuSlider: UIImageView!
    @IBOutlet weak var tabBar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let stumbleButton = UIButton(type: UIButtonType.Custom)
    
    var transitionOperator = TransitionOperator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // set up map location and zoom
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //locationManager delegate method
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue : CLLocationCoordinate2D = manager.location!.coordinate;
        //var span = MKCoordinateSpanMake(0.075, 0.075)
        let long = locValue.longitude;
        let lat = locValue.latitude;
        print(long);
        print(lat);
        centerMapOnLocation(locations.last!)
        locationManager.stopUpdatingLocation();
    }
    //locationManager delegate method
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            print("You selected a pin")
        }
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
    
    func userDidSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == UISwipeGestureRecognizerDirection.Right {
            performSegueWithIdentifier("presentNav", sender: self)
        }
    }
    
    @IBAction func presentNavigation(sender: AnyObject?){
        performSegueWithIdentifier("presentNav", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let toViewController = segue.destinationViewController as UIViewController
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        toViewController.transitioningDelegate = transitionOperator
    }
}

extension ViewController: HandleMapSearch {
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
    }
}

extension ViewController : MKMapViewDelegate {
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
        button.addTarget(self, action: "getDirections", forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
