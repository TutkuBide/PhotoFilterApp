//
//  filterModel.swift
//  PhotoFilterApp
//
//  Created by Tutku Bide on 24.01.2020.
//  Copyright © 2020 Tutku Bide. All rights reserved.
//

import Foundation
import UIKit

class FilterModel {
    var name: String
    var filter: String
    var image: UIImage

    init(name: String, filter: String, image: UIImage) {
        self.name = name
        self.filter = filter
        self.image = image
    }
}
