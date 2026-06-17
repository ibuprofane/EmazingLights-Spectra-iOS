//
//  FirmwareUpdatedViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/7/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class FirmwareUpdatedViewController: UIViewController {

    @IBOutlet var updatedLabel: UILabel!
    //@IBOutlet var retryButton: UIButton!
    @IBOutlet var resultImage: UIImageView!
    @IBOutlet var noticeLabel1: UILabel!
    @IBOutlet var noticeLabel2: UILabel!
    
    var success:Bool = true
    var initialVC:StartFirmwareUpdateViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(success)
        {
            updatedLabel.text = "Firmware Updated"
            resultImage.image = UIImage(named: "GoodCheck")
            noticeLabel1.text = "Please wait 1 minute while the firmware finishes updating. Your hub will flash red."
            noticeLabel2.text = "Your hardware will reset when it is ready to use."
            
            //initialVC.dismissWhenShown = true
            //retryButton.hidden = true
        }
        else
        {
            updatedLabel.text = "Firmware Update Failed"
            resultImage.image = UIImage(named: "BadCheck")
            noticeLabel1.text = "Firmware update could not be completed."
            noticeLabel2.text = "Please ensure the device is powered on and within range of your phone."
            
            //initialVC.dismissWhenShown = false
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*@IBAction func retryPressed(sender: AnyObject) {
        initialVC.dismissWhenShown = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }*/
    
    @IBAction func closePressed(sender: AnyObject) {
        initialVC.dismissWhenShown = true
        initialVC.dismissViewControllerAnimated(false, completion: nil)
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
