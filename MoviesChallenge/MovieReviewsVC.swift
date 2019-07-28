//
//  MovieReviews.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 7/13/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import Foundation
import UIKit


class MovieReviewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movie: Movie?
    private var reviews: Array<ReviewItem> = Array()
    private var cellSelectedIndex : IndexPath?
    private var loader: Loader!
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var lbl_reviews: UILabel!
    @IBOutlet weak var lbl_not_review: UILabel!
    
    override func viewDidLoad() {
        self.loader = Loader.init(view: self.view)
        
        movieImage.sd_setImage(with: URL(string: movie!.getPosterUrl()), placeholderImage: UIImage(named: "video-camera.png"))
        
        // set the height of the dynamic rows to expand the rows when they are pressed
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        
        self.loader.showLoading()
        getMovieReviews()
    }
    
    func getMovieReviews(){
        let urlStr = "\(Definitions.urlBase)/movie/\(movie!.id)/reviews?\(Definitions.appKey)&\(Definitions.language)&page=1"
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
                    
                    let jsonResult = jsonResponse?["results"]
                    guard let jsonArray = jsonResult as? [[String: Any]] else {
                        return
                    }
                    for dic in jsonArray{
                        let review = ReviewItem.init(with: dic)
                        self.reviews.append(review)
                    }
                    
                    let totalReviews = jsonResponse?["total_results"] as! Int
                    DispatchQueue.main.async {
                        self.lbl_not_review.isHidden = totalReviews > 0
                        self.lbl_reviews.text = "Reviews (\(totalReviews))"
                        self.table.reloadData()
                        self.loader.hideLoading()
                    }
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
        }
        task.resume()
    }
    
    // MARK: TableView protocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewReusableView", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        cell.author.text = review.getAuthor()
        cell.content.text = review.getContent()
        cell.selectionStyle = .none
        
        cell.content.numberOfLines = self.cellSelectedIndex != indexPath ? 2 : 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewReusableView", for: indexPath) as! ReviewCell
        
        // check if the cell was already selected to deselected
        let oldCellSelected = self.cellSelectedIndex
        self.cellSelectedIndex = indexPath
        if oldCellSelected == self.cellSelectedIndex {
            self.cellSelectedIndex = nil
        }

        // expand or contract the cell
        tableView.beginUpdates()
        cell.content.numberOfLines = cell.content.numberOfLines == 0 ? 2 : 0
        tableView.endUpdates()
        
        // reload only rows that was modified
        let indexPaths = oldCellSelected != nil ? [indexPath, oldCellSelected] : [indexPath]
        tableView.reloadRows(at: indexPaths as! [IndexPath], with: .automatic)
        
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}
