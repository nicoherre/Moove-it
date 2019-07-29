//
//  Loader.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 7/21/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import Foundation
import UIKit

class Loader: NSObject{
    
    private var loader_container: UIView!
    private var loader: UIImageView!
    private var label: UILabel!
    
    init(view: UIView) {
        super.init()
        self.loader_container = UIView.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.loader_container.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.loader_container.layer.cornerRadius = 10
        self.loader_container.center = view.center
        
        self.loader = UIImageView(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
        self.loader.tintColor = UIColor.white
        self.loader_container.addSubview(self.loader!)
        self.loader_container.isHidden = true
        
        self.label = UILabel.init(frame: CGRect(x: 0, y: 60, width: 80, height: 20))
        self.label.textAlignment = NSTextAlignment.center
        self.label.textColor = UIColor.white
        self.label.font = self.label.font.withSize(14)
        self.loader_container.addSubview(label)
        
        view.addSubview(self.loader_container!)
    }
    
    func setText(text : String) {
        self.label.text = text
    }
    
    func changeCenter (to center: CGPoint){
        self.loader_container.center = center
    }
    
    func showLoading() {
        if self.loader_container.isHidden {
            self.loader_container.alpha = 0
            self.loader_container.isHidden = false
            animateLoader()
            self.loader_container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            
            UIView.animate(withDuration: 0.3) {
                self.loader_container.alpha = 1
                self.loader_container.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                UIView.animate(withDuration: 0.2, animations: {
                    self.loader_container.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }
        }
    }
    
    func animateLoader() {
        self.loader.image = UIImage(imageLiteralResourceName: "SPINNING-Zen").withRenderingMode(.alwaysTemplate)
        self.loader.isHidden = false
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = NSNumber(floatLiteral: 0)
        rotation.toValue = NSNumber(floatLiteral: 2 * .pi)
        rotation.duration = 1.0
        rotation.repeatCount = HUGE
        self.loader.layer.add(rotation, forKey: "Spin")
    }
    
    func hideLoading() {
        self.loader.stopAnimating()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.loader_container.alpha = 0
            self.loader_container.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }) { (_) in
            self.loader_container.isHidden = true
        }
    }
    
}
