//
//  ViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-01.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BWWalkthroughViewControllerDelegate {
    var needWalkthrough:Bool = true
    var walkthrough:BWWalkthroughViewController!
    let stb = UIStoryboard(name: "Main", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func startWalkThrough(_ sender: UIButton) {
        initializePages()
    }
    func initializePages (){
        walkthrough = stb.instantiateViewController(withIdentifier: "mainContainer") as! BWWalkthroughViewController
        let intro = stb.instantiateViewController(withIdentifier: "intro")
        let step1 = stb.instantiateViewController(withIdentifier: "step1")
        let step2 = stb.instantiateViewController(withIdentifier: "step2")
        let step3 = stb.instantiateViewController(withIdentifier: "step3")
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(intro)
        walkthrough.addViewController(step1)
        walkthrough.addViewController(step2)
        walkthrough.addViewController(step3)
        self.present(walkthrough, animated: true, completion: nil)
        
    }
}

