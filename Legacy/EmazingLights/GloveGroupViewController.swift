//
//  GloveGroupViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/10/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class GloveGroupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var charmButtons: Array<UIButton>!
    @IBOutlet var preselectedCharm: UIButton!
    
    var existingGroup:GloveGroup!
    var selectedCharm:String!
    var settingsViewController:SettingsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        
        //If the group already exists
        if(existingGroup != nil)
        {
            //If editing an existing group, set the background color for the selected charm
            selectedCharm = existingGroup.charm
            for charmButton in self.charmButtons
            {
                if(charmButton.titleLabel!.text! == selectedCharm)
                {
                    charmButton.backgroundColor = UIColor.blueColor()
                }
                else
                {
                    charmButton.backgroundColor = UIColor.whiteColor()
                }
            }
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GloveGroupViewController.saveGroup))
        }
        else //If this is a new group
        {
            self.preselectedCharm.backgroundColor = UIColor.blueColor()
            self.selectedCharm = self.preselectedCharm.titleLabel!.text!
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GloveGroupViewController.saveGroupAndAddGloves))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func saveGroup()
    {
        existingGroup.groupName = self.nameTextField.text!
        existingGroup.charm = selectedCharm
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveGroupAndAddGloves()
    {
        existingGroup = GloveGroup()
        existingGroup.groupName = self.nameTextField.text!
        existingGroup.charm = selectedCharm
        
        EmazingSettings.settings.gloveGroups.append(existingGroup)
        
        //Go to new glove view
        let controller:NewGloveViewController = self.storyboard?.instantiateViewControllerWithIdentifier("newGloveView") as! NewGloveViewController
        controller.gloveAction = "New"
        controller.gloveGroup = existingGroup
        controller.settingsViewController = self.settingsViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func charmSelected(sender: AnyObject)
    {
        for charmButton in self.charmButtons
        {
            charmButton.backgroundColor = UIColor.whiteColor()
        }
        
        let button:UIButton = sender as! UIButton
        selectedCharm = button.titleLabel!.text!
        button.backgroundColor = UIColor.blueColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return false
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
