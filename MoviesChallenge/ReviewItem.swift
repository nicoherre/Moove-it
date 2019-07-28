//
//  ReviewItem.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 7/13/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import Foundation
import UIKit

class ReviewItem: NSObject {
    private var author : String = ""
    private var content : String = ""
    private var url : String = ""
    private var id : String = ""
    private var movie : Movie?
    
    init(with review : [String: Any]) {
        id = review["id"] as! String
        url = review["url"] as! String
        content = review["content"] as! String
        author = review["author"] as! String
    }
    
    func getContent() -> String {
        return content
    }
    
    func getAuthor() -> String {
        return author
    }
}
