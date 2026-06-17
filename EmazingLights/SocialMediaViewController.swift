//
//  SocialMediaViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/11/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class SocialMediaViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        if let url = NSURL(string: "https://www.facebook.com/EmazingLights/")
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    @IBAction func instagramPressed(sender: AnyObject) {
        if let url = NSURL(string: "https://instagram.com/EmazingLights/")
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func twitterPressed(sender: AnyObject) {
        if let url = NSURL(string: "https://twitter.com/EmazingLights/")
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func youtubePressed(sender: AnyObject) {
        if let url = NSURL(string: "https://www.youtube.com/user/EmazingLights/")
        {
            UIApplication.sharedApplication().openURL(url)
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
