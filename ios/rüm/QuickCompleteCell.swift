//
//  QuickCompleteCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class QuickCompleteCell: UITableViewCell, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    var collectionViewDelegate: UICollectionViewDelegate? {
        didSet {
            self.collectionView.delegate = collectionViewDelegate
        }
    }
    var tasks: [String] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        let quickCompleteCollectionViewCellNib = UINib(nibName: "QuickCompleteCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(quickCompleteCollectionViewCellNib, forCellWithReuseIdentifier: "quickCompleteCollectionViewCell")
        self.collectionView.dataSource = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("quickCompleteCollectionViewCell", forIndexPath: indexPath) as! QuickCompleteCollectionViewCell
        cell.loadTask(self.tasks[indexPath.item])
        return cell
    }
}
