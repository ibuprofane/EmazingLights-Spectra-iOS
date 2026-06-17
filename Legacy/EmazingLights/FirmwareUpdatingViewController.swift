//
//  FirmwareUpdatingViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/4/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class FirmwareUpdatingViewController: UIViewController, FirmwareUpdaterDelegate {

    var firmwareUpdater:FirmwareUpdater!
    var initialVC:StartFirmwareUpdateViewController!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firmwareUpdater.updaterDelegate = self
        firmwareUpdater.beginUpdate(EmazingCommManager.commManager.connectedGloves)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadingFirmware(status:String)
    {
        print("Downloading: \(status)")
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.statusLabel.text = status
        }
    }
    
    func firmwareDownloadFinished()
    {
        print("Firmware download finished")
    }
    
    func updatingBLEDevice(status:String)
    {
        print("Updating BLE Device: \(status)")
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.statusLabel.text = status
        }
    }
    
    func downloadProgress(progress: Float) {
        progressView.progress = progress
    }
    
    func bleUpdateFinished(success:Bool)
    {
        print("BLE update finished")
        let controller:FirmwareUpdatedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("firmwareUpdatedView") as! FirmwareUpdatedViewController
        
        controller.success = success
        controller.initialVC = self.initialVC
        self.showViewController(controller, sender: self)
        
        //self.presentViewController(controller, animated: true) { () -> Void in
        //}
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
