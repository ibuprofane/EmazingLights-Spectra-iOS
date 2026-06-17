//
//  TagSelectViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/2/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class TagSelectViewController: UIViewController {

    @IBOutlet var tagCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return EmazingSettings.settings.stockGloveSets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell:GloveSetCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("tagCell", forIndexPath: indexPath) as! GloveSetCollectionViewCell
        
        let gloveSet = EmazingSettings.settings.stockGloveSets[indexPath.row]
        cell.gloveSet = gloveSet
        
        let gloveSetImage:UIImageView = cell.viewWithTag(100) as! UIImageView
        gloveSetImage.image = UIImage(named: gloveSet.imageName)
        
        let name:UILabel = cell.viewWithTag(101) as! UILabel
        name.text = gloveSet.name
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let controller:GloveSetConfigViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gloveSetConfigView") as! GloveSetConfigViewController
        controller.gloveSet = EmazingSettings.settings.stockGloveSets[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
        //self.performSegueWithIdentifier("gloveSetConfigSegue", sender: nil)
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
