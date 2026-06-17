//
//  WebViewController.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/2/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var page:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        if(page != nil)
        {
            let url = NSURL(string: page)!
            webView.loadRequest(NSURLRequest(URL: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
