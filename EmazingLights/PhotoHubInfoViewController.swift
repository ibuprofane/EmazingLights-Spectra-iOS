//
//  PhotoHubInfoViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/7/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class PhotoHubInfoViewController: UIViewController, UITextFieldDelegate, DeviceUpdateDelegate {
    
    var photoHub:PhotoHub!
    var settingsViewController:SettingsViewController!
    
    @IBOutlet var hubNameTextField: UITextField!
    @IBOutlet var removeHubButton: UIButton!
    @IBOutlet var batteryLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hubNameTextField.delegate = self
        photoHub.delegate = self
        
        EmazingCommManager.commManager.connectToKnownPhotoHub(photoHub.UUID)
        
        batteryLevelLabel.text = "\(photoHub.batteryLevel)%"
        hubNameTextField.text = photoHub.givenName
        
        //Show Save button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewPhotoHubViewController.savePhotoHub))
    }
    
    override func viewDidDisappear(animated: Bool) {
        EmazingCommManager.commManager.disconnectFromGloves()
    }
    
    func savePhotoHub()
    {
        if(hubNameTextField.text != "")
        {
            let customName = hubNameTextField.text!
            
            photoHub.givenName = customName
            EmazingSettings.settings.save()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.setHubNameAndExitPairingMode(self.photoHub.UUID, name: customName)
            })
            
            self.navigationController?.popToViewController(self.settingsViewController, animated: true)
        }
        else
        {
            let alertController = UIAlertController(title: "No device name", message: "Please enter a name for your hardware (up to 12 characters).", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        return newString.length <= 12
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func removePhotoHubPressed(sender: AnyObject) {
        
        for i in 0 ..< EmazingSettings.settings.photoHubs.count
        {
            if(EmazingSettings.settings.photoHubs[i].UUID == photoHub.UUID)
            {
                EmazingSettings.settings.photoHubs.removeAtIndex(i)
            }
        }
        
        EmazingSettings.settings.save()
        
        if(settingsViewController != nil)
        {
            self.navigationController?.popToViewController(self.settingsViewController, animated: true)
        }
        else
        {
            print("Could not pop to SettingsViewController (it equals nil).")
        }
    }
    
    func batteryUpdated(value:Int)
    {
        self.batteryLevelLabel.text = "\(photoHub.batteryLevel)%"
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