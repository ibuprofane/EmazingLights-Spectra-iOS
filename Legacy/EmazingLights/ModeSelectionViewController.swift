//
//  ModeSelectionViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/24/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class ModeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var modeSlot:Int = -1
    var finger:Finger!
    var pageMode:PageMode = .Select // Select, Edit
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(pageMode == .Edit)
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ModeSelectionViewController.newMode))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("modeCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        
        //Set selection color for selected cell
        /*let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.purpleColor()
        cell.selectedBackgroundView = bgColorView*/
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        var mode:Mode!
        if(indexPath.section == 0)
        {
            mode = EmazingSettings.settings.stockModes[indexPath.row]
        }
        else
        {
            mode = EmazingSettings.settings.customModes[indexPath.row]
        }
        
        let nameLabel:UILabel = cell.viewWithTag(101) as! UILabel
        nameLabel.text = mode.name
        
        let copyModeButton:CopyModeButton = cell.viewWithTag(102) as! CopyModeButton
        if(pageMode == .Edit)
        {
            copyModeButton.modeIndex = indexPath.row
            copyModeButton.section = indexPath.section
            copyModeButton.hidden = false
        }
        else if(pageMode == .Select)
        {
            copyModeButton.hidden = true
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(section == 0)
        {
            return EmazingSettings.settings.stockModes.count
        }
        else if(section == 1)
        {
            return EmazingSettings.settings.customModes.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0)
        {
            return "EmazingLights Favorites"
        }
        else if(section == 1)
        {
            return "User-Created Modes"
        }
        else
        {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableCellWithIdentifier("modeHeaderCell")
        {
            let stockTitleLabel:UILabel = headerView.viewWithTag(100) as! UILabel
            let customTitleLabel:UILabel = headerView.viewWithTag(101) as! UILabel
            let infoLabel:UILabel = headerView.viewWithTag(102) as! UILabel
            
            if(section == 0)
            {
                stockTitleLabel.hidden = false
                customTitleLabel.hidden = true
                infoLabel.hidden = true
            }
            else
            {
                stockTitleLabel.hidden = true
                customTitleLabel.hidden = false
                infoLabel.hidden = false
            }
            
            //headerView.contentView.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
            return headerView.contentView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let customCount = EmazingSettings.settings.customModes.count
        if(customCount != 0)
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //Only custom modes can be deleted
        if(indexPath.section == 1)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            EmazingSettings.settings.customModes.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            
            if(EmazingSettings.settings.customModes.count > 0)
            {
                //Section is not yet empty, so delete only the current row
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            else
            {
                //Section is now completely empty, so delete the entire section
                tableView.deleteSections(NSIndexSet.init(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            tableView.endUpdates()
            
            EmazingSettings.settings.save() 
        }
        else
        {
            print("Unhandled editing style")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(pageMode == .Select)
        {
            if(finger != nil && modeSlot != -1)
            {
                if(indexPath.section == 0)
                {
                    finger.modes[modeSlot] = EmazingSettings.settings.stockModes[indexPath.row]
                }
                else if(indexPath.section == 1)
                {
                    finger.modes[modeSlot] = EmazingSettings.settings.customModes[indexPath.row]
                }
            }
            
            finger.otfModes[modeSlot] = nil
            
            self.navigationController?.popViewControllerAnimated(true)
        }
        else //Edit
        {
            let controller:ModeEditViewController = self.storyboard?.instantiateViewControllerWithIdentifier("modeEditView") as! ModeEditViewController
            controller.finger = finger
            if(indexPath.section == 0)
            {
                controller.mode = EmazingSettings.settings.stockModes[indexPath.row]
                controller.customModeSelected = false
                controller.displayMode = .DirectEdit
            }
            else if(indexPath.section == 1)
            {
                controller.mode = EmazingSettings.settings.customModes[indexPath.row]
                controller.customModeSelected = true
                controller.displayMode = .DirectEdit
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func copyModePressed(sender: AnyObject)
    {
        let copyButton:CopyModeButton = sender as! CopyModeButton
        var baseMode:Mode!
        if(copyButton.section == 0)
        {
            baseMode = EmazingSettings.settings.stockModes[copyButton.modeIndex]
        }
        else
        {
            baseMode = EmazingSettings.settings.customModes[copyButton.modeIndex]
        }
        
        createMode("Copy", baseMode: baseMode)
    }
    
    func newMode()
    {
        let baseMode = EmazingSettings.settings.basicStrobeRGBMode
        createMode("Create New", baseMode: baseMode)
    }
    
    private func createMode(type:String, baseMode:Mode)
    {
        let alertController = UIAlertController(title: "\(type) Mode", message: "Create and save a new mode with the current settings.", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.addTarget(self, action: #selector(ModeSelectionViewController.textChanged(_:)), forControlEvents: .EditingChanged)
            textField.placeholder = "New Mode Name"
            textField.keyboardType = .Default
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print(action)
        }
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            self.doSaveAs(nameTextField.text!, modeToCopy: baseMode)
        }
        alertController.addAction(okAction)
        
        (alertController.actions[1] as UIAlertAction).enabled = false
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textChanged(sender:AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as! UIAlertController
        (alert.actions[1] as UIAlertAction).enabled = (tf.text != "")
    }
    
    func doSaveAs(name:String, modeToCopy:Mode)
    {
        //Check for duplicate names
        var duplicateFound:Bool = false
        for mode in EmazingSettings.settings.customModes
        {
            if(mode.name.lowercaseString == name.lowercaseString)
            {
                duplicateFound = true
            }
        }
        for mode in EmazingSettings.settings.stockModes
        {
            if(mode.name.lowercaseString == name.lowercaseString)
            {
                duplicateFound = true
            }
        }
        
        if(!duplicateFound)
        {
            let modeCopy = modeToCopy.copyObject()
            modeCopy.name = name
            
            EmazingSettings.settings.customModes.append(modeCopy)
            EmazingSettings.settings.save()
            
            let indexPath = NSIndexPath(forRow: EmazingSettings.settings.customModes.count - 1, inSection: 1)
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        else
        {
            //Present notice to user
            let alertController = UIAlertController(title: "Duplicate Name", message: "A mode with this name already exists. Please choose a unique name.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
