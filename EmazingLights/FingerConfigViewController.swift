//
//  FingerConfigViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/30/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class FingerConfigViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var finger:Finger!
    @IBOutlet var tableView: UITableView!
    var fingerTitle:String = ""
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView?.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("modeCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        
        //Set color for selected cell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.purpleColor()
        cell.selectedBackgroundView = bgColorView
        
        let mode = finger.modes[indexPath.row]
        let disabled = finger.disabledModes[indexPath.row]
        
        titleLabel.text = fingerTitle
        
        let numberLabel:UILabel = cell.viewWithTag(101) as! UILabel
        numberLabel.text = "\(indexPath.row + 1)"
        
        let nameLabel:UILabel = cell.viewWithTag(102) as! UILabel
        nameLabel.text = mode.name
        
        if(disabled)
        {
            numberLabel.textColor = UIColor.grayColor()
            nameLabel.textColor = UIColor.grayColor()
        }
        else
        {
            numberLabel.textColor = UIColor.blackColor()
            nameLabel.textColor = UIColor.blackColor()
        }
        
        let editModeButton:ModeButton = cell.viewWithTag(201) as! ModeButton
        editModeButton.modeSlot = indexPath.row
        
        let switchModeButton:ModeButton = cell.viewWithTag(202) as! ModeButton
        switchModeButton.modeSlot = indexPath.row
        
        let disableModeButton:ModeButton = cell.viewWithTag(203) as! ModeButton
        disableModeButton.modeSlot = indexPath.row
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleEnableDisable(sender: AnyObject) {
        let button = sender as! ModeButton
        
        finger.disabledModes[button.modeSlot] = !(finger.disabledModes[button.modeSlot])
        
        self.tableView.reloadData()
    }
    
    @IBAction func switchModePressed(sender: AnyObject) {
        let button = sender as! ModeButton
        
        let controller:ModeSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("modeSelectionView") as! ModeSelectionViewController
        
        controller.pageMode = .Select
        controller.finger = finger
        controller.modeSlot = button.modeSlot
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func editModePressed(sender: AnyObject) {
        let button = sender as! ModeButton
        
        let controller:ModeEditViewController = self.storyboard?.instantiateViewControllerWithIdentifier("modeEditView") as! ModeEditViewController
        controller.mode = finger.modes[button.modeSlot]
        controller.finger = finger
        controller.displayMode = .Edit

        self.navigationController?.pushViewController(controller, animated: true)
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
