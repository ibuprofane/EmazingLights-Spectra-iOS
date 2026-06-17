//
//  ChipMenuViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 4/8/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class ChipMenuViewController: UIViewController {

    var deviceType:String = ""
    var menuButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named:"backarrow") as UIImage!
        let btnBack:UIButton = UIButton(type: UIButtonType.Custom)
        btnBack.addTarget(self, action: #selector(ChipMenuViewController.BtnTapBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnBack.setImage(image, forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItems  = [menuButton, myCustomBackButtonItem]
        
        if(deviceType == "PhotoChips")
        {
            self.navigationItem.title = "Photo Hub Menu"
        }
        else
        {
            self.navigationItem.title = "Glove Sets"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chipsPressed(sender: AnyObject)
    {
        let controller:GloveSetSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveSetSelectionView") as! GloveSetSelectionViewController
        controller.menuButton = self.menuButton
        controller.deviceType = "PhotoChips"
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func BtnTapBack(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func modesPressed(sender: AnyObject)
    {
        let controller:ModeSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("modeSelectionView") as! ModeSelectionViewController
        
        controller.pageMode = .Edit
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func flashingPatternsPressed(sender: AnyObject)
    {
        let controller:FlashingPatternSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("flashingPatternSelectionView") as! FlashingPatternSelectionViewController
        
        controller.pageMode = .Edit
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func colorPalettesPressed(sender: AnyObject)
    {
        let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
        
        //TODO: Adjust for multiple sequences and slots
        controller.displayMode = .PaletteMenuEdit
        controller.exitToController = self
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
