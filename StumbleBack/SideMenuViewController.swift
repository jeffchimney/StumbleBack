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
    
    @IBOutlet var tableView   : UITableView!
    
    var items : [NavigationModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let item1 = NavigationModel(title: "MY ACCOUNT")
        let item2 = NavigationModel(title: "COMMENTS", count: "3")
        let item3 = NavigationModel(title: "FAVORITES")
        let item4 = NavigationModel(title: "SETTINGS")
        let item5 = NavigationModel(title: "ABOUT")
        
        items = [item1, item2, item3, item4, item5]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NavigationCell") as! NavigationCell
        
        //let item = items[indexPath.row]
        
        //cell.titleLabel.text = item.title
        //cell.countLabel.text = item.count
        //cell.iconImageView.image = UIImage(named: item.icon)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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