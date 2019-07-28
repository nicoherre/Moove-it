//
//  ReviewCell.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 7/13/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import Foundation
import UIKit

class ReviewCell: UITableViewCell {
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var imageMovie: UIImageView!
    @IBOutlet weak var content: UILabel!
  
    func tapped(isOpen: Bool) {
        print("is Open: \(isOpen)")
        if !isOpen {
            content.numberOfLines = 0
        }
        else {
            content.numberOfLines = 2
        }
    }
}
