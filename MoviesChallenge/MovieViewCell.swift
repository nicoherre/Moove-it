//
//  MovieViewCell.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 6/15/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import UIKit
import Cosmos

class MovieViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var year_lbl: UILabel!
    @IBOutlet weak var name_lbl: UILabel!
    @IBOutlet weak var ratingStar: CosmosView!

    func setRating(_ rating: Double) {
        ratingStar.rating = rating/2
    }

    override public func prepareForReuse() {
        // Ensures the reused cosmos view is as good as new
        ratingStar.prepareForReuse()
    }
}
