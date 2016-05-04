//
//  MenuTableViewController.swift
//  StumbleBack
//
//  Created by Jeff Chimney on 2016-04-27.
//  Copyright © 2016 Jeff Chimney. All rights reserved.
//

import Foundation
import UIKit

class SideMenuViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var transitionOperator = TransitionOperator()
    
    @IBOutlet var tableView   : UITableView!
    @IBOutlet var backgroundImage: UIImageView!
    
    var items : [NavigationModel]!
    var expanded = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.image = UIImage(named: "boozeShelf")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let item1 = NavigationModel(title: "MY ACCOUNT")
        let item2 = NavigationModel(title: "FRIENDS")
        let item3 = NavigationModel(title: "SETTINGS")
        let item4 = NavigationModel(title: "ABOUT")
        
        items = [item1, item2, item3, item4]
        expanded = [false, false, false, false]
        
        backgroundImage.userInteractionEnabled = true
        
        //--------- Gesture Recognizer Initialization ----------
        
        // set up gesture recognizers
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SideMenuViewController.imageTapped(_:)))
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuViewController.userDidSwipe(_:)))
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        //Add recognizers to view.
        backgroundImage.addGestureRecognizer(tapRecognizer)
        backgroundImage.addGestureRecognizer(swipeLeftRecognizer)
        tableView.addGestureRecognizer(swipeLeftRecognizer)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NavigationCell") as! NavigationCell
        
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item.title
        //cell.countLabel.text = item.count
        //cell.iconImageView.image = UIImage(named: item.icon)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //dismissViewControllerAnimated(true, completion: nil)
        switch indexPath.item {
        case 0:
            expanded = [true, false, false, false]
            toAccount()
            
        case 1:
            expanded = [false, true, false, false]
            toFriends()
        case 2:
            expanded = [false, false, true, false]
            toSettings()
        case 3:
            expanded = [false, false, false, true]
            toAbout()
        default: break
        }
    }
    
    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        //tappedImageView will be the image view that was tapped.
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let toViewController = segue.destinationViewController as UIViewController
        //self.modalPresentationStyle = UIModalPresentationStyle.Custom
        //toViewController.transitioningDelegate = transitionOperator
        
        if segue.identifier == "toSettings" {
            if let controller = segue.destinationViewController as? UIViewController {
                //controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 186)
            }
        }
    }
    
    func toAccount(){
        //performSegueWithIdentifier("toAccount", sender: self)
    }
    
    func toFriends(){
        //performSegueWithIdentifier("toFriends", sender: self)
    }
    
    func toSettings(){
        performSegueWithIdentifier("toSettings", sender: self)
    }
    
    func toAbout(){
        //performSegueWithIdentifier("toAbout", sender: self)
    }
}

class NavigationModel {
    
    var title : String!
    var count : String?
    
    init(title: String){
        self.title = title
    }
    
    init(title: String, count: String){
        
        self.title = title
        self.count = count
    }
}