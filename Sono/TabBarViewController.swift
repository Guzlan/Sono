//
//  TabBarViewController.swift
//  Sono
//
//  Created by zeyad saleh on 2017-04-03.
//  Copyright © 2017 Amro Gazlan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let aboutView = AboutViewController()
        aboutView.tabBarItem.title = "About"
        aboutView.tabBarItem.setFAIcon(icon: .FAFolderO)
        self.viewControllers?.append(aboutView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}