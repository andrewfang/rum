//
//  DataViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!{
        didSet {
            self.pieChartView.descriptionText = ""
            self.pieChartView.holeRadiusPercent = 0.3
            
            var dataEntries: [ChartDataEntry] = []
            let dataPoints = [5.0, 10.0, 10.0, 1.0]
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(value: dataPoints[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            
            let titles = ["Jare", "Sarah", "Jorge", "Andrew"]
            let colors = [UIColor.appBlue(), UIColor.appTeal(), UIColor.appRed(), UIColor.appOrange()]
            let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
            chartDataSet.colors = colors
            pieChartView.data = PieChartData(xVals: titles, dataSet: chartDataSet)
            
        }
    }

}
