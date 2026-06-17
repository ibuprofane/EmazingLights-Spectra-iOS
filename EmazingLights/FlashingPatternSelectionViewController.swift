//
//  FlashingPatternSelectionViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/18/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class FlashingPatternSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    var sequence:Sequence!
    var sequenceCopy:Sequence!
    var parentMode:Mode!
    var selectedItem:Int = -1
    var editingMode:Bool = false
    var customSelected:Bool = false
    var pageMode:PageMode = .Select // Select, Edit
    var modeEditedDelegate:ModeEditedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(pageMode == .Select)
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FlashingPatternSelectionViewController.save))
            
            self.customSelected = sequence.customFP
            
            var index = -1
            if(customSelected)
            {
                for fp in EmazingSettings.settings.customFlashingPatterns
                {
                    index += 1
                    if(fp.name == sequence.flashingPattern.name)
                    {
                        break
                    }
                }
            }
            else
            {
                for fp in EmazingSettings.settings.stockFlashingPatterns
                {
                    index += 1
                    if(fp.name == sequence.flashingPattern.name)
                    {
                        break
                    }
                }
            }
            
            self.selectedItem = index 
            self.sequenceCopy = sequence.copyObject()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        collectionView.reloadData()
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if(pageMode == .Edit)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.turnOffPreview()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if(EmazingSettings.settings.customFlashingPatterns.count > 0)
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(section == 0) //Stock
        {
            return EmazingSettings.settings.stockFlashingPatterns.count
        }
        else //Custom
        {
            return EmazingSettings.settings.customFlashingPatterns.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("flashingPatternCell", forIndexPath: indexPath) as! FlashingPatternCell
        
        if(indexPath.row == selectedItem && ((indexPath.section == 0 && !customSelected) || (indexPath.section == 1 && customSelected)))
        {
            cell.backgroundColor = UIColor.yellowColor()
        }
        else
        {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        if(indexPath.section == 0)
        {
            let pattern = EmazingSettings.settings.stockFlashingPatterns[indexPath.row]
            cell.flashingPattern = pattern
            
            let patternImage:UIImageView = cell.viewWithTag(100) as! UIImageView
            if(pattern.imageName != "")
            {
                patternImage.image = UIImage(named: pattern.imageName)
            }
            else
            {
                patternImage.image = UIImage(named: "dankFPfiller")
            }
            
            let patternName:UILabel = cell.viewWithTag(101) as! UILabel
            patternName.text = pattern.name
            
            let deleteButton:DeleteFPButton = cell.viewWithTag(102) as! DeleteFPButton
            deleteButton.hidden = true
        }
        else
        {
            let pattern = EmazingSettings.settings.customFlashingPatterns[indexPath.row]
            cell.flashingPattern = pattern
            
            let patternImage:UIImageView = cell.viewWithTag(100) as! UIImageView
            patternImage.image = UIImage(named: "dankFPfiller")
            
            let patternName:UILabel = cell.viewWithTag(101) as! UILabel
            patternName.text = pattern.name
            
            let deleteButton:DeleteFPButton = cell.viewWithTag(102) as! DeleteFPButton
            deleteButton.fpIndex = indexPath.row
            if(editingMode)
            {
                deleteButton.hidden = false
            }
            else
            {
                deleteButton.hidden = true
            }
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if(pageMode == .Select)
        {
            selectedItem = indexPath.row
            
            if(indexPath.section == 0)
            {
                customSelected = false
                sequenceCopy.flashingPattern = EmazingSettings.settings.stockFlashingPatterns[selectedItem]
            }
            else
            {
                customSelected = true
                sequenceCopy.flashingPattern = EmazingSettings.settings.customFlashingPatterns[selectedItem]
            }

            sequenceCopy.customFP = customSelected
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.collectionView.reloadData()
                print("FP #\(indexPath.row) selected")
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.previewSequence(self.sequenceCopy)
            })
        }
        else
        {
            if(!editingMode)
            {
                let controller:FlashPatternEditorViewController = self.storyboard?.instantiateViewControllerWithIdentifier("flashPatternEditor") as! FlashPatternEditorViewController
                
                if(indexPath.section == 0)
                {
                    controller.baseFP = EmazingSettings.settings.stockFlashingPatterns[indexPath.row]
                    controller.modifyingCustom = false
                }
                else
                {
                    controller.baseFP = EmazingSettings.settings.customFlashingPatterns[indexPath.row]
                    controller.modifyingCustom = true
                }
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        //print("Highlighted \(indexPath.row)")
        /*if let cell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            cell.backgroundColor = UIColor.yellowColor()
        }*/
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        //print("Unhighlighted \(indexPath.row)")
    }
    
    func save()
    {
        if(selectedItem != -1)
        {
            if(!customSelected)
            {
                sequence.flashingPattern = EmazingSettings.settings.stockFlashingPatterns[selectedItem]
                sequence.customFP = false
            }
            else
            {
                sequence.flashingPattern = EmazingSettings.settings.customFlashingPatterns[selectedItem]
                sequence.customFP = true
            }
            
            parentMode.updateName()
            EmazingSettings.settings.save()
            
            modeEditedDelegate?.modeWasEdited()
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "fpHeaderView", forIndexPath: indexPath)
        let headerLabel:UILabel = headerView.viewWithTag(100) as! UILabel
        let editButton:UIButton = headerView.viewWithTag(101) as! UIButton
        
        if(indexPath.section == 0)
        {
            headerLabel.text = "Classic Flashing Patterns"
            editButton.hidden = true
        }
        else
        {
            headerLabel.text = "Custom Flashing Patterns"
            editButton.hidden = false
            
            if(editingMode)
            {
                editButton.setTitle("Done", forState: UIControlState.Normal)
            }
            else
            {
                editButton.setTitle("Edit", forState: UIControlState.Normal)
            }
        }
        
        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.width
        let cellWidth = (width / 2) - 15
        let cellHeight = cellWidth / 1.4
        return CGSize(width: cellWidth, height: cellHeight)
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
    
    
    /*func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return false
     }*/
    
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
    
    @IBAction func deletePressed(sender: AnyObject)
    {
        let deleteButton:DeleteFPButton = sender as! DeleteFPButton
        EmazingSettings.settings.customFlashingPatterns.removeAtIndex(deleteButton.fpIndex)
        EmazingSettings.settings.save()
        
        if(EmazingSettings.settings.customFlashingPatterns.count == 0)
        {
            doneEditing()
        }
        
        if(customSelected)
        {
            //If deleting the currently selected color
            if(selectedItem == deleteButton.fpIndex)
            {
                selectedItem = -1
                customSelected = false
            }
                //If deleting a color earlier in the list, decrement selected item
            else if(deleteButton.fpIndex < selectedItem)
            {
                selectedItem -= 1
            }
        }
        
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

class FlashingPatternCell:UICollectionViewCell
{
    var flashingPattern:FlashingPattern!
}

class DeleteFPButton:UIButton
{
    var fpIndex:Int!
}
