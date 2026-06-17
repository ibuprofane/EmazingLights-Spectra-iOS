//
//  TagImageCell.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/2/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation

class TagImageCell: NSObject
{
    var imageName:String!
    var tag:String!
    
    init(tag:String, imageName:String)
    {
        self.tag = tag
        self.imageName = imageName
    }
}