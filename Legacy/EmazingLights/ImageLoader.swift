//
//  ImageLoader.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/1/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation
import Parse

struct EmazingImageLoader {
    static var imageLoader:ImageLoader = ImageLoader()
}

protocol ImagesUpdatedDelegate
{
    func updateBannerImages()
    func updateHomePageImages()
}

class ImageLoader
{
    var bannerImagesUpdatedFromWeb:Bool = false //Do once
    var homeImagesUpdatedFromWeb:Bool = false //Do once
    
    var imageUpdateDelegate:ImagesUpdatedDelegate?
    
    func getBannerImages()->[ImageLinkCell]
    {
        if(!bannerImagesUpdatedFromWeb)
        {
            bannerImagesUpdatedFromWeb = true
            
            //Download the new image set in a background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() in
                let query = PFQuery(className: "Bannerv3")
                query.orderByAscending("createdAt")
                query.findObjectsInBackgroundWithBlock { ( objects:[PFObject]?, error) -> Void in
                    if(error == nil && objects != nil)
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() in
                            var newBanners:[ImageLinkCell] = []
                            
                            for object in objects!
                            {
                                //TODO: Change this to universal eventually
                                let file:PFFile = object.objectForKey("image") as! PFFile
                                if(!file.isKindOfClass(NSNull))
                                {
                                    let link = object.objectForKey("url") as! String
                                    let name = object.objectForKey("name") as! String
                                    let index = (object.objectForKey("index") as! Int)
                                    
                                    if let url  = NSURL(string: file.url!)
                                    {
                                        if let data = NSData(contentsOfURL: url)
                                        {
                                            newBanners.append(ImageLinkCell(name: name, image: UIImage(data: data)!, link: link, sortOrder: index))
                                        }
                                    }
                                }
                            }
                            
                            if(newBanners.count > 0)
                            {
                                print("Updated banners")
                                EmazingSettings.settings.bannerImageCache = newBanners
                                EmazingSettings.settings.save()
                                dispatch_async(dispatch_get_main_queue())
                                {
                                    self.imageUpdateDelegate?.updateBannerImages()
                                }
                            }
                        })
                    }
                    else
                    {
                        print(error)
                    }
                }
            })
        }

        let cacheCount = EmazingSettings.settings.bannerImageCache.count
        if(cacheCount == 0)
        {
            //TODO: Define default links/images
            var defaultBanners:[ImageLinkCell] = []
            defaultBanners.append(ImageLinkCell(name: "Welcome", image: UIImage(named: "welcome_banner")!, link: ""))
            defaultBanners.append(ImageLinkCell(name: "EmazingLights.com", image: UIImage(named: "shop_banner")!, link: "http://www.emazinglights.com"))
            defaultBanners.append(ImageLinkCell(name: "EmazingLights Videos", image: UIImage(named: "video_banner")!, link: "http://www.emazinglights.com/video-top-emazinglights"))
            EmazingSettings.settings.bannerImageCache = defaultBanners
        }

        print("returned banner images")
        return EmazingSettings.settings.bannerImageCache
    }
    
    func getHomePageImages()->[ImageLinkCell]
    {
        if(!homeImagesUpdatedFromWeb)
        {
            homeImagesUpdatedFromWeb = true
            
            //Download the new image set in a background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() in
                let query = PFQuery(className: "Buttonsv3")
                query.orderByAscending("createdAt")
                query.findObjectsInBackgroundWithBlock { ( objects:[PFObject]?, error) -> Void in
                    if(error == nil && objects != nil)
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() in
                            var newHomeImages:[ImageLinkCell] = []
                            
                            for object in objects!
                            {
                                //TODO: Change this to universal eventually
                                let file:PFFile = object.objectForKey("image") as! PFFile
                                if(!file.isKindOfClass(NSNull))
                                {
                                    let link = object.objectForKey("url") as! String
                                    let name = object.objectForKey("name") as! String
                                    let index = (object.objectForKey("index") as! Int)
                                    
                                    if let url  = NSURL(string: file.url!)
                                    {
                                        if let data = NSData(contentsOfURL: url)
                                        {
                                            newHomeImages.append(ImageLinkCell(name: name, image: UIImage(data: data)!, link: link, sortOrder: index))
                                        }
                                    }
                                }
                            }
                            
                            if(newHomeImages.count > 0)
                            {
                                print("Updated home images")
                                EmazingSettings.settings.homePageImageCache = newHomeImages
                                EmazingSettings.settings.save()
                                dispatch_async(dispatch_get_main_queue())
                                {
                                    self.imageUpdateDelegate?.updateHomePageImages()
                                }
                            }
                        })
                    }
                    else
                    {
                        print(error)
                    }
                }
            })
        }
        
        let cacheCount = EmazingSettings.settings.homePageImageCache.count
        if(cacheCount == 0)
        {
            //TODO: Define default links/images
            var defaultHomeImages:[ImageLinkCell] = []
            defaultHomeImages.append(ImageLinkCell(name: "My Gloves", image: UIImage(named: "mygloves")!, link: "Gloves", sortOrder: 0))
            defaultHomeImages.append(ImageLinkCell(name: "Settings", image: UIImage(named: "SetupButton")!, link: "Settings", sortOrder: 1))
            defaultHomeImages.append(ImageLinkCell(name: "EmazingLights Blog", image: UIImage(named: "blog")!, link: "http://blog.emazinglights.com", sortOrder: 2))
            defaultHomeImages.append(ImageLinkCell(name: "Video Tutorials", image: UIImage(named: "learn")!, link: "http://www.emazinglights.com/video-tutorials", sortOrder: 3))
            defaultHomeImages.append(ImageLinkCell(name: "EmazingLights Videos", image: UIImage(named: "videos")!, link: "http://www.emazinglights.com/video-top-emazinglights", sortOrder: 4))
            defaultHomeImages.append(ImageLinkCell(name: "Glove4Glove", image: UIImage(named: "g4g")!, link: "http://www.emazinglights.com/glove4glove", sortOrder: 5))
            defaultHomeImages.append(ImageLinkCell(name: "Social Media", image: UIImage(named: "social")!, link: "Social", sortOrder: 6))
            defaultHomeImages.append(ImageLinkCell(name: "Shop EmazingLights.com", image: UIImage(named: "store")!, link: "http://www.emazinglights.com", sortOrder: 7))
            EmazingSettings.settings.homePageImageCache = defaultHomeImages
        }
        
        print("returned home page images")
        return EmazingSettings.settings.homePageImageCache
    }
}