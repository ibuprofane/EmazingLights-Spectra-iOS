//
//  CustomColorViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/16/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class CustomColorViewController: UIViewController, UITextFieldDelegate, DTColorPickerImageViewDelegate {

    @IBOutlet var pickerImage: DTColorPickerImageView!
    @IBOutlet var colorDotImage: ColorDotView!
    @IBOutlet var colorNameLabel: UILabel!
    @IBOutlet var colorHexBox: UITextField!
    
    
    @IBOutlet var rgbhsbToggleButton: UIButton!
    //var rgbSlidersVisible:Bool = true
    
    //RGB
    @IBOutlet var rgbSliderView: UIView!
    @IBOutlet var redSlider: AHKSlider!
    @IBOutlet var greenSlider: AHKSlider!
    @IBOutlet var blueSlider: AHKSlider!
    @IBOutlet var redValue: UILabel!
    @IBOutlet var greenValue: UILabel!
    @IBOutlet var blueValue: UILabel!
    @IBOutlet var redStepper: UIStepper!
    @IBOutlet var greenStepper: UIStepper!
    @IBOutlet var blueStepper: UIStepper!
    
    var red:Int = 255
    var blue:Int = 255
    var green:Int = 255
    
    //HSB
    @IBOutlet var hsbSliderView: UIView!
    @IBOutlet var hueSlider: AHKSlider!
    @IBOutlet var satSlider: AHKSlider!
    @IBOutlet var brtSlider: AHKSlider!
    @IBOutlet var hueValue: UILabel!
    @IBOutlet var satValue: UILabel!
    @IBOutlet var brtValue: UILabel!
    @IBOutlet var hueStepper: UIStepper!
    @IBOutlet var satStepper: UIStepper!
    @IBOutlet var brtStepper: UIStepper!
    
    var hue:Int = 0
    var sat:Float = 1.0
    var brt:Float = 1.0

    var lastSelectedColor:UIColor!
    var selectedCustomPalette:Palette!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorHexBox.delegate = self
        colorHexBox.addTarget(self, action: #selector(CustomColorViewController.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        colorHexBox.inputView = MRHexKeyboard(textField: colorHexBox)
        
        pickerImage.delegate = self
        
        pickerImage.hidden = false
        rgbSliderView.hidden = true
        hsbSliderView.hidden = true
        
        rgbhsbToggleButton.setTitle("HSB", forState: UIControlState.Normal)
        
        rgbhsbToggleButton.layer.borderColor = UIColor.greenColor().CGColor
        rgbhsbToggleButton.layer.borderWidth = 2.0
        rgbhsbToggleButton.layer.cornerRadius = 5.0
    }
    
    
    
    @IBAction func pickerToggled(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //Picker
            rgbSliderView.hidden = true
            hsbSliderView.hidden = true
            pickerImage.hidden = false
        case 1: //RGB
            rgbSliderView.hidden = false
            hsbSliderView.hidden = true
            pickerImage.hidden = true
        case 2: //HSB
            rgbSliderView.hidden = true
            hsbSliderView.hidden = false
            pickerImage.hidden = true
        default:
            break;
        }  //Switch
    }
    
    
    /*@IBAction func toggleSliders()
    {
        if(!rgbSlidersVisible)
        {
            rgbSliderView.hidden = false
            hsbSliderView.hidden = true
            rgbhsbToggleButton.setTitle("HSB", forState: UIControlState.Normal)
        }
        else
        {
            rgbSliderView.hidden = true
            hsbSliderView.hidden = false
            rgbhsbToggleButton.setTitle("RGB", forState: UIControlState.Normal)
        }
        
        rgbSlidersVisible = !rgbSlidersVisible
    }*/
    
    func imageView(imageView: DTColorPickerImageView, didPickColorWithColor color: UIColor) {
        self.colorSelected(color)
    }
    
    func textFieldDidChange(textField: UITextField) {

        if(textField.text!.characters.count == 7) //6 hex chars plus "#"
        {
            let color = UIColor(rgba: textField.text!)
            if(color != UIColor.clearColor())
            {
                self.colorSelected(color)
            }
        }
    }
    
    @IBAction func rgbSlidersChanged(sender: AHKSlider)
    {
        red = Int(redSlider.value)
        redStepper.value = Double(redSlider.value)
        redValue.text = "\(red)"

        green = Int(greenSlider.value)
        greenStepper.value = Double(greenSlider.value)
        greenValue.text = "\(green)"

        blue = Int(blueSlider.value)
        blueStepper.value = Double(blueSlider.value)
        blueValue.text = "\(blue)"
        
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        colorSelected(color)
    }
    
    @IBAction func rgbStepperChanged(sender: UIStepper)
    {
        red = Int(redStepper.value)
        redSlider.value = Float(redStepper.value)
        redValue.text = "\(red)"
        
        green = Int(greenStepper.value)
        greenSlider.value = Float(greenStepper.value)
        greenValue.text = "\(green)"
        
        blue = Int(blueStepper.value)
        blueSlider.value = Float(blueStepper.value)
        blueValue.text = "\(blue)"
        
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        colorSelected(color)
    }
    
    
    @IBAction func hsbSlidersChanged(sender: AHKSlider)
    {
        hue = Int(hueSlider.value)
        hueStepper.value = Double(hueSlider.value)
        hueValue.text = "\(hue)"
        
        sat = satSlider.value
        satStepper.value = Double(satSlider.value)
        let satInt = Int(sat * 100.0)
        satValue.text = "\(satInt)%"
        
        brt = brtSlider.value
        brtStepper.value = Double(brtSlider.value)
        let brtInt = Int(brt * 100.0)
        brtValue.text = "\(brtInt)%"
        
        let hsbColor = UIColor(hue: CGFloat(hue) / 360.0, saturation: CGFloat(sat), brightness: CGFloat(brt), alpha: 1.0)

        colorSelected(hsbColor)
    }
    
    @IBAction func hsbStepperChanged(sender: UIStepper)
    {
        hue = Int(hueStepper.value)
        hueSlider.value = Float(hueStepper.value)
        hueValue.text = "\(hue)"
        
        sat = Float(satStepper.value)
        satSlider.value = sat
        let satInt = Int(sat * 100.0)
        satValue.text = "\(satInt)%"
        
        brt = Float(brtStepper.value)
        brtSlider.value = brt
        let brtInt = Int(brt * 100.0)
        brtValue.text = "\(brtInt)%"
        
        let hsbColor = UIColor(hue: CGFloat(hue) / 360.0, saturation: CGFloat(sat), brightness: CGFloat(brt), alpha: 1.0)
        
        colorSelected(hsbColor)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        colorHexBox.resignFirstResponder()
        return false
    }
    
    func hexColorSelected(hex:String)
    {
        let color = UIColor(rgba: hex)
        if(color != UIColor.clearColor())
        {
            self.colorSelected(color)
        }
    }
    
    func colorSelected(color:UIColor)
    {
        if(color != lastSelectedColor)
        {
            previewCustomColor(Color(color: color))
            
            colorHexBox.text = color.hexString(false)
            colorNameLabel.text = EmazingConstants.constants.colorNames.nameForColor(color).capitalizedString
            colorDotImage.assignColor(color)
            lastSelectedColor = color
            
            if let myCIColor = color.coreImageColor {
                let redComp = myCIColor.red
                red = Int(redComp * 255)
                redSlider.setValue(Float(red), animated: true)
                redStepper.value = Double(red)
                redValue.text = "\(red)"
                
                let greenComp = myCIColor.green
                green = Int(greenComp * 255)
                greenSlider.setValue(Float(green), animated: true)
                greenStepper.value = Double(green)
                greenValue.text = "\(green)"
                
                let blueComp = myCIColor.blue
                blue = Int(blueComp * 255)
                blueSlider.setValue(Float(blue), animated: true)
                blueStepper.value = Double(blue)
                blueValue.text = "\(blue)"
            }
            
            var hueComp:CGFloat = 0.0
            var satComp:CGFloat = 0.0
            var brtComp:CGFloat = 0.0
            var alphaComp:CGFloat = 0.0
            color.getHue(&hueComp, saturation: &satComp, brightness: &brtComp, alpha: &alphaComp)
            
            hue = Int(hueComp * 360.0)
            hueSlider.setValue(Float(hue), animated: true)
            hueStepper.value = Double(hue)
            hueValue.text = "\(hue)"
            
            sat = Float(satComp)
            satSlider.setValue(sat, animated: true)
            satStepper.value = Double(sat)
            let satInt = Int(sat * 100.0)
            satValue.text = "\(satInt)%"
            
            brt = Float(brtComp)
            brtSlider.setValue(brt, animated: true)
            brtStepper.value = Double(brt)
            let brtInt = Int(brt * 100.0)
            brtValue.text = "\(brtInt)%"
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CustomColorViewController.saveCustomColor))
    }
    
    var customColorCommandLimitTimer:NSTimer!
    let commandLimitTime:Double = 0.1
    var firstTime:Bool = true
    func previewCustomColor(color:Color)
    {
        if(canSendCustomColor)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                if(self.firstTime)
                {
                    EmazingCommManager.commManager.syncManager.enableCustomColorPreviewMode()
                    self.firstTime = false
                }
                EmazingCommManager.commManager.syncManager.previewCustomColor(color)
            })
            
            resetCommandLimitTimer()
            self.customColorCommandLimitTimer = NSTimer.scheduledTimerWithTimeInterval(commandLimitTime, target: self, selector: #selector(CustomColorViewController.canSendColor), userInfo: nil, repeats: false)
            canSendCustomColor = false
        }
    }
    
    var canSendCustomColor:Bool = true
    func canSendColor()
    {
        resetCommandLimitTimer()
        canSendCustomColor = true
    }
    
    func resetCommandLimitTimer()
    {
        if(customColorCommandLimitTimer != nil)
        {
            customColorCommandLimitTimer.invalidate()
            customColorCommandLimitTimer = nil
        }
    }
    
    func saveCustomColor()
    {
        var colorExists = false
        for color in selectedCustomPalette.colors
        {
            if(color.getUIColor() == lastSelectedColor)
            {
                colorExists = true
            }
        }
        
        if(!colorExists)
        {
            selectedCustomPalette.colors.append(Color(color:lastSelectedColor))
            self.navigationController?.popViewControllerAnimated(true)
        }
        else
        {
            //TODO: Show popup - color already exists
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

extension UIColor {
    var coreImageColor: CoreImage.CIColor? {
        return CoreImage.CIColor(color: self)  // The resulting Core Image color, or nil
    }
}
