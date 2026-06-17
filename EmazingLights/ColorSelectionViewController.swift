//
//  ColorSelectionViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/16/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class ColorSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    var finger:Finger!
    var sequence:Sequence!
    var sequenceCopy:Sequence!
    var selectedCustomPalette:Palette!
    var colorSlot:Int!
    var editingMode:Bool = false
    var selectedItem = -1
    var selectedItemTint:String = "H"
    var customSelected = false
    var disabledSelected = false
    var lastActiveColorCount = 0
    var initializedFromDisabled = false
    var alreadyAppendedTestColor = false
    var modeEditedDelegate:ModeEditedDelegate?
    var displayMode:ColorSelectionDisplayModes = ColorSelectionDisplayModes.ColorSelect
    var exitToController:UIViewController!
    var allowColorAddition:Bool = true
    
    enum ColorSelectionDisplayModes
    {
        case ColorSelect
        case CustomPaletteSelect
        case CustomPaletteEdit
        case SelectFromAllCustomColors
        case PaletteSelect
        case PaletteMenu
        case PaletteMenuEdit
    }
    
    //var initializedFromDisabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self

        if(sequence != nil && (displayMode == .ColorSelect || displayMode == .CustomPaletteSelect))
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ColorSelectionViewController.save))
        }
        
        if(displayMode == .ColorSelect)
        {
            if(finger != nil)
            {
                selectedCustomPalette = finger.defaultPalette
            }
            else
            {
                selectedCustomPalette = EmazingSettings.settings.emptyPalette
            }
        }
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "setEditingMode")
    }
    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.collectionView.reloadData()
        }
        
        if(sequence != nil) //Only perform if a sequence has been defined
        {
            sequenceCopy = sequence.copyObject()

            collectionView.delegate = self
            lastActiveColorCount = numberOfActiveColors(sequence.colorSet)
            
            if(colorSlot < sequence.colorSet.count)
            {
                let color = sequence.colorSet[colorSlot]
                
                if(displayMode == .ColorSelect)
                {
                    var colorMatched:Bool = false
                    for index in 0..<EmazingSettings.settings.stockColors.count
                    {
                        if(color.compareTo(EmazingSettings.settings.stockColors[index]))
                        {
                            colorMatched = true
                            customSelected = false
                            selectedItem = index
                            selectedItemTint = sequence.colorTints[colorSlot]
                            break
                        }
                    }
                    
                    if(!colorMatched)
                    {
                        for index in 0..<selectedCustomPalette.colors.count
                        {
                            if(color.compareTo(selectedCustomPalette.colors[index]))
                            {
                                colorMatched = true
                                customSelected = true
                                selectedItem = index
                                selectedItemTint = sequence.colorTints[colorSlot]
                                break
                            }
                        }
                    }
                }
                else if(displayMode == .CustomPaletteSelect)
                {
                    for index in 0..<selectedCustomPalette.colors.count
                    {
                        if(color.compareTo(selectedCustomPalette.colors[index]))
                        {
                            customSelected = true
                            selectedItem = index
                            selectedItemTint = sequence.colorTints[colorSlot]
                            break
                        }
                    }
                }
            }
            else
            {
                //Disable selected
                initializedFromDisabled = true
                colorSlot = sequence.colorSet.count
                disabledSelected = true
                selectedItem = EmazingSettings.settings.stockColors.count
            }
            
            if(displayMode == .ColorSelect && EmazingSettings.settings.photoHubs.count > 0)
            {
                doSequenceUpdate(sequenceCopy)
            }
        }
    }
    
    func save()
    {
        if(selectedItem != -1)
        {
            if(customSelected)
            {
                if(self.sequence.colorSet.count > colorSlot)
                {
                    self.sequence.colorSet[colorSlot] = selectedCustomPalette.colors[selectedItem]
                }
                else
                {
                    self.sequence.colorSet.append(selectedCustomPalette.colors[selectedItem])
                }
            }
            else if(disabledSelected)
            {
                if(self.sequence.colorSet.count > colorSlot)
                {
                    self.sequence.colorSet[colorSlot] = Color(disabled: true)
                }
            }
            else
            {
                if(self.sequence.colorSet.count > colorSlot)
                {
                    self.sequence.colorSet[colorSlot] = EmazingSettings.settings.stockColors[selectedItem]
                }
                else
                {
                    self.sequence.colorSet.append(EmazingSettings.settings.stockColors[selectedItem])
                }
            }
            
            if(self.sequence.colorTints.count > colorSlot)
            {
                self.sequence.colorTints[colorSlot] = selectedItemTint
            }
            else
            {
                self.sequence.colorTints.append(selectedItemTint)
            }
            
            let cleanedColorsAndTints = cleanColorsAndTints(self.sequence.colorSet, tints: self.sequence.colorTints)
            self.sequence.colorSet = cleanedColorsAndTints.colors
            self.sequence.colorTints = cleanedColorsAndTints.tints
            
            EmazingSettings.settings.save()
            sequenceCopy = nil
            
            modeEditedDelegate?.modeWasEdited()
            
            //self.navigationController?.popViewControllerAnimated(true)
            self.navigationController?.popToViewController(exitToController, animated: true)
        }
    }
    
    func cleanColorsAndTints(colorSet:[Color], tints:[String])->(colors:[Color], tints:[String])
    {
        var newColorSet:[Color] = []
        var newTints:[String] = []
        for index in 0..<colorSet.count
        {
            if(!colorSet[index].disabled)
            {
                newColorSet.append(colorSet[index])
                if(index < tints.count)
                {
                    newTints.append(tints[index])
                }
                else
                {
                    newTints.append("H")
                }
            }
        }
        return (newColorSet, newTints)
    }
    
    func cleanColorSet(colorSet:[Color])->[Color]
    {
        var newColorSet:[Color] = []
        for color in colorSet
        {
            if(!color.disabled)
            {
                newColorSet.append(color)
            }
        }
        return newColorSet
    }
    
    func numberOfActiveColors(colorSet:[Color])->Int
    {
        var numColors:Int = 0
        for color in colorSet
        {
            if(!color.disabled)
            {
                numColors += 1
            }
        }
        return numColors
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if(displayMode == .ColorSelect)
        {
            return 2
        }
        else if(displayMode == .SelectFromAllCustomColors)
        {
            return EmazingSettings.settings.customPalettes.count
        }
        else
        {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        switch displayMode
        {
        case .CustomPaletteSelect:
            return selectedCustomPalette.colors.count + 2 //Extra 2 for "Add Existing" and "Add New"
        case .CustomPaletteEdit:
            return selectedCustomPalette.colors.count + 2 //Extra 2 for "Add Existing" and "Add New"
        case .PaletteMenu:
            return EmazingSettings.settings.customPalettes.count
        case .PaletteSelect:
            return EmazingSettings.settings.customPalettes.count
        case .PaletteMenuEdit:
            return EmazingSettings.settings.customPalettes.count + 1 //Extra 1 for "Add Palette"
        case .SelectFromAllCustomColors:
            return EmazingSettings.settings.customPalettes[section].colors.count
        default: //ColorSelect
            if(section == 0) //Stock
            {
                return EmazingSettings.settings.stockColors.count + 1 //Extra 1 for Disabled
            }
            else //Custom
            {
                if(allowColorAddition)
                {
                    return selectedCustomPalette.colors.count + 2 //Extra 2 for "Add Existing" and "Add New"
                }
                else
                {
                    return selectedCustomPalette.colors.count
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if(displayMode == .CustomPaletteEdit || displayMode == .CustomPaletteSelect)
        {
            if(indexPath.row < selectedCustomPalette.colors.count)
            {
                let color = selectedCustomPalette.colors[indexPath.row]
                return createColorDotCell(indexPath, color: color, customColor: true)
            }
            else if (indexPath.row == selectedCustomPalette.colors.count) //Add custom color cell
            {
                let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("addColorCell", forIndexPath: indexPath) as! ColorDotCell
                return cell
            }
            else
            {
                let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("addExistingColorCell", forIndexPath: indexPath) as! ColorDotCell
                return cell
            }
        }
        else if(displayMode == .PaletteMenu || displayMode == .PaletteSelect)
        {
            let palette = EmazingSettings.settings.customPalettes[indexPath.row]
            return createPaletteCell(indexPath, palette: palette)
        }
        else if(displayMode == .PaletteMenuEdit)
        {
            if(indexPath.row < EmazingSettings.settings.customPalettes.count)
            {
                let palette = EmazingSettings.settings.customPalettes[indexPath.row]
                return createPaletteCell(indexPath, palette: palette)
            }
            else
            {
                let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("addNewPalette", forIndexPath: indexPath) as! ColorDotCell
                return cell
            }
        }
        if(displayMode == .SelectFromAllCustomColors)
        {
            let color = EmazingSettings.settings.customPalettes[indexPath.section].colors[indexPath.row]
            return createColorDotCell(indexPath, color: color, customColor: true)
        }
        else
        {
            if(indexPath.section == 0) //Stock
            {
                if(indexPath.row >= EmazingSettings.settings.stockColors.count)
                {
                    return createDisabledCell(indexPath)
                }
                
                let color = EmazingSettings.settings.stockColors[indexPath.row]
                
                if(color.fixedColorRef == 1) //Blank
                {
                    return createBlankDotCell(indexPath, color: color)
                }
                else
                {
                    return createColorDotCell(indexPath, color: color)
                }
            }
            else //Custom
            {
                if(indexPath.row < selectedCustomPalette.colors.count)
                {
                    let color = selectedCustomPalette.colors[indexPath.row]
                    return createColorDotCell(indexPath, color: color, customColor: true)
                }
                else if (indexPath.row == selectedCustomPalette.colors.count) //Add custom color cell
                {
                    let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("addColorCell", forIndexPath: indexPath) as! ColorDotCell
                    return cell
                }
                else
                {
                    let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("addExistingColorCell", forIndexPath: indexPath) as! ColorDotCell
                    return cell
                }
            }
        }
    }
    
    func createPaletteCell(indexPath: NSIndexPath, palette:Palette) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("colorPaletteCell", forIndexPath: indexPath) as! ColorDotCell
        cell.palette = palette

        let startingTag = 201
        for i in 0..<9
        {
            if(i < palette.colors.count)
            {
                let color = palette.colors[i]
                let colorValue = color.getUIColor()
                let colorDot:ColorDotView = cell.viewWithTag(startingTag + i) as! ColorDotView
                colorDot.assignColor(colorValue, tint: "H")
                colorDot.hidden = false
            }
            else
            {
                let colorDot:ColorDotView = cell.viewWithTag(startingTag + i) as! ColorDotView
                colorDot.hidden = true
            }
        }
        
        //If empty, show empty text
        let emptyLabel:UILabel = cell.viewWithTag(103) as! UILabel
        if(palette.colors.count > 0)
        {
            emptyLabel.hidden = true
        }
        else
        {
            emptyLabel.hidden = false
        }
        
        let nameLabel:UILabel = cell.viewWithTag(101) as! UILabel
        nameLabel.text = palette.name
        
        let deleteButton:DeleteColorButton = cell.viewWithTag(102) as! DeleteColorButton
        deleteButton.paletteIndex = indexPath.row
        if(editingMode)
        {
            deleteButton.hidden = false
        }
        else
        {
            deleteButton.hidden = true
        }
        
        return cell
    }
    
    func createColorDotCell(indexPath: NSIndexPath, color:Color, customColor:Bool = false) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("colorDotCell", forIndexPath: indexPath) as! ColorDotCell
        cell.color = color
        
        var tint = "H"
        if(customSelected && ((displayMode == .ColorSelect && indexPath.section == 1) || displayMode == .CustomPaletteSelect) && sequence != nil && indexPath.row == selectedItem)
        {
            cell.backgroundColor = UIColor.purpleColor()
            tint = selectedItemTint
        }
        else if(!customSelected && ((displayMode == .ColorSelect && indexPath.section == 0) || displayMode == .CustomPaletteSelect) && sequence != nil && indexPath.row == selectedItem)
        {
            cell.backgroundColor = UIColor.purpleColor()
            tint = selectedItemTint
        }
        else
        {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        var colorValue:UIColor!
        if(!customColor)
        {
            var cleanedColor = color
            if(color.fixedColorRef == 0) //Fix for white
            {
                cleanedColor = Color(red: 255, green: 255, blue: 255)
            }
            colorValue = cleanedColor.getUIColor()
        }
        else
        {
            colorValue = color.getUIColor()
        }
        
        let colorName = EmazingConstants.constants.colorNames.nameForColor(colorValue)
        
        let colorDot:ColorDotView = cell.viewWithTag(100) as! ColorDotView
        colorDot.assignColor(colorValue, tint: tint)
        
        let colorNameLabel:UILabel = cell.viewWithTag(101) as! UILabel
        colorNameLabel.text = colorName.capitalizedString
        
        let deleteButton:DeleteColorButton = cell.viewWithTag(102) as! DeleteColorButton
        if(customColor && editingMode)
        {
            deleteButton.colorIndex = indexPath.row
            deleteButton.hidden = false
        }
        else
        {
            deleteButton.hidden = true
        }
        
        let tintLabel:UILabel = cell.viewWithTag(103) as! UILabel
        if(tint == "H")
        {
            tintLabel.hidden = true
        }
        else
        {
            tintLabel.text = selectedItemTint
            tintLabel.hidden = false
        }
        
        return cell
    }
    
    func createBlankDotCell(indexPath: NSIndexPath, color:Color) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("blankDotCell", forIndexPath: indexPath) as! ColorDotCell
        cell.color = color
        
        if(indexPath.row == selectedItem && !customSelected)
        {
            cell.backgroundColor = UIColor.purpleColor()
        }
        else
        {
            cell.backgroundColor = UIColor.blackColor()
        }
        return cell
    }
    
    func createDisabledCell(indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("disabledDotCell", forIndexPath: indexPath) as! ColorDotCell
        cell.color = Color(disabled: true)
        
        if(indexPath.row == selectedItem && disabledSelected)
        {
            cell.backgroundColor = UIColor.purpleColor()
        }
        else
        {
            cell.backgroundColor = UIColor.blackColor()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if(!editingMode)
        {
            if(displayMode == .ColorSelect)
            {
                if(indexPath.section == 1 && indexPath.row == selectedCustomPalette.colors.count)
                {
                    //Add New Color
                    goToAddCustomColor()
                }
                else if(indexPath.section == 1 && indexPath.row == selectedCustomPalette.colors.count + 1)
                {
                    //Add Existing Color
                    goToAddExistingColor()
                }
                else
                {
                    colorDotSelected(indexPath)
                }
            }
            else if(displayMode == .CustomPaletteEdit || displayMode == .CustomPaletteSelect)
            {
                //If Add Color Selected
                if(indexPath.row == selectedCustomPalette.colors.count)
                {
                    goToAddCustomColor()
                }
                else if(indexPath.row > selectedCustomPalette.colors.count)
                {
                    goToAddExistingColor()
                }
                else
                {
                    colorDotSelected(indexPath)
                }
            }
            else if(displayMode == .SelectFromAllCustomColors)
            {
                colorDotSelected(indexPath)
            }
            else if(displayMode == .PaletteSelect)
            {
                finger.defaultPalette = EmazingSettings.settings.customPalettes[indexPath.row]
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            else if(displayMode == .PaletteMenu)
            {
                let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
                
                //TODO: Adjust for multiple sequences and slots
                controller.sequence = sequence
                controller.colorSlot = colorSlot
                controller.finger = finger
                controller.displayMode = .CustomPaletteSelect
                controller.modeEditedDelegate = modeEditedDelegate
                controller.selectedCustomPalette = EmazingSettings.settings.customPalettes[indexPath.row]
                controller.exitToController = exitToController
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else if(displayMode == .PaletteMenuEdit)
            {
                //Palette was pressed
                if(indexPath.row < EmazingSettings.settings.customPalettes.count)
                {
                    goToPaletteMenuEdit(indexPath.row)
                }
                else //Add New Palette was pressed
                {
                    let alertController = UIAlertController(title: "Create New Palette", message: "Please enter a name for your new color palette.", preferredStyle: .Alert)
                    
                    alertController.addTextFieldWithConfigurationHandler { (textField) in
                        textField.addTarget(self, action: #selector(ColorSelectionViewController.textChanged(_:)), forControlEvents: .EditingChanged)
                        textField.placeholder = "Palette Name"
                        textField.keyboardType = .Default
                        textField.autocapitalizationType = UITextAutocapitalizationType.Words
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                        print(action)
                    }
                    
                    alertController.addAction(cancelAction)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                        let nameTextField = alertController.textFields![0] as UITextField
                        let name = nameTextField.text
                        let newPalette = Palette(name: name!, colors: [])
                        EmazingSettings.settings.customPalettes.append(newPalette)
                        EmazingSettings.settings.save()
                        self.goToPaletteMenuEdit(indexPath.row)
                    }
                    alertController.addAction(okAction)
                    
                    (alertController.actions[1] as UIAlertAction).enabled = false
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func goToAddCustomColor()
    {
        //Go to add custom color segue
        let controller:CustomColorViewController = self.storyboard?.instantiateViewControllerWithIdentifier("customColorView") as! CustomColorViewController
        controller.selectedCustomPalette = selectedCustomPalette
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToAddExistingColor()
    {
        let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
        
        controller.sequence = sequence
        controller.colorSlot = colorSlot
        controller.finger = finger
        controller.displayMode = .SelectFromAllCustomColors
        controller.modeEditedDelegate = modeEditedDelegate
        controller.selectedCustomPalette = selectedCustomPalette
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToPaletteMenuEdit(index:Int)
    {
        let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
        
        //TODO: Adjust for multiple sequences and slots
        controller.sequence = sequence
        controller.colorSlot = colorSlot
        controller.finger = finger
        controller.displayMode = .CustomPaletteEdit
        controller.modeEditedDelegate = modeEditedDelegate
        controller.selectedCustomPalette = EmazingSettings.settings.customPalettes[index]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func textChanged(sender:AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as! UIAlertController
        (alert.actions[1] as UIAlertAction).enabled = (tf.text != "")
    }
    
    func colorDotSelected(indexPath:NSIndexPath)
    {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! ColorDotCell
        
        let blankSelected = (indexPath.section == 0 && indexPath.row == 1)
        //If current item was selected and isn't "Blank"
        if((self.selectedItem == indexPath.row && !blankSelected && displayMode == .ColorSelect) ||
            (self.selectedItem == indexPath.row && (displayMode == .CustomPaletteSelect)))
        {
            if(self.selectedItemTint == "H")
            {
                self.selectedItemTint = "M"
            }
            else if(self.selectedItemTint == "M")
            {
                self.selectedItemTint = "L"
            }
            else if(self.selectedItemTint == "L")
            {
                self.selectedItemTint = "H"
            }
        }
        else //If a different color was selected
        {
            self.selectedItem = indexPath.row
            self.selectedItemTint = "H"
        }
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.collectionView.reloadData()
        }
        
        //If we came to the page from a disabled color, but selected a different color
        if(displayMode == .SelectFromAllCustomColors)
        {
            if(selectedCustomPalette != nil)
            {
                let copiedColor = selectedCell.color.copyObject()
                selectedCustomPalette.colors.append(copiedColor)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else if(initializedFromDisabled && !selectedCell.color.disabled && !alreadyAppendedTestColor)
        {
            self.sequenceCopy.colorSet.append(selectedCell.color)
            
            let cleanedColorsAndTints = cleanColorsAndTints(self.sequenceCopy.colorSet, tints: self.sequenceCopy.colorTints)
            self.sequenceCopy.colorSet = cleanedColorsAndTints.colors
            self.sequenceCopy.colorTints = cleanedColorsAndTints.tints
            
            disabledSelected = false
            
            if(indexPath.section == 0)
            {
                customSelected = false
            }
            else
            {
                customSelected = true
            }
            
            alreadyAppendedTestColor = true
            doSequenceUpdate(sequenceCopy)
        }
        else
        {
            //If the selected color was not "Disabled"
            if(!selectedCell.color.disabled)
            {
                var refreshSequence:Bool = false
                
                //If disabled was selected last, resend original sequence
                if(disabledSelected)
                {
                    sequenceCopy = sequence.copyObject()
                    refreshSequence = true
                }
                
                disabledSelected = false
                
                //If we selected a stock color
                if(indexPath.section == 0 && displayMode == .ColorSelect)
                {
                    if(refreshSequence)
                    {
                        if(self.sequenceCopy.colorSet.count > colorSlot)
                        {
                            self.sequenceCopy.colorSet[colorSlot] = EmazingSettings.settings.stockColors[selectedItem]
                        }
                        else
                        {
                            self.sequenceCopy.colorSet.append(EmazingSettings.settings.stockColors[selectedItem])
                        }
                        
                        if(self.sequenceCopy.colorTints.count > colorSlot)
                        {
                            self.sequenceCopy.colorTints[colorSlot] = selectedItemTint
                        }
                        else
                        {
                            self.sequenceCopy.colorTints.append(selectedItemTint)
                        }
                        doSequenceUpdate(sequenceCopy)
                        refreshSequence = false
                    }
                    customSelected = false
                    doColorPreviewUpdate(colorSlot, color: selectedCell.color, tint: selectedItemTint)
                }
                else //If we selected a custom color
                {
                    if(refreshSequence)
                    {
                        if(self.sequenceCopy.colorSet.count > colorSlot)
                        {
                            self.sequenceCopy.colorSet[colorSlot] = selectedCustomPalette.colors[selectedItem]
                        }
                        else
                        {
                            self.sequenceCopy.colorSet.append(selectedCustomPalette.colors[selectedItem])
                        }
                        
                        if(self.sequenceCopy.colorTints.count > colorSlot)
                        {
                            self.sequenceCopy.colorTints[colorSlot] = selectedItemTint
                        }
                        else
                        {
                            self.sequenceCopy.colorTints.append(selectedItemTint)
                        }
                        doSequenceUpdate(sequenceCopy)
                        refreshSequence = false
                    }
                    
                    customSelected = true
                    doColorPreviewUpdate(colorSlot, color: selectedCell.color, tint: selectedItemTint)
                }
            }
            else //If the selected color is "Disabled"
            {
                if(!disabledSelected)
                {
                    disabledSelected = true
                    customSelected = false
                    if(sequenceCopy.colorSet.count > colorSlot)
                    {
                        self.sequenceCopy.colorSet[colorSlot] = Color(disabled: true)
                    }
                    else
                    {
                        self.sequenceCopy.colorSet.append(Color(disabled: true))
                    }
                    
                    let cleanedColorsAndTints = cleanColorsAndTints(self.sequenceCopy.colorSet, tints: self.sequenceCopy.colorTints)
                    self.sequenceCopy.colorSet = cleanedColorsAndTints.colors
                    self.sequenceCopy.colorTints = cleanedColorsAndTints.tints
                    
                    alreadyAppendedTestColor = false
                    doSequenceUpdate(sequenceCopy)
                    
                    //doColorPreviewUpdate(colorSlot, color: Color(red: 0, green: 0, blue: 0))
                }
            }
        }
    }
    
    func doColorPreviewUpdate(slot:Int?, color:Color, tint:String)
    {
        if(slot != nil)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.updatePreviewColorSlot(slot!, color: color, tint: tint)
            })
        }
    }
    
    func doSequenceUpdate(sequence:Sequence)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            EmazingCommManager.commManager.syncManager.previewSequence(sequence)
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "colorSectionHeader", forIndexPath: indexPath)
        let titleLabel:UILabel = headerView.viewWithTag(100) as! UILabel
        let infoLabel:UILabel = headerView.viewWithTag(103) as! UILabel
        let editButton:UIButton = headerView.viewWithTag(101) as! UIButton
        let palettesButton:UIButton = headerView.viewWithTag(102) as! UIButton
        let centeredTitleLabel:UILabel = headerView.viewWithTag(104) as! UILabel
        
        if(displayMode == .CustomPaletteSelect) //Came from selection page
        {
            editButton.hidden = false
            palettesButton.hidden = true
            infoLabel.hidden = false
            titleLabel.text = selectedCustomPalette.name
            centeredTitleLabel.hidden = true
            
            if(editingMode)
            {
                editButton.setTitle("Done", forState: UIControlState.Normal)
            }
            else
            {
                editButton.setTitle("Edit", forState: UIControlState.Normal)
            }
        }
        else if(displayMode == .CustomPaletteEdit)
        {
            editButton.hidden = false
            palettesButton.hidden = true
            infoLabel.hidden = true
            titleLabel.hidden = true
            centeredTitleLabel.text = selectedCustomPalette.name
            centeredTitleLabel.hidden = false
            
            if(editingMode)
            {
                editButton.setTitle("Done", forState: UIControlState.Normal)
            }
            else
            {
                editButton.setTitle("Edit", forState: UIControlState.Normal)
            }
        }
        else if(displayMode == .PaletteMenu)
        {
            editButton.hidden = true
            palettesButton.hidden = true
            infoLabel.hidden = true
            titleLabel.hidden = true
            centeredTitleLabel.text = "Custom Color Palettes"
            centeredTitleLabel.hidden = false
        }
        else if(displayMode == .PaletteMenuEdit)
        {
            editButton.hidden = false
            palettesButton.hidden = true
            infoLabel.hidden = true
            titleLabel.hidden = true
            centeredTitleLabel.text = "Custom Color Palettes"
            centeredTitleLabel.hidden = false

            if(editingMode)
            {
                editButton.setTitle("Done", forState: UIControlState.Normal)
            }
            else
            {
                editButton.setTitle("Edit", forState: UIControlState.Normal)
            }
        }
        else if(displayMode == .SelectFromAllCustomColors)
        {
            editButton.hidden = true
            palettesButton.hidden = true
            infoLabel.hidden = true
            titleLabel.hidden = true
            centeredTitleLabel.text = EmazingSettings.settings.customPalettes[indexPath.section].name
            centeredTitleLabel.hidden = false
        }
        else //ColorSelect
        {
            editButton.hidden = true
            centeredTitleLabel.hidden = true
            infoLabel.hidden = false
            titleLabel.hidden = false
            
            if(indexPath.section == 0)
            {
                titleLabel.text = "Classic Colors"
                palettesButton.hidden = true
            }
            else
            {
                titleLabel.text = selectedCustomPalette.name
                palettesButton.hidden = false
            }
        }

        return headerView
    }
    
    @IBAction func editButtonPressed(sender: AnyObject)
    {
        if(editingMode == false)
        {
            setEditingMode()
        }
        else
        {
            doneEditing()
        }
    }

    @IBAction func palettesButtonPressed(sender: AnyObject)
    {
        let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
        
        //TODO: Adjust for multiple sequences and slots
        controller.sequence = sequence
        controller.colorSlot = colorSlot
        controller.finger = finger
        controller.displayMode = .PaletteMenu
        controller.modeEditedDelegate = modeEditedDelegate
        controller.exitToController = exitToController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /*func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEditingMode()
    {
        editingMode = true
        collectionView.reloadData()
    }
    
    func doneEditing()
    {
        editingMode = false
        collectionView.reloadData()
    }
    
    @IBAction func deleteColorPressed(sender: AnyObject)
    {
        let deleteButton:DeleteColorButton = sender as! DeleteColorButton
        selectedCustomPalette.colors.removeAtIndex(deleteButton.colorIndex)
        EmazingSettings.settings.save()
        
        if(customSelected)
        {
            //If deleting the currently selected color
            if(selectedItem == deleteButton.colorIndex)
            {
                selectedItem = -1
                customSelected = false
            }
                //If deleting a color earlier in the list, decrement selected item
            else if(deleteButton.colorIndex < selectedItem)
            {
                selectedItem -= 1
            }
        }

        collectionView.reloadData()
    }
    
    @IBAction func deletePalettePressed(sender: AnyObject)
    {
        let deleteButton:DeleteColorButton = sender as! DeleteColorButton
        EmazingSettings.settings.customPalettes.removeAtIndex(deleteButton.paletteIndex)
        EmazingSettings.settings.save()
        
        collectionView.reloadData()
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

class ColorDotCell:UICollectionViewCell
{
    var color:Color!
    var palette:Palette!
}

class DeleteColorButton:UIButton
{
    var colorIndex:Int!
    var paletteIndex:Int!
}
