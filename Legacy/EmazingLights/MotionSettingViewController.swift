//
//  EmotionSettingViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 1/11/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class MotionSettingViewController: UIViewController{

    var mode:Mode!
    
    @IBOutlet var motionTypeSegControl: UISegmentedControl!
    @IBOutlet var thresholdSegControl: UISegmentedControl!
    
    @IBOutlet var speedFluxThresholds: UIView!
    @IBOutlet var lowSlider: UISlider!
    @IBOutlet var mediumSlider: UISlider!
    @IBOutlet var highSlider: UISlider!
    @IBOutlet var lowStepper: UIStepper!
    @IBOutlet var mediumStepper: UIStepper!
    @IBOutlet var highStepper: UIStepper!
    @IBOutlet var lowLabel: UILabel!
    @IBOutlet var mediumLabel: UILabel!
    @IBOutlet var highLabel: UILabel!
    
    @IBOutlet var tiltThresholds: UIView!
    @IBOutlet var upSlider: UISlider!
    @IBOutlet var downSlider: UISlider!
    @IBOutlet var upStepper: UIStepper!
    @IBOutlet var downStepper: UIStepper!
    @IBOutlet var upLabel: UILabel!
    @IBOutlet var downLabel: UILabel!
    
    var low:Int = 0
    var medium:Int = 0
    var high:Int = 0
    var up:Int = 0
    var down:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MotionSettingViewController.save))
        
        motionTypeSegControl.selectedSegmentIndex = mode.emotionEffect
        thresholdSegControl.selectedSegmentIndex = mode.emotionSpeedOption
        
        low = mode.emotionParam1
        medium = mode.emotionParam2
        high = mode.emotionParam3
        up = mode.emotionParam1
        down = mode.emotionParam2
        
        if(mode.emotionEffect == 2) //Tilt
        {
            if(mode.emotionSpeedOption == 3)
            {
                tiltThresholds.hidden = false
            }
            else
            {
                tiltThresholds.hidden = true
            }
            speedFluxThresholds.hidden = true
            
            upSlider.value = Float(up)
            upStepper.value = Double(up)
            upLabel.text = "\(up)"
            
            downSlider.value = Float(down)
            downStepper.value = Double(down)
            downLabel.text = "\(down)"
        }
        else
        {
            if(mode.emotionSpeedOption == 3)
            {
                speedFluxThresholds.hidden = false
            }
            else
            {
                speedFluxThresholds.hidden = true
            }
            tiltThresholds.hidden = true
            
            lowSlider.value = Float(low)
            lowStepper.value = Double(low)
            lowLabel.text = "\(Int(low))"
            
            mediumSlider.value = Float(medium)
            mediumStepper.value = Double(medium)
            mediumLabel.text = "\(medium)"
            
            highSlider.value = Float(high)
            highStepper.value = Double(high)
            highLabel.text = "\(high)"
        }
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper)
    {
        if(sender.tag == 1)
        {
            low = Int(sender.value)
        }
        else if(sender.tag == 2)
        {
            medium = Int(sender.value)
        }
        else if(sender.tag == 3)
        {
            high = Int(sender.value)
        }
        else if(sender.tag == 4)
        {
            up = Int(sender.value)
        }
        else if(sender.tag == 5)
        {
            down = Int(sender.value)
        }
        
        self.updateUIControls(low, medium: medium, high: high, up: up, down: down)
    }

    @IBAction func sliderValueChanged(sender: UISlider)
    {
        if(sender.tag == 1)
        {
            low = Int(sender.value)
        }
        else if(sender.tag == 2)
        {
            medium = Int(sender.value)
        }
        else if(sender.tag == 3)
        {
            high = Int(sender.value)
        }
        else if(sender.tag == 4)
        {
            up = Int(sender.value)
        }
        else if(sender.tag == 5)
        {
            down = Int(sender.value)
        }
        
        self.updateUIControls(low, medium: medium, high: high, up: up, down: down)
    }
    
    

    @IBAction func motionTypeSelected(sender: UISegmentedControl)
    {
        /*if(sender.selectedSegmentIndex == 2) // Tilt
        {
            tiltThresholds.hidden = false
            speedFluxThresholds.hidden = true
        }
        else
        {
            tiltThresholds.hidden = true
            speedFluxThresholds.hidden = false
        }*/
        
        thresholdSegControl.selectedSegmentIndex = 1 //Medium
        thresholdSegControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        tiltThresholds.hidden = true
        speedFluxThresholds.hidden = true
    }
    
    @IBAction func thresholdTypeSelected(sender: UISegmentedControl)
    {
        if(sender.selectedSegmentIndex == 0) //Low
        {
            tiltThresholds.hidden = true
            speedFluxThresholds.hidden = true
            if(motionTypeSegControl.selectedSegmentIndex == 2) //Tilt
            {
                up = 20
                down = 50
            }
            else
            {
                low = 20
                medium = 120
                high = 220
            }
        }
        else if(sender.selectedSegmentIndex == 1) //Medium
        {
            tiltThresholds.hidden = true
            speedFluxThresholds.hidden = true
            if(motionTypeSegControl.selectedSegmentIndex == 2) //Tilt
            {
                up = 100
                down = 150
            }
            else
            {
                low = 100
                medium = 150
                high = 200
            }
        }
        else if(sender.selectedSegmentIndex == 2) //High
        {
            tiltThresholds.hidden = true
            speedFluxThresholds.hidden = true
            if(motionTypeSegControl.selectedSegmentIndex == 2) //Tilt
            {
                up = 200
                down = 250
            }
            else
            {
                low = 200
                medium = 230
                high = 250
            }
        }
        else //Custom
        {
            if(motionTypeSegControl.selectedSegmentIndex == 2) //Tilt
            {
                tiltThresholds.hidden = false
                speedFluxThresholds.hidden = true
            }
            else
            {
                tiltThresholds.hidden = true
                speedFluxThresholds.hidden = false
            }
        }
        
        self.updateUIControls(low, medium: medium, high: high, up: up, down: down)
    }
    
    @IBAction func thresholdParamChanged(sender: AnyObject)
    {
        thresholdSegControl.selectedSegmentIndex = 3
    }
    
    func updateUIControls(low:Int, medium:Int, high:Int, up:Int, down:Int)
    {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            self.lowLabel.text = "\(low)"
            self.lowSlider.setValue(Float(low), animated: false)
            self.lowStepper.value = Double(low)
            
            self.mediumLabel.text = "\(medium)"
            self.mediumSlider.setValue(Float(medium), animated: false)
            self.mediumStepper.value = Double(medium)
            
            self.highLabel.text = "\(high)"
            self.highSlider.setValue(Float(high), animated: false)
            self.highStepper.value = Double(high)
            
            self.upLabel.text = "\(up)"
            self.upSlider.setValue(Float(up), animated: false)
            self.upStepper.value = Double(up)
            
            self.downLabel.text = "\(down)"
            self.downSlider.setValue(Float(down), animated: false)
            self.downStepper.value = Double(down)
        }
    }
    
    func save()
    {
        mode.emotionEffect = motionTypeSegControl.selectedSegmentIndex
        mode.emotionSpeedOption = thresholdSegControl.selectedSegmentIndex
        
        if(mode.emotionEffect == 2) //Tilt
        {
            mode.emotionParam1 = up
            mode.emotionParam2 = down
            mode.emotionParam3 = 0
        }
        else
        {
            mode.emotionParam1 = low
            mode.emotionParam2 = medium
            mode.emotionParam3 = high
        }
        
        EmazingSettings.settings.save()
            
        self.navigationController?.popViewControllerAnimated(true)
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
