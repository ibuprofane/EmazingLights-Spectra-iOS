//
//  FlashPatternEditorViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 4/8/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class FlashPatternEditorViewController: UITableViewController, UITextFieldDelegate {

    var baseFP:FlashingPattern!
    var modifyingCustom:Bool = false
    
    var strobeLength:Int = 15
    var gapLength:Int = 15
    var groupGapLength:Int = 15
    var faderOption:Int = 0
    var faderSpeed:Int = 0
    var brightnessSpeed:Int = 0
    var colorRepeat:Int = 0
    var groupRepeat:Int = 0
    var groupingNumber:Int = 0
    var firstColorStrobeLength:Int = 0
    var firstColorRepeat:Int = 0
    var firstColorPositionOption:Int = 0
    var firstColorPosition:Int = 0
    var rampOption:Int = 0
    var rampTargetLength:Int = 0
    
    @IBOutlet var basicSaveButton: UIButton!
    @IBOutlet var basicSaveAsNewButton: UIButton!
    @IBOutlet var advancedSaveButton: UIButton!
    @IBOutlet var advancedSaveAsNewButton: UIButton!
    
    @IBOutlet var fpNameLabel: UITextField!
    
    @IBOutlet var strobeLengthSlider: AHKSlider!
    @IBOutlet var strobeLengthLabel: UILabel!
    @IBOutlet var strobeLengthStepper: UIStepper!
    
    @IBOutlet var gapLengthSlider: AHKSlider!
    @IBOutlet var gapLengthLabel: UILabel!
    @IBOutlet var gapLengthStepper: UIStepper!
    
    @IBOutlet var groupGapLengthSlider: AHKSlider!
    @IBOutlet var groupGapLengthLabel: UILabel!
    @IBOutlet var groupGapLengthStepper: UIStepper!
    
    @IBOutlet var brightnessSlider: AHKSlider!
    @IBOutlet var brightnessLabel: UILabel!
    @IBOutlet var brightnessStepper: UIStepper!
    
    @IBOutlet var faderSegControl: UISegmentedControl!
    @IBOutlet var faderSpeedSlider: AHKSlider!
    @IBOutlet var faderSpeedLabel: UILabel!
    @IBOutlet var faderSpeedStepper: UIStepper!
    
    @IBOutlet var colorRepeatSwitch: UISwitch!
    @IBOutlet var colorRepeatLabel: UILabel!
    @IBOutlet var colorRepeatStepper: UIStepper!
    
    @IBOutlet var groupRepeatSwitch: UISwitch!
    @IBOutlet var groupRepeatLabel: UILabel!
    @IBOutlet var groupRepeatStepper: UIStepper!
    
    @IBOutlet var groupingNumberSwitch: UISwitch!
    @IBOutlet var groupingNumberLabel: UILabel!
    @IBOutlet var groupingNumberStepper: UIStepper!
    
    @IBOutlet var firstColorStrobeLengthSwitch: UISwitch!
    @IBOutlet var firstColorStrobeLengthLabel: UILabel!
    @IBOutlet var firstColorStrobeLengthSlider: AHKSlider!
    @IBOutlet var firstColorStrobeLengthStepper: UIStepper!
    
    @IBOutlet var firstColorRepeatSwitch: UISwitch!
    @IBOutlet var firstColorRepeatLabel: UILabel!
    @IBOutlet var firstColorRepeatStepper: UIStepper!
    
    @IBOutlet var firstColorPositionSwitch: UISwitch!
    @IBOutlet var firstColorPositionSegControl: UISegmentedControl!
    
    @IBOutlet var rampOptionSwitch: UISwitch!
    @IBOutlet var rampOptionSegControl: UISegmentedControl!
    
    @IBOutlet var rampTargetLengthLabel: UILabel!
    @IBOutlet var rampTargetLengthSlider: AHKSlider!
    @IBOutlet var rampTargetLengthStepper: UIStepper!
    
    var previewReady:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fpNameLabel.delegate = self

        if(baseFP != nil)
        {
            fpNameLabel.text = baseFP.name
            strobeLength = baseFP.strobeLength
            gapLength = baseFP.gapLength
            groupGapLength = baseFP.groupGapLength
            faderOption = baseFP.faderOption
            faderSpeed = baseFP.faderSpeed
            brightnessSpeed = baseFP.brightnessSpeed
            colorRepeat = baseFP.colorRepeat
            groupRepeat = baseFP.groupRepeat
            groupingNumber = baseFP.groupingNumber
            firstColorStrobeLength = baseFP.firstColorStrobeLength
            firstColorRepeat = baseFP.firstColorRepeat
            firstColorPosition = baseFP.firstColorPosition
            rampOption = baseFP.rampOption
            rampTargetLength = baseFP.rampTargetLength
        }
        
        if(!modifyingCustom)
        {
            basicSaveButton.hidden = true
            advancedSaveButton.hidden = true
        }
        
        self.updateUIControls(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
        self.updateFPPreview(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
    }
    
    func updateUIControls(strobeLength:Int, gapLength:Int, groupGapLength:Int, faderOption:Int, faderSpeed:Int, brightnessSpeed:Int, colorRepeat:Int, groupRepeat:Int, groupingNumber:Int, firstColorStrobeLength:Int, firstColorRepeat:Int, firstColorPosition:Int, rampOption:Int, rampTargetLength:Int)
    {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            //Switches and Segmented Controls
            var faderSpeedDisplay = faderSpeed
            if(faderOption == 0 || faderOption == 3) //None or Blend
            {
                self.faderSpeedSlider.enabled = false
                self.faderSpeedLabel.enabled = false
                self.faderSpeedStepper.enabled = false
                faderSpeedDisplay = 0
            }
            else if(faderOption == 1)
            {
                self.faderSpeedSlider.enabled = true
                self.faderSpeedLabel.enabled = true
                self.faderSpeedStepper.enabled = true
                faderSpeedDisplay = faderSpeed
            }
            else if(faderOption == 2)
            {
                self.faderSpeedSlider.enabled = true
                self.faderSpeedLabel.enabled = true
                self.faderSpeedStepper.enabled = true
                faderSpeedDisplay = faderSpeed - 125
            }
            self.faderSegControl.selectedSegmentIndex = faderOption
            
            if(colorRepeat == 0)
            {
                self.colorRepeatSwitch.on = false
                self.colorRepeatLabel.enabled = false
                self.colorRepeatStepper.enabled = false
            }
            else
            {
                self.colorRepeatSwitch.on = true
                self.colorRepeatLabel.enabled = true
                self.colorRepeatStepper.enabled = true
            }
            
            if(groupRepeat == 0)
            {
                self.groupRepeatSwitch.on = false
                self.groupRepeatLabel.enabled = false
                self.groupRepeatStepper.enabled = false
            }
            else
            {
                self.groupRepeatSwitch.on = true
                self.groupRepeatLabel.enabled = true
                self.groupRepeatStepper.enabled = true
            }
            
            if(groupingNumber == 0)
            {
                self.groupingNumberSwitch.on = false
                self.groupingNumberLabel.enabled = false
                self.groupingNumberStepper.enabled = false
            }
            else
            {
                self.groupingNumberSwitch.on = true
                self.groupingNumberLabel.enabled = true
                self.groupingNumberStepper.enabled = true
            }
            
            if(firstColorStrobeLength == 0)
            {
                self.firstColorStrobeLengthSwitch.on = false
                self.firstColorStrobeLengthLabel.enabled = false
                self.firstColorStrobeLengthSlider.enabled = false
                self.firstColorStrobeLengthStepper.enabled = false
            }
            else
            {
                self.firstColorStrobeLengthSwitch.on = true
                self.firstColorStrobeLengthLabel.enabled = true
                self.firstColorStrobeLengthSlider.enabled = true
                self.firstColorStrobeLengthStepper.enabled = true
            }
            
            if(firstColorRepeat == 0)
            {
                self.firstColorRepeatSwitch.on = false
                self.firstColorRepeatLabel.enabled = false
                self.firstColorRepeatStepper.enabled = false
            }
            else
            {
                self.firstColorRepeatSwitch.on = true
                self.firstColorRepeatLabel.enabled = true
                self.firstColorRepeatStepper.enabled = true
            }
            
            if(firstColorPosition == 0)
            {
                self.firstColorPositionSwitch.on = false
                self.firstColorPositionSegControl.enabled = false
                self.firstColorPositionSegControl.selectedSegmentIndex = 0
            }
            else
            {
                self.firstColorPositionSwitch.on = true
                self.firstColorPositionSegControl.enabled = true
                self.firstColorPositionSegControl.selectedSegmentIndex = firstColorPosition - 1
            }
            
            var rampTargetLengthDisplay = rampTargetLength
            if(rampTargetLength == 0)
            {
                self.rampOptionSwitch.on = false
                self.rampOptionSegControl.enabled = false
                self.rampTargetLengthLabel.enabled = false
                self.rampTargetLengthSlider.enabled = false
                self.rampTargetLengthStepper.enabled = false
            }
            else
            {
                self.rampOptionSwitch.on = true
                self.rampOptionSegControl.enabled = true
                self.rampTargetLengthLabel.enabled = true
                self.rampTargetLengthSlider.enabled = true
                self.rampTargetLengthStepper.enabled = true
                if(rampTargetLength > 0 && rampTargetLength <= 50)
                {
                    rampTargetLengthDisplay = rampTargetLength
                }
                else if(rampTargetLength > 50 && rampTargetLength <= 100)
                {
                    rampTargetLengthDisplay = rampTargetLength - 50
                }
            }
            self.rampOptionSegControl.selectedSegmentIndex = rampOption
            
            //Labels
            self.strobeLengthLabel.text = "\(strobeLength)"
            self.gapLengthLabel.text = "\(gapLength)"
            self.groupGapLengthLabel.text = "\(groupGapLength)"
            self.brightnessLabel.text = "\(brightnessSpeed)"
            self.faderSpeedLabel.text = "\(faderSpeedDisplay)"
            self.colorRepeatLabel.text = "\(colorRepeat)"
            self.groupRepeatLabel.text = "\(groupRepeat)"
            self.groupingNumberLabel.text = "\(groupingNumber)"
            self.firstColorStrobeLengthLabel.text = "\(firstColorStrobeLength)"
            self.firstColorRepeatLabel.text = "\(firstColorRepeat)"
            self.rampTargetLengthLabel.text = "\(rampTargetLengthDisplay)"
            
            //Sliders
            self.strobeLengthSlider.value = Float(strobeLength)
            self.gapLengthSlider.value = Float(gapLength)
            self.groupGapLengthSlider.value = Float(groupGapLength)
            self.brightnessSlider.value = Float(brightnessSpeed)
            self.faderSpeedSlider.value = Float(faderSpeedDisplay)
            self.firstColorStrobeLengthSlider.value = Float(firstColorStrobeLength)
            self.rampTargetLengthSlider.value = Float(rampTargetLengthDisplay)
            
            //Steppers
            self.strobeLengthStepper.value = Double(strobeLength)
            self.gapLengthStepper.value = Double(gapLength)
            self.groupGapLengthStepper.value = Double(groupGapLength)
            self.brightnessStepper.value = Double(brightnessSpeed)
            self.faderSpeedStepper.value = Double(faderSpeedDisplay)
            self.colorRepeatStepper.value = Double(colorRepeat)
            self.groupRepeatStepper.value = Double(groupRepeat)
            self.groupingNumberStepper.value = Double(groupingNumber)
            self.firstColorStrobeLengthStepper.value = Double(firstColorStrobeLength)
            self.firstColorRepeatStepper.value = Double(firstColorRepeat)
            self.rampTargetLengthStepper.value = Double(rampTargetLengthDisplay)
        }
    }
    
    func updateFPPreview(strobeLength:Int, gapLength:Int, groupGapLength:Int, faderOption:Int, faderSpeed:Int, brightnessSpeed:Int, colorRepeat:Int, groupRepeat:Int, groupingNumber:Int, firstColorStrobeLength:Int, firstColorRepeat:Int, firstColorPosition:Int, rampOption:Int, rampTargetLength:Int)
    {
        //TODO: Check if this is needed
        let flashingPatternID = 48
        if(!modifyingCustom)
        {
            //flashingPatternID = self.baseFP.code
        }
        //ENDTODO
        
        if(canSendFPPreview)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.previewCustomFlashingPattern(flashingPatternID, strobeLength: strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, brightnessSpeed: brightnessSpeed, faderValue: faderSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampTargetLength: rampTargetLength)
            })
            
            if(!previewReady)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    EmazingCommManager.commManager.syncManager.prepareFPPreview(flashingPatternID)
                    self.previewReady = true
                })
            }
            
            resetCommandLimitTimer()
            self.fpPreviewLimitTimer = NSTimer.scheduledTimerWithTimeInterval(commandLimitTime, target: self, selector: #selector(FlashPatternEditorViewController.canSendFlashingPattern), userInfo: nil, repeats: false)
            canSendFPPreview = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.fpNameLabel.resignFirstResponder()
        return true
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.fpNameLabel.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.fpNameLabel.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateSliderValue(sender: AnyObject)
    {
        let slider = sender as! AHKSlider
        let value = Int(slider.value)
        
        if(slider.tag == 0)
        {
            strobeLength = value
        }
        else if(slider.tag == 1)
        {
            gapLength = value
        }
        else if(slider.tag == 2)
        {
            groupGapLength = value
        }
        else if(slider.tag == 3)
        {
            brightnessSpeed = value
        }
        else if(slider.tag == 4)
        {
            if(faderOption == 1) //Fade
            {
                faderSpeed = value
            }
            else if(faderOption == 2) //Morph
            {
                faderSpeed = value + 125
            }
        }
        else if(slider.tag == 5)
        {
            firstColorStrobeLength = value
        }
        else if(slider.tag == 6)
        {
            if(rampOption == 0)
            {
                rampTargetLength = value
            }
            else if(rampOption == 1)
            {
                rampTargetLength = value + 50
            }
        }
        
        self.updateUIControls(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
        self.updateFPPreview(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
    }
    
    @IBAction func optionSelected(sender: UISegmentedControl)
    {
        if(sender.tag == 7)
        {
            faderOption = sender.selectedSegmentIndex
            if(faderOption == 0) //None
            {
                faderSpeed = 0
            }
            else if(faderOption == 1) //Fade
            {
                faderSpeed = 1
            }
            else if(faderOption == 2) //Morph
            {
                faderSpeed = 126
            }
            else if(faderOption == 3) //Blend
            {
                faderSpeed = 255
            }
        }
        else if(sender.tag == 8)
        {
            firstColorPositionOption = sender.selectedSegmentIndex
            firstColorPosition = firstColorPositionOption + 1
        }
        else if(sender.tag == 9)
        {
            rampOption = sender.selectedSegmentIndex
            if(rampOption == 0)
            {
                rampTargetLength = Int(rampTargetLengthSlider.value)
            }
            else if(rampOption == 1)
            {
                rampTargetLength = Int(rampTargetLengthSlider.value) + 50
            }
        }
        
        self.updateUIControls(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
        self.updateFPPreview(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
    }
    
    @IBAction func stepperUpdated(sender: UIStepper)
    {
        if(sender.tag == 10)
        {
            colorRepeat = Int(sender.value)
        }
        else if(sender.tag == 11)
        {
            groupRepeat = Int(sender.value)
        }
        else if(sender.tag == 12)
        {
            groupingNumber = Int(sender.value)
        }
        else if(sender.tag == 13)
        {
            firstColorRepeat = Int(sender.value)
        }
        else if(sender.tag == 21)
        {
            strobeLength = Int(sender.value)
        }
        else if(sender.tag == 22)
        {
            gapLength = Int(sender.value)
        }
        else if(sender.tag == 23)
        {
            groupGapLength = Int(sender.value)
        }
        else if(sender.tag == 24)
        {
            brightnessSpeed = Int(sender.value)
        }
        else if(sender.tag == 25)
        {
            if(faderOption == 1) //Fade
            {
                faderSpeed = Int(sender.value)
            }
            else if(faderOption == 2) //Morph
            {
                faderSpeed = Int(sender.value) + 125
            }
        }
        else if(sender.tag == 26)
        {
            firstColorStrobeLength = Int(sender.value)
        }
        else if(sender.tag == 27)
        {
            if(rampOption == 0)
            {
                rampTargetLength = Int(sender.value)
            }
            else if(rampOption == 1)
            {
                rampTargetLength = Int(sender.value) + 50
            }
        }
        
        self.updateUIControls(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
        self.updateFPPreview(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
    }
    
    @IBAction func switchToggled(sender: UISwitch)
    {
        if(sender.tag == 14)
        {
            if(colorRepeatSwitch.on)
            {
                colorRepeat = 1
            }
            else
            {
                colorRepeat = 0
            }
        }
        else if(sender.tag == 15)
        {
            if(groupRepeatSwitch.on)
            {
                groupRepeat = 1
            }
            else
            {
                groupRepeat = 0
            }
        }
        else if(sender.tag == 16)
        {
            if(groupingNumberSwitch.on)
            {
                groupingNumber = 1
            }
            else
            {
                groupingNumber = 0
            }
        }
        else if(sender.tag == 17)
        {
            if(firstColorStrobeLengthSwitch.on)
            {
                firstColorStrobeLength = 1
            }
            else
            {
                firstColorStrobeLength = 0
            }
        }
        else if(sender.tag == 18)
        {
            if(firstColorRepeatSwitch.on)
            {
                firstColorRepeat = 1
            }
            else
            {
                firstColorRepeat = 0
            }
        }
        else if(sender.tag == 19)
        {
            if(firstColorPositionSwitch.on)
            {
                firstColorPositionOption = 0
                firstColorPosition = 1
            }
            else
            {
                firstColorPositionOption = 0
                firstColorPosition = 0
            }
        }
        else if(sender.tag == 20)
        {
            if(rampOptionSwitch.on)
            {
                rampOption = 0
                rampTargetLength = 25
            }
            else
            {
                rampOption = 0
                rampTargetLength = 0
            }
        }
        
        self.updateUIControls(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
        self.updateFPPreview(strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
    }
    
    @IBAction func savePressed(sender: AnyObject)
    {
        if let fpName = fpNameLabel.text
        {
            if(!nameIsDuplicate(fpName, ignoreCurrent: baseFP) && fpName != "")
            {
                baseFP.name = fpName
                baseFP.strobeLength = strobeLength
                baseFP.gapLength = gapLength
                baseFP.groupGapLength = groupGapLength
                baseFP.faderOption = faderOption
                baseFP.faderSpeed = faderSpeed
                baseFP.brightnessSpeed = brightnessSpeed
                baseFP.colorRepeat = colorRepeat
                baseFP.groupRepeat = groupRepeat
                baseFP.groupingNumber = groupingNumber
                baseFP.firstColorStrobeLength = firstColorStrobeLength
                baseFP.firstColorRepeat = firstColorRepeat
                baseFP.firstColorPosition = firstColorPosition
                baseFP.rampOption = rampOption
                baseFP.rampTargetLength = rampTargetLength

                EmazingSettings.settings.save()
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            else if(fpName == "")
            {
                showBlankNameMessage()
            }
            else
            {
                showDuplicateNameMessage()
            }
        }
    }
    
    @IBAction func saveAsNewPressed(sender: AnyObject) {
        if let fpName = fpNameLabel.text
        {
            if(!nameIsDuplicate(fpName, ignoreCurrent: nil) && fpName != "")
            {
                let newFP:FlashingPattern = FlashingPattern(name: fpName, imageName: baseFP.imageName, code: baseFP.code, strobeLength: strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, faderOption: faderOption, faderSpeed: faderSpeed, brightnessSpeed: brightnessSpeed, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampOption: rampOption, rampTargetLength: rampTargetLength)
                EmazingSettings.settings.customFlashingPatterns.append(newFP)
                EmazingSettings.settings.save()
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            else if(fpName == "")
            {
                showBlankNameMessage()
            }
            else
            {
                showDuplicateNameMessage()
            }
        }
    }
    
    func showDuplicateNameMessage()
    {
        let alertController = UIAlertController(title: "Duplicate Name", message: "A chip set with this name already exists. Please choose a unique name.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showBlankNameMessage()
    {
        let alertController = UIAlertController(title: "Choose A Name", message: "Please choose a name for this custom flashing pattern.", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func nameIsDuplicate(name:String, ignoreCurrent:FlashingPattern?)->Bool
    {
        var duplicateFound:Bool = false
        for fp in EmazingSettings.settings.stockFlashingPatterns
        {
            if(fp.name == name)
            {
                if(fp != ignoreCurrent)
                {
                    duplicateFound = true
                }
            }
        }
        for fp in EmazingSettings.settings.customFlashingPatterns
        {
            if(fp.name == name)
            {
                if(fp != ignoreCurrent)
                {
                    duplicateFound = true
                }
            }
        }
        
        return duplicateFound
    }
    
    //MARK: Flashing pattern command limiter
    var fpPreviewLimitTimer:NSTimer!
    let commandLimitTime:Double = 0.1
    var canSendFPPreview:Bool = true
    func canSendFlashingPattern()
    {
        resetCommandLimitTimer()
        canSendFPPreview = true
    }
    
    func resetCommandLimitTimer()
    {
        if(fpPreviewLimitTimer != nil)
        {
            fpPreviewLimitTimer.invalidate()
            fpPreviewLimitTimer = nil
        }
    }

    //Prevent the table cells from highlighting
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
