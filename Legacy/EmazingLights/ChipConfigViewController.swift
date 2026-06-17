//
//  FingerConfigViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/30/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class ChipConfigViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SyncManagerDelegate {
    
    var chip:Chip!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet var editButton:UIButton!
    @IBOutlet var titleEditField: UITextField!
    @IBOutlet var footerView: UIView!
    @IBOutlet var syncButton: UIButton!
    var headerHeightConstraint:NSLayoutConstraint!
    var footerHeightConstraint:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let editButtonFrame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.frame.height + 10, imageView.frame.width, 30)
        editButton = UIButton(frame: editButtonFrame)
        editButton.hidden = false
        editButton.layer.borderColor = UIColor.blueColor().CGColor
        editButton.layer.borderWidth = 2.0
        editButton.layer.cornerRadius = 5.0
        editButton.setTitle("Edit", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        //editButton.titleLabel?.font = moreButton.titleLabel?.font
        editButton.addTarget(self, action: "editButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.headerView.addSubview(editButton)*/
        
        syncButton.layer.borderColor = UIColor.yellowColor().CGColor
        syncButton.layer.borderWidth = 2.0
        syncButton.layer.cornerRadius = 5.0
        
        descriptionTextView.layer.borderColor = UIColor.whiteColor().CGColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.clipsToBounds = true
        
        headerHeightConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 90)
        self.view.addConstraint(headerHeightConstraint)
        
        footerHeightConstraint = NSLayoutConstraint(item: footerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UIScreen.mainScreen().bounds.height / 8)
        self.view.addConstraint(footerHeightConstraint)
        
        titleLabel.text = chip.name
        imageButton.setBackgroundImage(chip.image, forState: UIControlState.Normal)

        //TODO: Uncomment
        //descriptionTextView.text = chip.description
        
        self.descriptionTextView.textContainerInset = UIEdgeInsetsZero
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Defaults", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChipConfigViewController.restoreDefaults))
    }
    
    func restoreDefaults()
    {
        let alert = UIAlertController(title: "Restore Modes to Default?", message: "This will delete your existing settings for this set. Are you sure you want to continue?", preferredStyle: .Alert) // 1
        let firstAction = UIAlertAction(title: "Yes", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            self.chip.finger = self.chip.fingerDataForRestore.copyObject()
            self.tableView.reloadData()
        }
        
        let secondAction = UIAlertAction(title: "No", style: .Default) { (alert: UIAlertAction!) -> Void in
            print("Canceled")
        }
        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        presentViewController(alert, animated: true, completion:nil) // 6
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView?.reloadData()
        
        //EmazingCommManager.commManager.syncManager.turnOffPreview()
        //EmazingCommManager.commManager.forceSyncCancel = true
    }
    
    override func viewDidLayoutSubviews()
    {
        self.setTextExclusionPath()
    }
    
    var infoPanelOpen:Bool = false
    @IBAction func moreButtonPressed(sender: AnyObject)
    {
        if(editingDescription && infoPanelOpen)
        {
            updateDescriptionEditing(false)
        }
        updateHeaderState(!infoPanelOpen)
    }
    
    private func updateHeaderState(open:Bool)
    {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.LayoutSubviews, animations: { () -> Void in
            
            var moreButtonFrame = self.moreButton.frame
            
            if(open)
            {
                self.headerHeightConstraint.constant += 110
                self.view.setNeedsLayout()
                moreButtonFrame.origin.y += 110
                self.moreButton.setTitle("Less", forState: UIControlState.Normal)
                self.editButton.hidden = false
                self.editButton.setTitle("Edit", forState: UIControlState.Normal)
            }
            else
            {
                self.headerHeightConstraint.constant -= 110
                self.view.setNeedsLayout()
                moreButtonFrame.origin.y -= 110
                self.moreButton.setTitle("More", forState: UIControlState.Normal)
                self.editButton.hidden = true
            }
            
            self.moreButton.frame = moreButtonFrame
            
            }) { (completed) -> Void in
                
                self.setTextExclusionPath()
        }
        
        //print("HeaderView Frame: \(headerView.frame)")
        
        infoPanelOpen = open
    }
    
    var editingDescription:Bool = false
    @IBAction func editButtonPressed()
    {
        updateDescriptionEditing(!editingDescription)
    }
    
    func updateDescriptionEditing(shouldEdit:Bool)
    {
        if(shouldEdit)
        {
            descriptionTextView.editable = true
            descriptionTextView.selectable = true
            descriptionTextView.backgroundColor = UIColor.whiteColor()
            descriptionTextView.textColor = UIColor.blackColor()
            descriptionTextView.layer.borderWidth = 2.0
            editButton.setTitle("Done", forState: UIControlState.Normal)
            titleEditField.text = titleLabel.text
            titleEditField.hidden = false
            titleLabel.hidden = true
        }
        else
        {
            descriptionTextView.editable = false
            descriptionTextView.selectable = false
            descriptionTextView.backgroundColor = UIColor.clearColor()
            descriptionTextView.textColor = UIColor.whiteColor()
            descriptionTextView.layer.borderWidth = 0.0
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            titleLabel.text = titleEditField.text
            titleEditField.hidden = true
            titleLabel.hidden = false
        }
        editingDescription = shouldEdit
    }
    
    func setTextExclusionPath()
    {
        //Set the exclusion path to ensure description text and More/Less button don't overlap
        let moreRect:CGRect = self.descriptionTextView.convertRect(self.moreButton.bounds, fromView: self.moreButton)
        let moreRectPath = UIBezierPath(rect: moreRect)
        self.descriptionTextView.textContainer.exclusionPaths = [moreRectPath]
    }
    
    @IBAction func imageButtonPressed(sender: AnyObject)
    {
        print("Image button pressed")
    }
    
    var syncWatchdogTimer:NSTimer!
    @IBAction func syncToPhotoChipsPressed(sender: AnyObject)
    {
        EmazingCommManager.commManager.forceSyncCancel = false
        
        if(EmazingSettings.settings.photoHubs.count == 1)
        {
            let controller:SyncPopupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("syncPopupController") as! SyncPopupViewController
            controller.chip = self.chip
            
            self.presentViewController(controller, animated: true, completion: { () -> Void in
                //...
            })
        }
        else
        {
            print("Proceed to Sync PhotoChips flow")
            let controller:SelectPhotoHubViewController = self.storyboard?.instantiateViewControllerWithIdentifier("selectPhotoHubView") as! SelectPhotoHubViewController
            controller.chip = self.chip
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
                self.syncButton.enabled = true
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
                
                self.syncButton.enabled = true
                self.syncButton.setTitle("Sync Now", forState: UIControlState.Normal)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("modeCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        
        //Set color for selected cell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor() //UIColor.purpleColor()
        cell.selectedBackgroundView = bgColorView
        
        let mode = chip.finger.modes[indexPath.row]
        let numberLabel:UILabel = cell.viewWithTag(101) as! UILabel
        numberLabel.text = "\(indexPath.row + 1)"
        
        let nameLabel:UILabel = cell.viewWithTag(102) as! UILabel
        if(chip.finger.otfModes[indexPath.row] != nil)
        {
            nameLabel.text = "Custom Mode"
        }
        else
        {
            nameLabel.text = mode.name
        }

        let disabled = chip.finger.disabledModes[indexPath.row]
        
        let disableModeButton:ModeButton = cell.viewWithTag(203) as! ModeButton
        disableModeButton.modeSlot = indexPath.row
        
        let disableModeLabel:UILabel = cell.viewWithTag(205) as! UILabel
        
        let editModeButton:ModeButton = cell.viewWithTag(201) as! ModeButton
        editModeButton.modeSlot = indexPath.row
        
        let switchModeButton:ModeButton = cell.viewWithTag(202) as! ModeButton
        switchModeButton.modeSlot = indexPath.row
        
        let modeMotionButton:ModeButton = cell.viewWithTag(204) as! ModeButton
        modeMotionButton.modeSlot = indexPath.row
        
        if(disabled)
        {
            numberLabel.textColor = UIColor.grayColor()
            nameLabel.textColor = UIColor.grayColor()
            switchModeButton.enabled = false
            modeMotionButton.enabled = false
            disableModeButton.setImage(UIImage(named: "enable"), forState: UIControlState.Normal)
            disableModeLabel.text = "Enable"
        }
        else
        {
            numberLabel.textColor = UIColor.blackColor()
            nameLabel.textColor = UIColor.blackColor()
            switchModeButton.enabled = true
            modeMotionButton.enabled = true
            disableModeButton.setImage(UIImage(named: "disable"), forState: UIControlState.Normal)
            disableModeLabel.text = "Disable"
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chip.finger.modes.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleEnableDisable(sender: AnyObject) {
        let button = sender as! ModeButton
        
        chip.finger.disabledModes[button.modeSlot] = !(chip.finger.disabledModes[button.modeSlot])
        
        self.tableView.reloadData()
    }
    
    @IBAction func switchModePressed(sender: AnyObject) {
        let button = sender as! ModeButton
        
        let controller:ModeSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("modeSelectionView") as! ModeSelectionViewController
        
        controller.pageMode = .Select
        controller.finger = chip.finger
        controller.modeSlot = button.modeSlot
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func editModePressed(sender: AnyObject) {
        let button = sender as! ModeButton
        
        let controller:ModeEditViewController = self.storyboard?.instantiateViewControllerWithIdentifier("modeEditView") as! ModeEditViewController
        
        if let modeToEdit = chip.finger.otfModes[button.modeSlot]
        {
            controller.mode = modeToEdit
            controller.usingOTFMode = true
        }
        else
        {
            controller.mode = chip.finger.modes[button.modeSlot]
            controller.usingOTFMode = false
        }
        controller.modeSlot = button.modeSlot
        controller.finger = chip.finger
        controller.displayMode = .Edit
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func editMotionPressed(sender: AnyObject)
    {
        let button = sender as! ModeButton
        
        let controller:MotionSettingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("motionEditView") as! MotionSettingViewController
        controller.mode = chip.finger.modes[button.modeSlot]
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func chipSetingsPressed(sender: AnyObject)
    {
        let controller:ChipSettingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("chipSettingsView") as! ChipSettingsViewController

        controller.finger = chip.finger
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "iconHeaderSegue")
        {
            let iconHeaderVC = segue.destinationViewController as! IconHeaderViewController
            iconHeaderVC.titleString = chip.name
            iconHeaderVC.descriptionString = chip.description
            iconHeaderVC.imageName = chip.imageName
            iconHeaderVC.parentVC = self
        }
    }
    */
    
}
