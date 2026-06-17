//
//  HomeViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/30/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, KDCycleBannerViewDataSource, KDCycleBannerViewDelegate, ImagesUpdatedDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var cycleBanner: KDCycleBannerView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var hamburgerMenuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EmazingImageLoader.imageLoader.imageUpdateDelegate = self
        EmazingImageLoader.imageLoader.getHomePageImages()
        
        setupNavigationBar()
        setupBannerView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar()
    {
        //Setup logo
        let logo = UIImage(named: "logo")
        let logoView = UIImageView(image: logo)
        logoView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = logoView
        
        self.navigationItem.leftItemsSupplementBackButton = true
        
        //self.navigationItem.leftBarButtonItem = hamburgerMenuButton
    }
    
    func setupBannerView()
    {
        cycleBanner.autoPlayTimeInterval = 5
        cycleBanner.continuous = true
    }
    
    func updateBannerImages() {
        self.cycleBanner.reloadDataWithCompleteBlock(nil)
    }
    
    func updateHomePageImages() {
        self.tableView.reloadData()
    }

    @IBAction func shopButtonPressed(sender: AnyObject)
    {
        segueToWebView("http://www.emazinglights.com", name: "Shop EmazingLights.com")
    }

    //MARK: - UITableView Functions
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("homeImageCell", forIndexPath: indexPath)
        
        let imageView:UIImageView = cell.viewWithTag(101) as! UIImageView
        
        for imageLinkPair in EmazingSettings.settings.homePageImageCache
        {
            if(imageLinkPair.sortOrder == indexPath.row)
            {
                imageView.image = imageLinkPair.image
            }
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        for imageLinkPair in EmazingSettings.settings.homePageImageCache
        {
            if(imageLinkPair.sortOrder == indexPath.row)
            {
                if(imageLinkPair.link == "Gloves")
                {
                    //Do this to get to ProtoGloves
                    /*let controller:GloveSetSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveSetSelectionView") as! GloveSetSelectionViewController
                    controller.menuButton = self.hamburgerMenuButton
                    controller.deviceType = "ProtoGloves"
                    */
                    
                    if(EmazingSettings.settings.photoHubs.count > 0)
                    {
                        //Do this to get to PhotoChips
                        let controller:ChipMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("chipMenuViewController") as! ChipMenuViewController
                        controller.deviceType = "PhotoChips"
                        controller.menuButton = self.hamburgerMenuButton

                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    else
                    {
                        let alert = UIAlertController(title: "No Hub Configured", message: "Would you like to configure one in Settings?", preferredStyle: .Alert) // 1
                        let firstAction = UIAlertAction(title: "Yes", style: .Default) { (alert: UIAlertAction!) -> Void in
                            let controller:SettingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("settingsView") as! SettingsViewController
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        
                        let secondAction = UIAlertAction(title: "No", style: .Default) { (alert: UIAlertAction!) -> Void in
                            //Do this to get to PhotoChips
                            let controller:ChipMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("chipMenuViewController") as! ChipMenuViewController
                            controller.deviceType = "PhotoChips"
                            controller.menuButton = self.hamburgerMenuButton
                            
                            /*let controller:GloveSetSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveSetSelectionView") as! GloveSetSelectionViewController
                            controller.menuButton = self.hamburgerMenuButton
                            controller.deviceType = "PhotoChips"*/
                            
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        
                        alert.addAction(firstAction) // 4
                        alert.addAction(secondAction) // 5
                        presentViewController(alert, animated: true, completion:nil) // 6
                    }
                }
                else if(imageLinkPair.link == "Settings")
                {
                    let controller:SettingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("settingsView") as! SettingsViewController
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                else if(imageLinkPair.link == "Social")
                {
                    //Go to social media tab
                    let controller:SocialMediaViewController = self.storyboard?.instantiateViewControllerWithIdentifier("socialMediaViewController") as! SocialMediaViewController
                    self.navigationController?.pushViewController(controller, animated: true)
                    print("Segue to Social Media")
                }
                else
                {
                    //Go to web view with specified URL
                    print("Segue to \(imageLinkPair.link)")
                    segueToWebView(imageLinkPair.link, name: imageLinkPair.name)
                }
            }
        }
    }
    
    func segueToWebView(page:String, name:String)
    {
        let controller:WebViewController = self.storyboard?.instantiateViewControllerWithIdentifier("webView") as! WebViewController
        controller.page = page
        controller.title = name
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return EmazingSettings.settings.homePageImageCache.count
    }
    
    @IBOutlet var testImage: UIImageView!
    //MARK: - KDCycleBanner Functions
    func numberOfKDCycleBannerView(bannerView: KDCycleBannerView!) -> [AnyObject]! {
        
        let imageLinkPairs = EmazingImageLoader.imageLoader.getBannerImages()
        
        var justImages = [UIImage]()
        for imageLinkPair in imageLinkPairs
        {
            justImages.append(imageLinkPair.image)
        }
        return justImages
    }
    
    func contentModeForImageIndex(index: UInt) -> UIViewContentMode {
        return UIViewContentMode.ScaleAspectFit
    }
    
    /*func placeHolderImageOfZeroBannerView() -> UIImage!
    {
        return UIImage(named: "banner1")
    }*/
    
    func cycleBannerView(bannerView: KDCycleBannerView!, didScrollToIndex index: UInt) {
        //Nothing at the moment
    }
    
    func cycleBannerView(bannerView: KDCycleBannerView!, didSelectedAtIndex index: UInt) {

        let i = Int(index)
        if(i < EmazingSettings.settings.bannerImageCache.count)
        {
            let bannerItem = EmazingSettings.settings.bannerImageCache[i]
            let url = bannerItem.link
            let name = bannerItem.name
            if(url.containsString("http://"))
            {
                segueToWebView(url, name: name)
            }
        }
    }
    
    
}
