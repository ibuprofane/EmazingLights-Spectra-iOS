//
//  NewPhotoHubViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/7/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class NewPhotoHubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FoundPhotoHubsDelegate {
    
    var foundPhotoHubs:[PhotoHub] = []
    var settingsViewController:SettingsViewController!
    var selectedHub:String = ""
    var selectedHubName:String = ""
    var doDisconnectOnBack:Bool = true
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*self.navigationItem.hidesBackButton = true
        //let customBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewPhotoHubViewController.backButtonPressed))
        let customBackButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Back, target: self, action: #selector(NewPhotoHubViewController.backButtonPressed))
        self.navigationItem.leftBarButtonItem = customBackButton
        */
        
        EmazingCommManager.commManager.photoHubsDelegate = self
    }
    
    // Swift
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            if(doDisconnectOnBack)
            {
                backButtonPressed()
            }
        }
    }
    
    func backButtonPressed()
    {
        EmazingCommManager.commManager.stopHardwareScan()
        EmazingCommManager.commManager.disconnectFromPhotoHubs()
        //self.navigationController?.popToViewController(self.settingsViewController, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        EmazingCommManager.commManager.scanForHardware(EmazingConstants.constants.photoHubHardwareName, pairingMode: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        //EmazingCommManager.commManager.stopHardwareScan()
        //EmazingCommManager.commManager.disconnectFromPhotoHubs()
    }
    
    func updateFoundPhotoHubs(hubs: [PhotoHub]) {
        self.foundPhotoHubs = hubs
        self.tableView.reloadData()
    }
    
    @IBAction func checkButtonPressed(sender: AnyObject)
    {
        let button = sender as! CheckButton
        if(button.checkState == 0 && selectedHub == "") //First check will be Left
        {
            button.checkState = 1
            selectedHub = button.gloveUUID
            selectedHubName = button.hubName
        }
        else if(button.checkState == 1) //Uncheck Left
        {
            button.checkState = 0
            selectedHub = ""
            selectedHubName = ""
        }
        
        if(selectedHub != "")
        {
            //Show Save button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewPhotoHubViewController.savePhotoHub))
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.tableView.reloadData()
    }
    
    func savePhotoHub()
    {
        if(selectedHub != "")
        {
            let alertController = UIAlertController(title: "Name your device", message: "Please choose a unique name for your hardware (up to 12 characters).", preferredStyle: .Alert)
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.addTarget(self, action: #selector(NewPhotoHubViewController.textChanged(_:)), forControlEvents: .EditingChanged)
                textField.placeholder = "Name"
                textField.text = self.selectedHubName
                textField.keyboardType = .Default
                textField.autocapitalizationType = UITextAutocapitalizationType.Words
                textField.delegate = self
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                print(action)
            }
            
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                let nameTextField = alertController.textFields![0] as UITextField
                var customName = EmazingConstants.constants.photoHubDefaultDisplayName
                if(nameTextField.text != nil)
                {
                    customName = nameTextField.text!
                }
                
                //self.doSaveAs(nameTextField.text!, chipToCopy: chipToCopy)
                let photoHub = PhotoHub(uuid: self.selectedHub, name:customName)
                if(!EmazingSettings.settings.photoHubs.contains(photoHub))
                {
                    EmazingSettings.settings.photoHubs.append(photoHub)
                }
                
                EmazingSettings.settings.save()
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    EmazingCommManager.commManager.syncManager.setHubNameAndExitPairingMode(self.selectedHub, name: customName)
                })
                
                self.doDisconnectOnBack = false
                
                self.navigationController?.popToViewController(self.settingsViewController, animated: true)
            }
            alertController.addAction(okAction)
            
            //(alertController.actions[1] as UIAlertAction).enabled = false
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func textChanged(sender:AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as! UIAlertController
        (alert.actions[1] as UIAlertAction).enabled = (tf.text != "")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        return newString.length <= 12
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foundPhotoHubs.count
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("foundHubCell", forIndexPath: indexPath)
        
        let gloveUUID:String = self.foundPhotoHubs[indexPath.row].UUID
        let hubName:String = self.foundPhotoHubs[indexPath.row].givenName
        
        let name:UILabel = cell.viewWithTag(100) as! UILabel
        name.text = hubName
        
        let checkButton:CheckButton = cell.viewWithTag(101) as! CheckButton
        checkButton.gloveUUID = gloveUUID
        checkButton.hubName = hubName
        
        if(selectedHub == gloveUUID)
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
