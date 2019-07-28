//
//  DetailViewController.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 6/16/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import UIKit
import Cosmos


class DetailViewController: UIViewController {
    
    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var review_tv: UITextView!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var lbl_vote: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var stars_vote: CosmosView!
    
    var movie : Movie?
    private var loader : Loader!
    private var bigView : UIView!
    private var prevFrame : CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader = Loader.init(view: self.view)
        loader.showLoading()
        
        title = movie?.getTitle()
        review_tv.text = movie?.getOverview()
        popularity.text = movie?.getPopularity()
        lbl_vote.text = String(movie!.getVoteAverage())
        stars_vote.rating = movie!.getVoteAverage()/2
        
        poster.sd_setImage(with: URL(string: movie!.getPosterUrl()), placeholderImage: UIImage(named: "clappeboard.png"))
        backdrop.sd_setImage(with: URL(string: movie!.getBackdropUrl()), placeholderImage: UIImage(named: "video-camera.png"))
        
        getMovieDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        review_tv.setContentOffset(.zero, animated: animated)
    }
    
    private func getMovieDetails() {
        let urlStr = "\(Definitions.urlBase)/movie/\(movie!.id)?\(Definitions.appKey)&\(Definitions.language)"
        let url = URL(string:urlStr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if (error != nil){
                print(error!)
            }
            else {
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                do{
                    //here dataResponse received from a network request
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String: Any]
                    
                    let jsonResult = jsonResponse?["genres"]
                    guard let jsonArray = jsonResult as? [[String: Any]] else {
                        return
                    }
                    self.movie!.setGenres(from: jsonArray)
                    
                    DispatchQueue.main.async {
                        self.genres.text = self.movie!.getGenresString()
                        self.loader.hideLoading()
                    }
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieReviewsVC = segue.destination as! MovieReviewsVC
        movieReviewsVC.movie = movie;
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        self.prevFrame = imageView.frame
        
        let newImageView = UIImageView(image: imageView.image)
        newImageView.backgroundColor = UIColor.clear
        newImageView.contentMode = .scaleAspectFit
        newImageView.frame = imageView.frame
        newImageView.isUserInteractionEnabled = true
        newImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitFullScreen)))
        newImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panFullScreen(_:))))
        newImageView.autoresizingMask = UIView.AutoresizingMask(rawValue:   UIView.AutoresizingMask.flexibleWidth.rawValue |
                                                                            UIView.AutoresizingMask.flexibleHeight.rawValue)
        
        self.bigView = UIView(frame: self.view.frame)
        self.bigView.alpha = 0
        self.bigView.backgroundColor = UIColor.clear
        self.bigView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        
        let blackView = UIView(frame: self.view.frame)
        blackView.backgroundColor = UIColor.black
        blackView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        self.bigView.addSubview(blackView)
        self.bigView.addSubview(newImageView)
        
        self.view?.addSubview(self.bigView)
        
        UIView.animate(withDuration: 0.5, animations: {
            newImageView.frame = self.bigView.frame
            self.bigView.alpha = 1
        }) { (_) in
        }
        
    }
    
    
    //MARK: Actions of Gestures
    @objc func exitFullScreen () {
        
        let intDuration = 0.5
        let blackView = self.bigView.subviews[0]
        let imageV = self.bigView.subviews[1] as! UIImageView
        
        UIView.animate(withDuration: intDuration, animations: {
            let posterPosition = self.view.convert(self.prevFrame, to: nil)
            let imagePosition = imageV.convert(posterPosition, from: nil)
            imageV.frame = imagePosition
            blackView.alpha = 0
        }, completion: { (bol) in
            self.bigView.removeFromSuperview()
        })
    }
    
    @objc func panFullScreen(_ recognizer : UIPanGestureRecognizer) {
        let blackView = self.bigView.subviews[0]
        let imageV = self.bigView.subviews[1] as! UIImageView
        let center = self.view.frame.size.height / 2
        
        let translation = recognizer.translation(in: imageV)
        
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: imageV)
        
        let diff = abs(center - recognizer.view!.center.y) / center
        blackView.alpha = abs(diff - 1)
        
        
        if recognizer.state == UIGestureRecognizer.State.ended {
            NSLog("pan gesture ended")
            UIView.animate(withDuration: 0.3) {
                recognizer.view?.center.y = center
            }
            if diff > 0.1 {
                self.exitFullScreen()
            }
        }
    }
}
