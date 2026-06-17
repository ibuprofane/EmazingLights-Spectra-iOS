//
//  GloveSetConfigViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/24/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class GloveSetConfigViewController: UIViewController , UIScrollViewDelegate{

    var gloveSet:GloveSet!
    
    @IBOutlet var gloveSetImage: UIImageView!
    @IBOutlet var gloveSetNameLabel: UILabel!
    @IBOutlet var gloveSetInfoView: UIView!
    @IBOutlet var newScrollView: UIScrollView!

    //var scrollView:REPagedScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(gloveSet != nil)
        {
            gloveSetNameLabel.text = gloveSet.name
            gloveSetImage.image = UIImage(named: gloveSet.imageName)
        }
        
        newScrollView.delegate = self
        
        
        /*let scrollViewHeight:CGFloat = self.view.bounds.height - 200.0
        scrollView = REPagedScrollView(frame: CGRect(x: 0.0, y: gloveSetInfoView.frame.origin.y + gloveSetInfoView.frame.height, width: self.view.bounds.width, height: scrollViewHeight))
        scrollView.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        scrollView.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        
        let leftHandView = NSBundle.mainBundle().loadNibNamed("LeftHandView", owner: self, options: nil)[0] as! UIView
        leftHandView.backgroundColor = UIColor.redColor()
        leftHandView.frame = CGRect(x: leftHandView.frame.origin.x, y: leftHandView.frame.origin.y, width: gloveSetInfoView.frame.width, height: scrollViewHeight)
        scrollView.addPage(leftHandView)
        
        let rightHandView = NSBundle.mainBundle().loadNibNamed("LeftHandView", owner: self, options: nil)[0] as! UIView
        rightHandView.backgroundColor = UIColor.blueColor()
        rightHandView.frame = CGRect(x: rightHandView.frame.origin.x, y: rightHandView.frame.origin.y, width: gloveSetInfoView.frame.width, height: scrollViewHeight)
        scrollView.addPage(rightHandView)
        
        self.view.addSubview(scrollView)*/
    }

    override func viewDidLayoutSubviews() {
        newScrollView.contentSize = CGSize(width: 760, height: 300)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fingerButtonClicked(sender: AnyObject) {
        
        let controller:FingerConfigViewController = self.storyboard?.instantiateViewControllerWithIdentifier("fingerConfigView") as! FingerConfigViewController
        
        var gloveID:Int!
        var fingerID:Int!
        var finger:Finger!
        
        let button = sender as! UIButton
        if(sender.tag >= 101 && sender.tag <= 205)
        {
            if(sender.tag >= 101 && sender.tag <= 105)
            {
                //Left Hand
                gloveID = 0
                fingerID = sender.tag - 101
            }
            else if(sender.tag >= 201 && sender.tag <= 205)
            {
                //Right Hand
                gloveID = 1
                fingerID = sender.tag - 201
            }
            
            finger = self.gloveSet.glovePair[gloveID].fingers[fingerID]
        }
        
        if(finger != nil)
        {
            controller.finger = finger
            controller.fingerTitle = "\(gloveSet.name) - \(button.titleLabel!.text!)"
            self.navigationController?.pushViewController(controller, animated: true)
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
