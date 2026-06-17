//
//  SelectPhotoHubViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/12/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class SelectPhotoHubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SyncManagerDelegate {
    
    var chip:Chip!
    var selectedHub:String = ""
    @IBOutlet var tableView: UITableView!
    @IBOutlet var syncNowButton: UIButton!
    var syncWatchdogTimer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func checkButtonPressed(sender: AnyObject)
    {
        let button = sender as! CheckButton
        if(button.checkState == 0 && selectedHub == "") //First check will be Left
        {
            button.checkState = 1
            selectedHub = button.gloveUUID
        }
        else if(button.checkState == 1) //Uncheck Left
        {
            button.checkState = 0
            selectedHub = ""
        }
        
        if(selectedHub != "")
        {
            syncNowButton.hidden = false
        }
        else
        {
            syncNowButton.hidden = true
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func syncNowPressed(sender: AnyObject){
        self.syncNowButton.enabled = false
        self.syncNowButton.setTitle("Syncing...", forState: UIControlState.Disabled)
        
        if(syncWatchdogTimer != nil)
        {
            self.syncWatchdogTimer.invalidate()
            self.syncWatchdogTimer = nil
        }
        self.syncWatchdogTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: #selector(SelectPhotoHubViewController.syncFailed), userInfo: nil, repeats: false)
        EmazingCommManager.commManager.syncManager.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            EmazingCommManager.commManager.syncManager.prepareForSync(self.chip, uuid: self.selectedHub)
        })
        
    }
    
    func syncFailed()
    {
        syncFinished(false)
    }
    
    func syncFinished(completed:Bool)
    {
        if(syncWatchdogTimer != nil)
        {
            self.syncWatchdogTimer.invalidate()
            self.syncWatchdogTimer = nil
        }
        
        //EmazingCommManager.commManager.disconnectFromPhotoHubs()
        
        if(completed)
        {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.syncNowButton.enabled = true
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertController = UIAlertController(title: "Sync Failed", message: "The app could not sync to your device. Please ensure that the device is powered on and within range of your phone.", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) { }
                
                self.syncNowButton.enabled = true
                self.syncNowButton.setTitle("Sync Now", forState: UIControlState.Normal)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EmazingSettings.settings.photoHubs.count
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("foundHubCell", forIndexPath: indexPath)
        
        let gloveUUID:String = EmazingSettings.settings.photoHubs[indexPath.row].UUID
        let hubName:String = EmazingSettings.settings.photoHubs[indexPath.row].givenName
        
        let name:UILabel = cell.viewWithTag(100) as! UILabel
        name.text = hubName
        
        let checkButton:CheckButton = cell.viewWithTag(101) as! CheckButton
        checkButton.gloveUUID = gloveUUID
        
        if(selectedHub == name.text)
        {
            checkButton.setImage(UIImage(named: "PlainCheck"), forState: UIControlState.Normal)
            checkButton.checkState = 1
        }
        else
        {
            checkButton.setImage(UIImage(named: "EmptyCheck"), forState: UIControlState.Normal)
            checkButton.checkState = 0
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
