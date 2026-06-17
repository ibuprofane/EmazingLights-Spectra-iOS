//
//  SyncPopupViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 3/15/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class SyncPopupViewController: UIViewController, SyncManagerDelegate {
    @IBOutlet var syncingLabel: UILabel!
    @IBOutlet var completionImage: UIImageView!
    var chip:Chip!
    let successImage:UIImage = UIImage(named: "GoodCheck")!
    let failureImage:UIImage = UIImage(named: "BadCheck")!
    var syncWatchdogTimer:NSTimer!
    let syncTimeout:Double = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        syncingLabel.hidden = false
        completionImage.hidden = true
        
        if(syncWatchdogTimer != nil)
        {
            self.syncWatchdogTimer.invalidate()
            self.syncWatchdogTimer = nil
        }
        
        self.syncWatchdogTimer = NSTimer.scheduledTimerWithTimeInterval(syncTimeout, target: self, selector: #selector(SyncPopupViewController.syncFailed), userInfo: nil, repeats: false)
        
        EmazingCommManager.commManager.disconnectFromPhotoHubs()
        sleep(1)
        EmazingCommManager.commManager.syncManager.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            EmazingCommManager.commManager.syncManager.prepareForSync(self.chip, uuid: EmazingSettings.settings.photoHubs[0].UUID)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func syncFailed()
    {
        syncFinished(false)
    }
    
    func syncFinished(completed:Bool)
    {
        if(syncWatchdogTimer != nil)
        {
            self.syncWatchdogTimer.invalidate()
            self.syncWatchdogTimer = nil
        }
        
        if(completed)
        {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.syncingLabel.hidden = true
                self.completionImage.hidden = false
                self.completionImage.image = self.successImage
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    //...
                })
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.syncingLabel.hidden = true
                self.completionImage.hidden = false
                self.completionImage.image = self.failureImage
                
                let alertController = UIAlertController(title: "Sync Failed", message: "The app could not connect to your device. Please ensure that the device is powered on and within range of your phone.", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        //...
                    })
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) { }


            }
        }
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
