//
//  InformationCollectionViewCell.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-27.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit

class InformationCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupViews()
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews(){
        let label = UILabel()
        label.text = "This is where battery information will be"
        label.backgroundColor = UIColor.blue
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":label]))

//        self.addSubview(graphChart)
//        //        self.clipsToBounds = true
//        //        self.layer.cornerRadius = 10
//        graphChart.layer.cornerRadius = 10
//        graphChart.clipsToBounds = true
//        //self.backgroundColor = UIColor.blue
//        graphChart.backgroundColor = UIColor.red
//        
//        graphChart.noDataText = "No data yo"
//        graphChart.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(graphChart)
//        
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphChart]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphChart]))
    }

}
