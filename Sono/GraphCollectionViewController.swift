//
//  GraphCollectionViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-26.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import Charts
private let grapCellIdentifier = "GraphCell"
private let informationCellIdentifier = "InformationCell"

class GraphCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    let noGraphDataMessages = ["No EA data", "No blood volume data", "No heart rate data", "No temperature data","No inter beat interval data"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.backgroundColor = UIColor.white
        self.collectionView!.register(GraphCollectionViewCell.self, forCellWithReuseIdentifier: grapCellIdentifier)
        self.collectionView!.register(InformationCollectionViewCell.self, forCellWithReuseIdentifier: informationCellIdentifier)
        navigationItem.title = "Graphs"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        // Do any additional setup after loading the view.
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//    // MARK: UICollectionViewDataSource
//
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

//
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 6
    }
    
//
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < 5{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: grapCellIdentifier, for: indexPath) as! GraphCollectionViewCell
            let currentGraph = cell.graphChart
            currentGraph.noDataText = noGraphDataMessages[indexPath.row]
//            currentGraph.noDataText = "MEOW !!!"
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: informationCellIdentifier, for: indexPath)
            return cell
        }
        // Configure the cell
    }
//
//    // MARK: UICollectionViewDelegate
//
//    /*
//    // Uncomment this method to specify if the specified item should be highlighted during tracking
//    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    */
//
//    /*
//    // Uncomment this method to specify if the specified item should be selected
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    */
//
//    /*
//    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//    
//    }
//    */
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < 4{
            return CGSize(width: self.view.frame.width, height: 250)
        }else {
            return CGSize(width: self.view.frame.width, height: 100)
        }
    }

}
