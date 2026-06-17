//
//  GloveInfoViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/9/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class GloveInfoViewController: UIViewController, UITextFieldDelegate, DeviceUpdateDelegate {

    var glove:Glove!
    var gloveGroup:GloveGroup!
    var settingsViewController:SettingsViewController!
    
    @IBOutlet var gloveNameTextField: UITextField!
    @IBOutlet var removeGloveButton: UIButton!
    @IBOutlet var batteryLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gloveNameTextField.delegate = self
        glove.delegate = self

        EmazingCommManager.commManager.connectToKnownGlove(glove)
        
        batteryLevelLabel.text = "\(glove.batteryLevel)%"
        gloveNameTextField.text = glove.givenName
    }
    
    override func viewDidDisappear(animated: Bool) {
        EmazingCommManager.commManager.disconnectFromGloves()
    }
    
    @IBAction func removeGlovePressed(sender: AnyObject) {
    
        for i in 0 ..< gloveGroup.gloves.count
        {
            if(gloveGroup.gloves[i].UUID == glove.UUID)
            {
                gloveGroup.gloves.removeAtIndex(i)
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
        self.batteryLevelLabel.text = "\(glove.batteryLevel)%"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        gloveNameTextField.resignFirstResponder()
        return false
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
