//
//  GloveSetSelectionViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/23/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class GloveSetSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {//, UICollectionViewController, UISearchBarDelegate{

    @IBOutlet var gloveSetCollection: UICollectionView!
    var menuButton:UIBarButtonItem!
    var deviceType:String = "" //PhotoChips, ProtoGloves, BLEChips
    var editingMode:Bool = false
    
    /*var filteredChips = [Chip]()
    var searchBarActive:Bool = false
    var searchBarBoundsY:CGFloat?
    var searchBar:UISearchBar?
    var refreshControl:UIRefreshControl?*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named:"backarrow") as UIImage!
        let btnBack:UIButton = UIButton(type: UIButtonType.Custom)
        btnBack.addTarget(self, action: #selector(GloveSetSelectionViewController.BtnTapBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnBack.setImage(image, forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItems  = [menuButton, myCustomBackButtonItem]
        
        if(deviceType == "PhotoChips")
        {
            self.navigationItem.title = "Photo Hubs"
        }
        else
        {
            self.navigationItem.title = "Glove Sets"
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy Set", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GloveSetSelectionViewController.saveAs))
    }
    
    func saveAs()
    {
        let alertController = UIAlertController(title: "Create New Chip Set", message: "Please select a base chip.", preferredStyle: .Alert)
        
        let base1 = UIAlertAction(title: "Element", style: .Default) { (_) in
            self.createChipSet("Element")
        }
        let base2 = UIAlertAction(title: "Chroma 24", style: .Default) { (_) in
            self.createChipSet("Chroma 24")
        }
        let base3 = UIAlertAction(title: "ChromaCTRL", style: .Default) { (_) in
            self.createChipSet("ChromaCTRL")
        }
        let base4 = UIAlertAction(title: "Flow", style: .Default) { (_) in
            self.createChipSet("Flow")
        }
        let base5 = UIAlertAction(title: "EZLite 2.0", style: .Default) { (_) in
            self.createChipSet("EZLite 2.0")
        }
        let base6 = UIAlertAction(title: "eNOVA", style: .Default) { (_) in
            self.createChipSet("eNOVA")
        }
        let baseDefault = UIAlertAction(title: "RGB Strobe", style: .Default) { (_) in
            self.createChipSet("RGB Strobe")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            print("Cancel")
        }
        
        alertController.addAction(base1)
        alertController.addAction(base2)
        alertController.addAction(base3)
        alertController.addAction(base4)
        alertController.addAction(base5)
        alertController.addAction(base6)
        alertController.addAction(baseDefault)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func createChipSet(type:String)
    {
        var chipToCopy:Chip!
        for chip in EmazingSettings.settings.stockChips
        {
            if(chip.name == type)
            {
                chipToCopy = chip
                break
            }
        }
        
        let alertController = UIAlertController(title: "Create New Chip Set", message: "Create and save a new chip set with the current settings.", preferredStyle: .Alert)
         
         alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.addTarget(self, action: #selector(GloveSetSelectionViewController.textChanged(_:)), forControlEvents: .EditingChanged)
            textField.placeholder = "Chip Set Name"
            textField.keyboardType = .Default
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
         }
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print(action)
         }
        
         alertController.addAction(cancelAction)
        
         let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
            let nameTextField = alertController.textFields![0] as UITextField
            self.doSaveAs(nameTextField.text!, chipToCopy: chipToCopy)
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
    
    func doSaveAs(name:String, chipToCopy:Chip)
    {
        //Check for duplicates
        var duplicateFound:Bool = false
        for chip in EmazingSettings.settings.customChips
        {
            if(chip.name == name)
            {
                duplicateFound = true
            }
        }
        
        if(!duplicateFound)
        {
            let chipCopy = chipToCopy.copyObject()
            chipCopy.name = name
            
            let generator = SabilandTB(width: 100.0, height: 100.0)
            let trippyImage = generator.SabilandTrippyBackground
            chipCopy.image = trippyImage
            
            EmazingSettings.settings.customChips.append(chipCopy)
            EmazingSettings.settings.save()
            
            let indexPath = NSIndexPath(forRow: EmazingSettings.settings.customChips.count - 1, inSection: 1)
            self.gloveSetCollection.reloadData()
            self.gloveSetCollection.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
        else
        {
            //Present notice to user
            let alertController = UIAlertController(title: "Duplicate Name", message: "A chip set with this name already exists. Please choose a unique name.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: Search Bar Stuff
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareUI()
    }
    
    deinit{
        self.removeObservers()
    }
    
    func refreashControlAction(){
        self.cancelSearching()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // stop refreshing after 2 seconds
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: Search
    func filterContentForSearchText(searchText:String){
        let filteredArray = EmazingSettings.settings.stockChips.filter() {
            let type = ($0 as Chip).name as String
            return type.rangeOfString(searchText) != nil
        }
        self.filteredChips = filteredArray
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0 {
            // search and reload data source
            self.searchBarActive    = true
            self.filterContentForSearchText(searchText)
            self.collectionView?.reloadData()
        }else{
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self .cancelSearching()
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        self.searchBarActive = false
        self.searchBar!.setShowsCancelButton(false, animated: false)
    }
    func cancelSearching(){
        self.searchBarActive = false
        self.searchBar!.resignFirstResponder()
        self.searchBar!.text = ""
    }
    
    // MARK: prepareVC
    func prepareUI(){
        self.addSearchBar()
        self.addRefreshControl()
    }
    
    func addSearchBar(){
        if self.searchBar == nil{
            self.searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height
            
            self.searchBar = UISearchBar(frame: CGRectMake(0,self.searchBarBoundsY!, UIScreen.mainScreen().bounds.size.width, 44))
            self.searchBar!.searchBarStyle       = UISearchBarStyle.Minimal
            self.searchBar!.tintColor            = UIColor.whiteColor()
            self.searchBar!.barTintColor         = UIColor.whiteColor()
            self.searchBar!.delegate             = self;
            self.searchBar!.placeholder          = "search here";
            
            self.addObservers()
        }
        
        if !self.searchBar!.isDescendantOfView(self.view){
            self.view .addSubview(self.searchBar!)
        }
    }
    
    func addRefreshControl(){
        if (self.refreshControl == nil) {
            self.refreshControl            = UIRefreshControl()
            self.refreshControl?.tintColor = UIColor.whiteColor()
            self.refreshControl?.addTarget(self, action: "refreashControlAction", forControlEvents: UIControlEvents.ValueChanged)
        }
        if !self.refreshControl!.isDescendantOfView(self.collectionView!) {
            self.collectionView!.addSubview(self.refreshControl!)
        }
    }
    
    func startRefreshControl(){
        if !self.refreshControl!.refreshing {
            self.refreshControl!.beginRefreshing()
        }
    }
    
    func addObservers(){
        let context = UnsafeMutablePointer<UInt8>(bitPattern: 1)
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.New,.Old], context: context)
    }
    
    func removeObservers(){
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValueForKeyPath(keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>){
            if keyPath! == "contentOffset" {
                if let collectionV:UICollectionView = object as? UICollectionView {
                    self.searchBar?.frame = CGRectMake(
                        self.searchBar!.frame.origin.x,
                        self.searchBarBoundsY! + ( (-1 * collectionV.contentOffset.y) - self.searchBarBoundsY!),
                        self.searchBar!.frame.size.width,
                        self.searchBar!.frame.size.height
                    )
                }
            }
    }
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.gloveSetCollection.reloadData()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            EmazingCommManager.commManager.syncManager.turnOffPreview()
            EmazingCommManager.commManager.forceSyncCancel = true
        })
    }

    @IBAction func BtnTapBack(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Collection View Delegates
    /*func collectionView( collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets{
            return UIEdgeInsetsMake(self.searchBar!.frame.size.height, 0, 0, 0);
    }*/
    
    /*func collectionView (collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
            let cellLeg = (collectionView.frame.size.width/3) - 5;
            return CGSizeMake(cellLeg,cellLeg);
    }*/
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(deviceType == "PhotoChips" && section == 0)
        {
            return EmazingSettings.settings.stockChips.count
        }
        else if(deviceType == "PhotoChips" && section == 1)
        {
            return EmazingSettings.settings.customChips.count
        }
        else if(deviceType == "ProtoGloves" && section == 0)
        {
            return EmazingSettings.settings.stockGloveSets.count
        }
        else
        {
            return EmazingSettings.settings.customGloveSets.count
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if(deviceType == "PhotoChips")
        {
            if(EmazingSettings.settings.customChips.count > 0)
            {
                return 2
            }
            else
            {
                return 1
            }
        }
        else
        {
            if(EmazingSettings.settings.customGloveSets.count > 0)
            {
                return 2
            }
            else
            {
                return 1
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell:GloveSetCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("gloveSetCell", forIndexPath: indexPath) as! GloveSetCollectionViewCell
        
        if(deviceType == "PhotoChips")
        {
            var chip:Chip!
            let deleteButton:DeleteChipSetButton = cell.viewWithTag(102) as! DeleteChipSetButton
            
            if(indexPath.section == 0)
            {
                chip = EmazingSettings.settings.stockChips[indexPath.row]
                deleteButton.hidden = true
            }
            else
            {
                chip = EmazingSettings.settings.customChips[indexPath.row]
                
                deleteButton.chipIndex = indexPath.row
                if(editingMode)
                {
                    deleteButton.hidden = false
                }
                else
                {
                    deleteButton.hidden = true
                }
            }
            
            cell.chip = chip
            let gloveSetImage:UIImageView = cell.viewWithTag(100) as! UIImageView
            gloveSetImage.image = chip.image
            
            let name:UILabel = cell.viewWithTag(101) as! UILabel
            name.text = chip.name
        }
        else
        {
            var gloveSet:GloveSet!
            if(indexPath.section == 0)
            {
                gloveSet = EmazingSettings.settings.stockGloveSets[indexPath.row]
            }
            else
            {
                gloveSet = EmazingSettings.settings.customGloveSets[indexPath.row]
            }
            
            cell.gloveSet = gloveSet
            
            let gloveSetImage:UIImageView = cell.viewWithTag(100) as! UIImageView
            gloveSetImage.image = UIImage(named: gloveSet.imageName)
            
            let name:UILabel = cell.viewWithTag(101) as! UILabel
            name.text = gloveSet.name
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(!editingMode)
        {
            if(deviceType == "PhotoChips")
            {
                let controller:ChipConfigViewController = self.storyboard?.instantiateViewControllerWithIdentifier("chipConfigView") as! ChipConfigViewController
                if(indexPath.section == 0)
                {
                    controller.chip = EmazingSettings.settings.stockChips[indexPath.row]
                }
                else
                {
                    controller.chip = EmazingSettings.settings.customChips[indexPath.row]
                }
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else if(deviceType == "ProtoGloves")
            {
                let controller:GloveSetConfigViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveSetConfigView") as! GloveSetConfigViewController
                if(indexPath.section == 0)
                {
                    controller.gloveSet = EmazingSettings.settings.stockGloveSets[indexPath.row]
                }
                else
                {
                    controller.gloveSet = EmazingSettings.settings.customGloveSets[indexPath.row]
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "setHeaderView", forIndexPath: indexPath)
        let headerLabel:UILabel = headerView.viewWithTag(100) as! UILabel
        let editButton:UIButton = headerView.viewWithTag(101) as! UIButton
        
        if(indexPath.section == 0)
        {
            headerLabel.text = "Emazing Favorites"
            editButton.hidden = true
        }
        else
        {
            headerLabel.text = "Custom Sets"
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
    
    func setEditingMode()
    {
        editingMode = true
        gloveSetCollection.reloadData()
    }
    
    func doneEditing()
    {
        editingMode = false
        gloveSetCollection.reloadData()
    }
    
    @IBAction func deletePressed(sender: AnyObject)
    {
        let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this chip set?", preferredStyle: .Alert) // 1
        let firstAction = UIAlertAction(title: "Yes", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            
            let deleteButton:DeleteChipSetButton = sender as! DeleteChipSetButton
            EmazingSettings.settings.customChips.removeAtIndex(deleteButton.chipIndex)
            EmazingSettings.settings.save()
            self.doneEditing()
            
            self.gloveSetCollection.reloadData()
        }
        
        let secondAction = UIAlertAction(title: "No", style: .Default) { (alert: UIAlertAction!) -> Void in
            print("Do nothing")
        }
        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        presentViewController(alert, animated: true, completion:nil) // 6
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if(segue.identifier == "gloveSetConfigSegue")
        {
            //stopOnlyZone2()
            let gloveSetConfigController = segue.destinationViewController as! GloveSetConfigViewController
            gloveSetConfigController.gloveSet = self.lastSelectedGloveSet
        }*/
    }
}

class GloveSetCollectionViewCell: UICollectionViewCell {
    var gloveSet:GloveSet!
    var chip:Chip!
}

class DeleteChipSetButton:UIButton
{
    var chipIndex:Int!
}

