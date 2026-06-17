//
//  ChipSettingsViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 5/17/16.
//  Copyright © 2016 Emazing Group. All rights reserved.
//

import UIKit

class ChipSettingsViewController: UIViewController {

    var finger:Finger!
    @IBOutlet var paletteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paletteLabel?.text = finger?.defaultPalette?.name
    }
    
    override func viewDidAppear(animated: Bool) {
        paletteLabel?.text = finger?.defaultPalette?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeDefaultPalettePressed(sender: AnyObject)
    {
        let controller:ColorSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("colorSelectionView") as! ColorSelectionViewController
        
        controller.finger = finger
        controller.displayMode = .PaletteSelect

        self.navigationController?.pushViewController(controller, animated: true)
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
