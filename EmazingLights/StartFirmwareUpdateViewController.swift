//
//  StartFirmwareUpdateViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/4/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class StartFirmwareUpdateViewController: UIViewController, FirmwareStatusDelegate, GlovesConnectionStatusDelegate {

    var firmwareUpdater:FirmwareUpdater!
    var dismissWhenShown:Bool = false
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var checkingForUpdatesLabel: UILabel!
    @IBOutlet var startUpdateButton: UIButton!
    @IBOutlet var upToDateImage: UIImageView!
    @IBOutlet var searchForHardwareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firmwareUpdater.statusDelegate = self
        self.firmwareUpdater.commManager.gloveConnectionStatusDelegate = self
        self.searchForHardware(nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(dismissWhenShown)
        {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func searchForHardware(sender: AnyObject?)
    {
        self.searchForHardwareButton.hidden = true
        self.activityIndicator.hidden = false
        self.checkingForUpdatesLabel.text = "Checking for updates"
        
        //TODO: Choose a hub to connect
        //EmazingCommManager.commManager.connectToKnownHub(EmazingSettings.settings.activeGloveHub)
        
        //HACK: use first hub
        let hub:PhotoHub = EmazingSettings.settings.photoHubs[0]
        EmazingCommManager.commManager.connectToKnownPhotoHub(hub.UUID)
    }

    func firmwareVersionChecked(newFirmwareAvailable:Bool)
    {
        if(newFirmwareAvailable)
        {
            self.activityIndicator.hidden = true
            self.checkingForUpdatesLabel.text = "An update is available for your hardware."
            self.upToDateImage.hidden = true
            self.startUpdateButton.hidden = false
        }
        else
        {
            self.activityIndicator.hidden = true
            self.checkingForUpdatesLabel.text = "Everything is up to date!"
            self.upToDateImage.hidden = false
            self.startUpdateButton.hidden = true
        }
    }
    
    func gloveConnectionStatus(status:String)
    {
        if(status == "Timed Out")
        {
            self.activityIndicator.hidden = true
            self.checkingForUpdatesLabel.text = "Could not find hardware. Ensure that..."
            self.upToDateImage.hidden = true
            self.startUpdateButton.hidden = true
            self.searchForHardwareButton.hidden = false
        }
    }
    
    @IBAction func closeFirmwareUpdate(sender: AnyObject)
    {
        EmazingCommManager.commManager.disconnectFromGloves()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startFirmwareUpdate(sender: AnyObject) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "segueToUpdating")
        {
            let firmwareUpdatingController = segue.destinationViewController as! FirmwareUpdatingViewController
            firmwareUpdatingController.initialVC = self
            firmwareUpdatingController.firmwareUpdater = self.firmwareUpdater
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
