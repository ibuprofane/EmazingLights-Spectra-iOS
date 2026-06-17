//
//  ImageLinkCell.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/1/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation

class ImageLinkCell: NSObject
{
    var image:UIImage!
    var link:String!
    var sortOrder:Int!
    var name:String!
    
    init(name:String, image:UIImage, link:String, sortOrder:Int = -1)
    {
        self.name = name
        self.image = image
        self.link = link
        self.sortOrder = sortOrder
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.image, forKey: "image")
        aCoder.encodeObject(self.link, forKey: "link")
        aCoder.encodeObject(self.sortOrder, forKey: "sortOrder")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("name"))
        {
            self.name = aDecoder.decodeObjectForKey("name") as! String
        }
        if(aDecoder.containsValueForKey("image"))
        {
            self.image = aDecoder.decodeObjectForKey("image") as! UIImage
        }
        if(aDecoder.containsValueForKey("link"))
        {
            self.link = aDecoder.decodeObjectForKey("link") as! String
        }
        if(aDecoder.containsValueForKey("sortOrder"))
        {
            self.sortOrder = aDecoder.decodeObjectForKey("sortOrder") as! Int
        }
    }
}