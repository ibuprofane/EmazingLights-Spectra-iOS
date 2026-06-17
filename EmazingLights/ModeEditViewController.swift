//
//  ModeEditViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/30/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

protocol ModeEditedDelegate
{
    func modeWasEdited()
}

class ModeEditViewController: UIViewController, UIScrollViewDelegate, ModeEditedDelegate {

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet var editButton:UIButton!
    @IBOutlet var titleEditField: UITextField!
    var headerHeightConstraint:NSLayoutConstraint!
    
    var fp1Button: UIButton!
    var fp1Label:UILabel!
    var fp2Button: UIButton!
    var fp2Label:UILabel!
    var seq1Colors: SelectedColorsContainerViewController!
    var seq2Colors: SelectedColorsContainerViewController!
    var nextPrevButton: UIButton!
    var currentSequencePage:Int = 0
    
    var mode:Mode!
    var modeSlot:Int = 0
    var tempModeCopy:Mode!
    var finger:Finger!
    var usingOTFMode:Bool = false
    var customModeSelected:Bool = false
    var displayMode:PageMode = PageMode.Edit
    
    override func loadView() {
        super.loadView()
        
        if(displayMode == .DirectEdit)
        {
            tempModeCopy = mode
        }
        else
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save As...", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ModeEditViewController.saveAs))
            
            tempModeCopy = mode.copyObject()
        }
        
        if(!usingOTFMode || displayMode == .DirectEdit)
        {
            titleLabel.text = mode.name
        }
        else
        {
            titleLabel.text = "Custom Mode"
        }
        
        let screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.size.width
        let screenHeight = screenSize.size.height
        
        //Variables are defaulted for iPhone 4S screen size
        var fpButtonWidth:CGFloat = screenWidth * 0.7
        var fpButtonHeight:CGFloat = screenHeight * 0.25
        var fpButtonY:CGFloat = 10.0
        var csViewWidth:CGFloat = 320.0
        var csViewHeight:CGFloat = 180.0
        var csViewY:CGFloat = fpButtonHeight + fpButtonY + 5.0
        if(screenHeight > 700.0) //iPhone 6 Plus
        {
            print("Using iPhone 6+ screen size")
            fpButtonWidth = screenWidth * 0.80
            fpButtonHeight = screenHeight * 0.32
            fpButtonY = 20.0
            csViewWidth = 320.0
            csViewHeight = 198.0
            csViewY = fpButtonHeight + fpButtonY + 15.0
        }
        else if(screenHeight > 600.0) //iPhone 6
        {
            print("Using iPhone 6 screen size")
            fpButtonWidth = screenWidth * 0.80
            fpButtonHeight = screenHeight * 0.32
            fpButtonY = 20.0
            csViewWidth = 320.0
            csViewHeight = 180.0
            csViewY = fpButtonHeight + fpButtonY + 15.0
        }
        else if(screenHeight > 500.0) //iPhone 5 + 5s + iPod
        {
            print("Using iPhone 5 screen size")
            fpButtonWidth = screenWidth * 0.8
            fpButtonHeight = screenHeight * 0.3
            fpButtonY = 10.0
            csViewWidth = 320.0
            csViewHeight = 180.0
            csViewY = fpButtonHeight + fpButtonY + 15.0
        }
        else
        {
            print("Using iPhone 4S screen size")
        }
        
        let fp1ButtonFrame:CGRect = CGRectMake(screenWidth / 2 - fpButtonWidth / 2, fpButtonY, fpButtonWidth, fpButtonHeight)
        fp1Button = UIButton(frame: fp1ButtonFrame)
        fp1Button.layer.backgroundColor = UIColor.blackColor().CGColor
        fp1Button.addTarget(self, action: #selector(ModeEditViewController.patternSelectPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        fp1Button.tag = 0
        scrollView.addSubview(fp1Button)
        
        let fp1LabelFrame:CGRect = CGRectMake(screenWidth / 2 - fpButtonWidth / 2, fpButtonY + fpButtonHeight - 26, fpButtonWidth, 26)
        fp1Label = UILabel(frame: fp1LabelFrame)
        fp1Label.layer.backgroundColor = UIColor.grayColor().CGColor
        fp1Label.textAlignment = NSTextAlignment.Center
        scrollView.addSubview(fp1Label)
        
        let fp2ButtonFrame:CGRect = CGRectMake(screenWidth + (screenWidth / 2 - fpButtonWidth / 2), fpButtonY, fpButtonWidth, fpButtonHeight)
        fp2Button = UIButton(frame: fp2ButtonFrame)
        fp2Button.layer.backgroundColor = UIColor.blackColor().CGColor
        fp2Button.addTarget(self, action: #selector(ModeEditViewController.patternSelectPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        fp2Button.tag = 1
        scrollView.addSubview(fp2Button)
        
        let fp2LabelFrame:CGRect = CGRectMake(screenWidth + (screenWidth / 2 - fpButtonWidth / 2), fpButtonY + fpButtonHeight - 26, fpButtonWidth, 26)
        fp2Label = UILabel(frame: fp2LabelFrame)
        fp2Label.layer.backgroundColor = UIColor.grayColor().CGColor
        fp2Label.textAlignment = NSTextAlignment.Center
        scrollView.addSubview(fp2Label)
        
        let cs1ViewFrame:CGRect = CGRectMake(screenWidth / 2 - csViewWidth / 2, csViewY, csViewWidth, csViewHeight)
        let cs1View:UIView = UIView(frame: cs1ViewFrame)
        cs1View.layer.backgroundColor = UIColor.orangeColor().CGColor
        cs1View.tag = 0
        scrollView.addSubview(cs1View)
        
        let colorSelect1ViewController = MyChildViewController.embed("selectedColorsEmbedView", storyboardName: "Main", containerViewController: self, containerView: cs1View)
        self.seq1Colors = colorSelect1ViewController as! SelectedColorsContainerViewController
        self.seq1Colors.sequence = tempModeCopy.sequences[0]
        self.seq1Colors.finger = finger
        self.seq1Colors.modeEditedDelegate = self
        self.seq1Colors.exitToController = self
        self.seq1Colors.modeDisplayMode = displayMode
        
        let cs2ViewFrame:CGRect = CGRectMake(screenWidth + (screenWidth / 2 - csViewWidth / 2), csViewY, csViewWidth, csViewHeight)
        let cs2View:UIView = UIView(frame: cs2ViewFrame)
        cs2View.layer.backgroundColor = UIColor.orangeColor().CGColor
        cs2View.tag = 1
        scrollView.addSubview(cs2View)
        
        let colorSelect2ViewController = MyChildViewController.embed("selectedColorsEmbedView", storyboardName: "Main", containerViewController: self, containerView: cs2View)
        self.seq2Colors = colorSelect2ViewController as! SelectedColorsContainerViewController
        self.seq2Colors.sequence = tempModeCopy.sequences[1]
        self.seq2Colors.finger = finger
        self.seq2Colors.modeEditedDelegate = self
        self.seq2Colors.exitToController = self
        self.seq2Colors.modeDisplayMode = displayMode
        
        headerHeightConstraint = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 90)
        self.view.addConstraint(headerHeightConstraint)
        
        //descriptionTextView.text = mode.description
    }

    override func viewDidLayoutSubviews() {
        let screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.size.width
        //let screenHeight = screenSize.size.height
        
        let contentSize = CGSize(width: screenWidth * 2, height: scrollView.frame.height)
        scrollView.contentSize = contentSize
        
        let nextButtonWidth:CGFloat = 60.0
        let nextButtonHeight:CGFloat = 80.0
        let nextButtonFrame:CGRect = CGRectMake(screenWidth - nextButtonWidth / 2, 20.0, nextButtonWidth, nextButtonHeight)
        let nextButton:UIButton = UIButton(frame: nextButtonFrame)
        nextButton.setImage(UIImage(named: "NextSequenceButton"), forState: UIControlState.Normal)
        //nextButton.layer.backgroundColor = UIColor.grayColor().CGColor
        nextButton.addTarget(self, action: #selector(ModeEditViewController.toggleSequencePage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(nextButton)
        
        let randomButtonWidth:CGFloat = 40.0
        let randomButtonHeight:CGFloat = 40.0
        
        let randomButton1Frame:CGRect = CGRectMake(20.0, 10.0, randomButtonWidth, randomButtonHeight)
        let random1Button:UIButton = UIButton(frame: randomButton1Frame)
        random1Button.layer.backgroundColor = UIColor.clearColor().CGColor
        random1Button.setImage(UIImage(named: "randombutton"), forState: UIControlState.Normal)
        random1Button.tag = 0
        random1Button.addTarget(self, action: #selector(ModeEditViewController.randomButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(random1Button)
        
        let randomButton2Frame:CGRect = CGRectMake(contentSize.width - randomButtonWidth - 20.0, 10.0, randomButtonWidth, randomButtonHeight)
        let random2Button:UIButton = UIButton(frame: randomButton2Frame)
        random2Button.layer.backgroundColor = UIColor.clearColor().CGColor
        random2Button.setImage(UIImage(named: "randombutton"), forState: UIControlState.Normal)
        random2Button.tag = 1
        random2Button.addTarget(self, action: #selector(ModeEditViewController.randomButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(random2Button)
        
        self.setFPImages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
    }
    
    func modeWasEdited()
    {
        if(displayMode != .DirectEdit)
        {
            finger.otfModes[modeSlot] = tempModeCopy
            EmazingSettings.settings.save()
            
            titleLabel.text = "Custom Mode"
            usingOTFMode = true
        }
    }
    
    func saveAs()
    {
        let alertController = UIAlertController(title: "Save As New Mode", message: "Create and save a new mode with the current settings.", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.addTarget(self, action: #selector(ModeEditViewController.textChanged(_:)), forControlEvents: .EditingChanged)
            textField.placeholder = "Mode Name"
            textField.keyboardType = .Default
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print(action)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            self.doSaveAs(nameTextField.text!, modeToCopy: self.tempModeCopy)
        }
        alertController.addAction(okAction)
        
        (alertController.actions[1] as UIAlertAction).enabled = false
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textChanged(sender:AnyObject) {
        let tf = sender as! UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as! UIAlertController
        (alert.actions[1] as UIAlertAction).enabled = (tf.text != "")
    }
    
    func doSaveAs(name:String, modeToCopy:Mode)
    {
        //Check for duplicates
        var duplicateFound:Bool = false
        for mode in EmazingSettings.settings.customModes
        {
            if(mode.name == name)
            {
                duplicateFound = true
            }
        }
        
        if(!duplicateFound)
        {
            let modeCopy = modeToCopy.copyObject()
            modeCopy.name = name
            
            EmazingSettings.settings.customModes.append(modeCopy)
            
            finger.modes[modeSlot] = modeCopy
            finger.otfModes[modeSlot] = nil
            
            self.navigationController?.popViewControllerAnimated(true)
        }
        else
        {
            //Present notice to user
            let alertController = UIAlertController(title: "Duplicate Name", message: "A custom mode with this name already exists. Please choose a unique name.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func setFPImages()
    {
        fp1Button.setImage(UIImage(named: tempModeCopy.sequences[0].flashingPattern.imageName), forState: UIControlState.Normal)
        fp1Label.text = tempModeCopy.sequences[0].flashingPattern.name
        fp2Button.setImage(UIImage(named: tempModeCopy.sequences[1].flashingPattern.imageName), forState: UIControlState.Normal)
        fp2Label.text = tempModeCopy.sequences[1].flashingPattern.name
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setFPImages()
        
        if(EmazingSettings.settings.photoHubs.count > 0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.previewSequence(self.tempModeCopy.sequences[self.currentSequencePage])
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomButtonPressed(sender: UIButton) {
        let tag = sender.tag
        
        let randomFPInt = Int.random(min: 0, max: EmazingSettings.settings.stockFlashingPatterns.count - 1)
        let randomFlashingPattern = EmazingSettings.settings.stockFlashingPatterns[randomFPInt]
        tempModeCopy.sequences[tag].flashingPattern = randomFlashingPattern
        
        if(tag == 0)
        {
            seq1Colors.randomizeColors()
        }
        else
        {
            seq2Colors.randomizeColors()
        }
        
        self.setFPImages()
        
        tempModeCopy.updateName()
        
        modeWasEdited()
        
        EmazingSettings.settings.save()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            EmazingCommManager.commManager.syncManager.previewSequence(self.tempModeCopy.sequences[self.currentSequencePage])
        })
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth:CGFloat = scrollView.frame.size.width
        let fractionalPage:Double = Double(scrollView.contentOffset.x / pageWidth)
        let page:NSInteger = lround(fractionalPage)
        if (currentSequencePage != page) {
            // Page has changed, do your thing!
            print(page)

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.previewSequence(self.tempModeCopy.sequences[page])
            })
            
            // Finally, update previous page
            currentSequencePage = page
        }
        
    }
    
    func toggleSequencePage(sender: UIButton) {
        var nextPage = 0
        if(currentSequencePage == 0)
        {
            nextPage = 1
        }
        else
        {
            nextPage = 0
        }
        self.scrollToPage(scrollView, page: nextPage, animated: true)
        
        if(EmazingSettings.settings.photoHubs.count > 0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                EmazingCommManager.commManager.syncManager.previewSequence(self.tempModeCopy.sequences[self.currentSequencePage])
            })
        }
    }
    
    func scrollToPage(scrollView: UIScrollView, page: Int, animated: Bool) {
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.scrollRectToVisible(frame, animated: animated)
        currentSequencePage = page
    }
    
    func patternSelectPressed(sender: UIButton) {
        let controller:FlashingPatternSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("flashingPatternSelectionView") as! FlashingPatternSelectionViewController

        //TODO: Adjust for multiple sequences
        controller.sequence = tempModeCopy.sequences[sender.tag]
        controller.parentMode = tempModeCopy
        controller.pageMode = .Select
        controller.modeEditedDelegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Header editing code
    var infoPanelOpen:Bool = false
    @IBAction func moreButtonPressed(sender: AnyObject)
    {
        if(editingDescription && infoPanelOpen)
        {
            updateDescriptionEditing(false)
        }
        updateHeaderState(!infoPanelOpen)
    }
    
    private func updateHeaderState(open:Bool)
    {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.LayoutSubviews, animations: { () -> Void in
            
            var moreButtonFrame = self.moreButton.frame
            
            if(open)
            {
                self.headerHeightConstraint.constant += 110
                self.view.setNeedsLayout()
                moreButtonFrame.origin.y += 110
                self.moreButton.setTitle("Less", forState: UIControlState.Normal)
                
                if(self.customModeSelected)
                {
                    self.editButton.hidden = false
                    self.editButton.setTitle("Edit", forState: UIControlState.Normal)
                }
            }
            else
            {
                self.headerHeightConstraint.constant -= 110
                self.view.setNeedsLayout()
                moreButtonFrame.origin.y -= 110
                self.moreButton.setTitle("More", forState: UIControlState.Normal)
                self.editButton.hidden = true
            }
            
            self.moreButton.frame = moreButtonFrame
            
        }) { (completed) -> Void in
            
            self.setTextExclusionPath()
        }
        
        //print("HeaderView Frame: \(headerView.frame)")
        
        infoPanelOpen = open
    }
    
    var editingDescription:Bool = false
    @IBAction func editButtonPressed()
    {
        updateDescriptionEditing(!editingDescription)
    }
    
    func updateDescriptionEditing(shouldEdit:Bool)
    {
        if(shouldEdit)
        {
            descriptionTextView.editable = true
            descriptionTextView.selectable = true
            descriptionTextView.backgroundColor = UIColor.whiteColor()
            descriptionTextView.textColor = UIColor.blackColor()
            descriptionTextView.layer.borderWidth = 2.0
            editButton.setTitle("Done", forState: UIControlState.Normal)
            titleEditField.text = titleLabel.text
            titleEditField.hidden = false
            titleLabel.hidden = true
        }
        else
        {
            descriptionTextView.editable = false
            descriptionTextView.selectable = false
            descriptionTextView.backgroundColor = UIColor.clearColor()
            descriptionTextView.textColor = UIColor.whiteColor()
            descriptionTextView.layer.borderWidth = 0.0
            editButton.setTitle("Edit", forState: UIControlState.Normal)
            titleLabel.text = titleEditField.text
            titleEditField.hidden = true
            titleLabel.hidden = false
            
            //TODO: Check for duplicates
            if let newName = titleEditField.text
            {
                tempModeCopy.name = newName
                EmazingSettings.settings.save()
            }
        }
        editingDescription = shouldEdit
    }
    
    func setTextExclusionPath()
    {
        //Set the exclusion path to ensure description text and More/Less button don't overlap
        let moreRect:CGRect = self.descriptionTextView.convertRect(self.moreButton.bounds, fromView: self.moreButton)
        let moreRectPath = UIBezierPath(rect: moreRect)
        self.descriptionTextView.textContainer.exclusionPaths = [moreRectPath]
    }
    
    @IBAction func imageButtonPressed(sender: AnyObject)
    {
        print("Image button pressed")
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

//Helper function for embedding child view controllers programmatically from:
//http://stackoverflow.com/questions/18928732/is-it-possible-to-have-embed-segue-containing-view-in-a-scrollview-with-code

struct MyChildViewController {
    static func embed(
        viewControllerId: String,
        storyboardName: String,
        containerViewController: UIViewController,
        containerView: UIView) -> UIViewController? {
            
            guard let viewController = initViewController(viewControllerId, storyboardName: storyboardName)
                else { return nil }
            
            containerViewController.addChildViewController(viewController)
            containerView.addSubview(viewController.view)
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            MyConstraints.fillParent(
                viewController.view, parentView: containerView, margin: 0, vertically: true)
            
            MyConstraints.fillParent(
                viewController.view, parentView: containerView, margin: 0, vertically: false)
            
            viewController.didMoveToParentViewController(containerViewController)
            
            return viewController
    }
    
    static func initViewController(viewControllerId: String, storyboardName: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle.mainBundle())
        return storyboard.instantiateViewControllerWithIdentifier(viewControllerId)
    }
}

struct MyConstraints {
    static func fillParent(view: UIView, parentView: UIView, margin: CGFloat = 0,
        vertically: Bool) -> [NSLayoutConstraint] {
            
            var marginFormat = ""
            
            if margin != 0 {
                marginFormat = "-\(margin)-"
            }
            
            var format = "|\(marginFormat)[view]\(marginFormat)|"
            
            if vertically {
                format = "V:" + format
            }
            
            let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format,
                options: [], metrics: nil,
                views: ["view": view])
            
            parentView.addConstraints(constraints)
            
            return constraints
    }
}
