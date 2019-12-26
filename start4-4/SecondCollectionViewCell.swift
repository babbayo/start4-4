//
//  SecondCollectionViewCell.swift
//  start4-4
//
//  Created by MacBook on 24/11/2019.
//  Copyright © 2019 yaco. All rights reserved.
//

import UIKit

class SecondCollectionViewCell: UICollectionViewCell {
     @IBOutlet var imageView: UIImageView!
     
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func selected() {
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.black.cgColor
        self.alpha = 0.5
    }
    
    func unselected() {
        self.layer.borderWidth = 0
        self.alpha = 1
    }
}
