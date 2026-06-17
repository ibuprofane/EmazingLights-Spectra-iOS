//
//  SettingsViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/2/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var gloveTable: UITableView!
    @IBOutlet var updateFirmwareButton: UIButton!
    
    var gloveTableData = [GlovesTableObject]()
    var numberOfGloveSections:Int = 0
    var willShowGroups:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTableData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        loadTableData()
    }
    

    
    func loadTableData()
    {
        populateGloveTableData()
        gloveTable.reloadData()
    }
    
    func populateGloveTableData()
    {
        gloveTableData = []

        //TODO: Remove commenting once ProtoGloves are implemented
        /*
        if(EmazingSettings.settings.gloveGroups.count > 0)
        {
            for gloveGroup in EmazingSettings.settings.gloveGroups
            {
                self.gloveTableData.append(GlovesTableObject(cellType: "glovePairHeader", referenceGlovePair: gloveGroup))
                numberOfGloveSections++
                willShowGroups = true
                
                //There should only be 0, 1, or 2 gloves in a group
                if(gloveGroup.gloves.count == 0)
                {
                    self.gloveTableData.append(GlovesTableObject(cellType: "newGloveCell", referenceGlovePair: gloveGroup))
                }
                else if(gloveGroup.gloves.count == 1)
                {
                    self.gloveTableData.append(GlovesTableObject(cellType: "gloveCell", referenceGlovePair: gloveGroup, referenceGlove: gloveGroup.gloves[0]))
                    self.gloveTableData.append(GlovesTableObject(cellType: "newGloveCell", referenceGlovePair: gloveGroup))
                }
                else if(gloveGroup.gloves.count == 2)
                {
                    self.gloveTableData.append(GlovesTableObject(cellType: "gloveCell", referenceGlovePair: gloveGroup, referenceGlove: gloveGroup.gloves[0]))
                    self.gloveTableData.append(GlovesTableObject(cellType: "gloveCell", referenceGlovePair: gloveGroup, referenceGlove: gloveGroup.gloves[1]))
                }
            }
        }
        else //Active hub, but no groups
        {
            self.gloveTableData.append(GlovesTableObject(cellType: "newGroupCell"))
            numberOfGloveSections = 1
        }*/
        
        if(EmazingSettings.settings.photoHubs.count > 0)
        {
            for photoHub in EmazingSettings.settings.photoHubs
            {
                self.gloveTableData.append(GlovesTableObject(cellType: "photoHubCell", referencePhotoHub: photoHub))
            }
            
            updateFirmwareButton.hidden = false
        }
        else //No hubs
        {
            self.gloveTableData.append(GlovesTableObject(cellType: "newHubCell"))
            
            updateFirmwareButton.hidden = true
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let gloveTableObject = self.gloveTableData[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(gloveTableObject.cellType, forIndexPath: indexPath)
        
        if(gloveTableObject.cellType == "glovePairHeader")
        {
            let name:UILabel = cell.viewWithTag(100) as! UILabel
            name.text = gloveTableObject.referenceGlovePair?.groupName
            
            let charm:UILabel = cell.viewWithTag(101) as! UILabel
            charm.text = gloveTableObject.referenceGlovePair?.charm

            //Get invisible button with tag
            //Set glove pair object to custom button object
        }
        else if(gloveTableObject.cellType == "gloveCell")
        {
            let name:UILabel = cell.viewWithTag(100) as! UILabel
            name.text = gloveTableObject.referenceGlove?.givenName
            
            let uuid:UILabel = cell.viewWithTag(101) as! UILabel
            uuid.text = gloveTableObject.referenceGlove?.UUID
        }
        else if(gloveTableObject.cellType == "photoHubCell")
        {
            let name:UILabel = cell.viewWithTag(100) as! UILabel
            name.text = gloveTableObject.referencePhotoHub?.givenName
            
            let uuid:UILabel = cell.viewWithTag(101) as! UILabel
            uuid.text = gloveTableObject.referencePhotoHub?.UUID
            
            //let image:UIImageView = cell.viewWithTag(102) as! UIImageView
            //image.image = UIImage(named: "photoHubProductImage")
        }
        /*else if(gloveTableObject.cellType == "newGloveCell")
        {
            //TODO: Anything?
        }
        else if(gloveTableObject.cellType == "newHubCell")
        {
            //TODO: Anything?
        }*/
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let gloveTableObject = self.gloveTableData[indexPath.row]
        
        if(gloveTableObject.cellType == "gloveCell")
        {
            //Go to glove detail
            let controller:GloveInfoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveInfoView") as! GloveInfoViewController
            controller.glove = gloveTableObject.referenceGlove
            controller.gloveGroup = gloveTableObject.referenceGlovePair
            controller.settingsViewController = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if(gloveTableObject.cellType == "newGloveCell")
        {
            //Go to new glove view
            let controller:NewGloveViewController = self.storyboard?.instantiateViewControllerWithIdentifier("newGloveView") as! NewGloveViewController
            controller.gloveGroup = gloveTableObject.referenceGlovePair
            controller.gloveAction = "New"
            controller.settingsViewController = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if(gloveTableObject.cellType == "newGroupCell")
        {
            //Go to new group view
            newGloveSetPressed(nil)
        }
        else if(gloveTableObject.cellType == "glovePairHeader")
        {
            //Go to glove pair edit
            viewGloveSetInfo(gloveTableData[indexPath.row].referenceGlovePair!)
        }
        else if(gloveTableObject.cellType == "newHubCell")
        {
            //Go to new group view
            newHubPressed(nil)
        }
        else if(gloveTableObject.cellType == "photoHubCell")
        {
            //Go to hub detail
            let controller:PhotoHubInfoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("photoHubInfoView") as! PhotoHubInfoViewController
            controller.photoHub = gloveTableObject.referencePhotoHub
            controller.settingsViewController = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @IBAction func checkForFirmwarePressed(sender: AnyObject)
    {
        EmazingCommManager.commManager.firmwareUpdater.presentFirmwareUpdateView()
    }
    
    //MARK: - TableView Functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.gloveTableData.count
    }
    
    @IBAction func newGloveSetPressed(sender: AnyObject?)
    {
        let controller:GloveGroupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveGroupView") as! GloveGroupViewController
        controller.existingGroup = nil
        controller.settingsViewController = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func newHubPressed(sender: AnyObject?)
    {
        let controller:NewPhotoHubViewController = self.storyboard?.instantiateViewControllerWithIdentifier("newPhotoHubView") as! NewPhotoHubViewController
        controller.settingsViewController = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func viewGloveSetInfo(gloveGroup:GloveGroup)
    {
        let controller:GloveGroupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveGroupView") as! GloveGroupViewController
        controller.existingGroup = gloveGroup
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

class GlovesTableObject
{
    var cellType:String = ""
    var referenceGlovePair:GloveGroup?
    var referenceGlove:Glove?
    var referencePhotoHub:PhotoHub?
    
    init(cellType:String)
    {
        self.cellType = cellType
    }
    
    init(cellType:String, referenceGlovePair:GloveGroup)
    {
        self.cellType = cellType
        self.referenceGlovePair = referenceGlovePair
    }
    
    init(cellType:String, referenceGlovePair:GloveGroup, referenceGlove:Glove)
    {
        self.cellType = cellType
        self.referenceGlovePair = referenceGlovePair
        self.referenceGlove = referenceGlove
    }
    
    init(cellType:String, referencePhotoHub:PhotoHub)
    {
        self.cellType = cellType
        self.referencePhotoHub = referencePhotoHub
    }
}
