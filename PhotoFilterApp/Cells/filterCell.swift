//
//  filterCell.swift
//  PhotoFilterApp
//
//  Created by Tutku Bide on 24.01.2020.
//  Copyright © 2020 Tutku Bide. All rights reserved.
//

import UIKit

class filterCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterName: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        imageView.layer.cornerRadius = 20
        
    }

}
