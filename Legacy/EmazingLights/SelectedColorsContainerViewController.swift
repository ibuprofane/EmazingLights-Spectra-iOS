//
//  SelectedColorsContainerViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/4/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class SelectedColorsContainerViewController: UIViewController {

    var exitToController:UIViewController!
    var sequence:Sequence!
    var finger:Finger!
    var modeEditedDelegate:ModeEditedDelegate?
    var modeDisplayMode:PageMode = .Edit
    
    @IBOutlet var colorButtonCollection: [UIButton]!
    @IBOutlet var colorLabelCollection: [UILabel]!
    @IBOutlet var colorTintCollection: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshColorDotData()
    }
    
    func refreshColorDotData()
    {
        var colorCount = 0
        for index in 0..<sequence.colorSet.count
        {
            let colorDot:ColorDotView = ColorDotView(frame: self.colorButtonCollection[index].frame)
            
            var cleanedColor = sequence.colorSet[index]
            if(sequence.colorSet[index].fixedColorRef == 0) //Fix for white
            {
                cleanedColor = Color(red: 255, green: 255, blue: 255)
            }
            
            var tint = "H"
            if(index < sequence.colorTints.count)
            {
                tint = sequence.colorTints[index]
            }
            
            colorDot.assignColor(cleanedColor.getUIColor(), tint: tint)
            self.colorButtonCollection[index].setImage(colorDot.getImage(), forState: UIControlState.Normal)
            self.colorLabelCollection[index].text = EmazingConstants.constants.colorNames.nameForColor(colorDot.baseColor).capitalizedString
            
            if(tint == "H")
            {
                self.colorTintCollection[index].hidden = true
            }
            else
            {
                self.colorTintCollection[index].text = tint
                self.colorTintCollection[index].hidden = false
            }
            
            colorCount += 1
        }
        
        for colorCount in colorCount..<sequence.maxColors
        {
            let colorDot:ColorDotView = ColorDotView(frame: self.colorButtonCollection[colorCount].frame)
            colorDot.assignAsDisabled()
            self.colorButtonCollection[colorCount].setImage(colorDot.getImage(), forState: UIControlState.Normal)
            self.colorLabelCollection[colorCount].text = "Disabled"
            self.colorTintCollection[colorCount].hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func colorDotSelected(sender: UIButton) {
        let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
        
        //TODO: Adjust for multiple sequences and slots
        controller.sequence = sequence
        controller.colorSlot = sender.tag
        controller.finger = finger
        controller.displayMode = .ColorSelect
        controller.modeEditedDelegate = modeEditedDelegate
        controller.exitToController = exitToController
        
        if(modeDisplayMode == .DirectEdit)
        {
            controller.allowColorAddition = false
        }

        self.navigationController?.pushViewController(controller, animated: true)
    }

    func randomizeColors()
    {
        var newColorSet:[Color] = []
        for _ in 0 ..< sequence.maxColors
        {
            let randomInt = Int.random(min: 0, max: EmazingSettings.settings.stockColors.count - 1)
            newColorSet.append(EmazingSettings.settings.stockColors[randomInt])
        }
        
        sequence.colorSet = newColorSet
        sequence.colorTints = ["H", "H", "H", "H", "H", "H", "H"]
        
        refreshColorDotData()
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
