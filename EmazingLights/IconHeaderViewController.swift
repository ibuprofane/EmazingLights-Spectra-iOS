//
//  IconHeaderViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/5/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class IconHeaderViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    var parentVC:ChipConfigViewController!
    
    var titleString:String!
    var imageName:String!
    var descriptionString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = titleString
        self.imageView.image = UIImage(named: imageName)
        //self.descriptionTextView.text = descriptionString
        
        let imageRectPath:UIBezierPath = UIBezierPath(rect: CGRectMake(0, 0, imageView.frame.width, imageView.frame.height - descriptionTextView.frame.origin.y - imageView.frame.origin.y))
        self.descriptionTextView.textContainer.exclusionPaths = [imageRectPath]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: 90)
    }
    
    var infoPanelOpen:Bool = false
    @IBAction func moreButtonPressed(sender: AnyObject)
    {
        if(infoPanelOpen)
        {
            //var headerFrame = self.view.frame
            //headerFrame.size.height = 90
            
            //var containerFrame = parentVC.view.frame
            //containerFrame.size.height = 90
            
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationDelay(0.0)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
            
            //self.view.frame = headerFrame
            //parentVC.view.frame = containerFrame
            
            self.preferredContentSize = CGSize(width: self.view.frame.width, height: 90)

            
            UIView.commitAnimations()
            
            //print(headerFrame)
            
            parentVC.view.setNeedsDisplay()
            
            infoPanelOpen = false
        }
        else
        {
            //var headerFrame = self.view.frame
            //headerFrame.size.height = 200
            
            //var containerFrame = parentVC.view.frame
            //containerFrame.size.height = 200
            
            
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationDelay(0.0)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
            
            //self.view.frame = headerFrame
            //parentVC.view.frame = containerFrame
            
            self.preferredContentSize = CGSize(width: self.view.frame.width, height: 200)
            
            UIView.commitAnimations()
            
            //print(headerFrame)
            
            parentVC.view.setNeedsDisplay()
            
            infoPanelOpen = true
        }
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
