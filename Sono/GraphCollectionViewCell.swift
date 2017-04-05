//
//  GraphCollectionViewCell.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-27.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import Charts
class GraphCollectionViewCell: UICollectionViewCell {
    var graphChart = LineChartView()
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupViews()
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews(){
        self.addSubview(graphChart)

        graphChart.layer.cornerRadius = 10
        graphChart.clipsToBounds = true
        
        graphChart.layer.borderWidth = 1
        graphChart.layer.borderColor = UIColor.white.cgColor
        
        
        graphChart.noDataText = "No data yo"
        graphChart.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(graphChart)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphChart]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphChart]))
    }
}
