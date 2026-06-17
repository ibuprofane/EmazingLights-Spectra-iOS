//
//  NewGloveViewController
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/8/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class NewGloveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FoundGlovesDelegate {
    
    var gloveGroup:GloveGroup!
    var foundGloves:[Glove] = []
    var gloveAction:String = "" //New, View, Change
    var settingsViewController:SettingsViewController!
    var selectedGloves:[Int:String] = [0:"", 1:""]
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        EmazingCommManager.commManager.glovesDelegate = self
        
        if(gloveGroup.gloves.count >= 1)
        {
            selectedGloves[0] = gloveGroup.gloves[0].UUID
        }
        if(gloveGroup.gloves.count >= 2)
        {
            selectedGloves[1] = gloveGroup.gloves[1].UUID
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        EmazingCommManager.commManager.scanForHardware(EmazingConstants.constants.gloveHardwareName, pairingMode: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        EmazingCommManager.commManager.stopHardwareScan()
    }
    
    func updateFoundGloves(gloves:[Glove])
    {
        self.foundGloves = gloves
        self.tableView.reloadData()
    }
    
    @IBAction func checkButtonPressed(sender: AnyObject)
    {
        let button = sender as! CheckButton
        if(button.checkState == 0 && selectedGloves[0] == "") //First check will be Left
        {
            button.checkState = 1
            selectedGloves[0] = button.gloveUUID
        }
        else if(button.checkState == 0 && selectedGloves[0] != "" && selectedGloves[1] == "") //Second check will be Right
        {
            button.checkState = 2
            selectedGloves[1] = button.gloveUUID
        }
        else if(button.checkState == 1) //Uncheck Left
        {
            button.checkState = 0
            selectedGloves[0] = ""
        }
        else if(button.checkState == 2) //Uncheck Right
        {
            button.checkState = 0
            selectedGloves[1] = ""
        }
        
        if(selectedGloves[0] != "" || selectedGloves[1] != "")
        {
            //Show Save button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewGloveViewController.saveGloves))
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.tableView.reloadData()
    }
    
    func saveGloves()
    {
        self.gloveGroup.gloves = []
        
        if(selectedGloves[0] != "")
        {
            let leftGlove = Glove(uuid: selectedGloves[0]!, name:"Lefty")
            self.gloveGroup.gloves.append(leftGlove)
        }
        
        if(selectedGloves[1] != "")
        {
            let rightGlove = Glove(uuid: selectedGloves[1]!, name:"Righty")
            self.gloveGroup.gloves.append(rightGlove)
        }
        
        self.navigationController?.popToViewController(self.settingsViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundGloves.count
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("foundGloveCell", forIndexPath: indexPath)
        
        let gloveUUID:String = self.foundGloves[indexPath.row].UUID
        
        let name:UILabel = cell.viewWithTag(100) as! UILabel
        name.text = gloveUUID
        
        let checkButton:CheckButton = cell.viewWithTag(101) as! CheckButton
        checkButton.gloveUUID = gloveUUID
        
        if(selectedGloves[0] == name.text)
        {
            checkButton.setImage(UIImage(named: "LeftCheck"), forState: UIControlState.Normal)
            checkButton.checkState = 1
        }
        else if(selectedGloves[1] == name.text)
        {
            checkButton.setImage(UIImage(named: "RightCheck"), forState: UIControlState.Normal)
            checkButton.checkState = 2
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
