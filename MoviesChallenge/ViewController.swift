//
//  ViewController.swift
//  MoviesChallenge
//
//  Created by Nicolas Herrera on 7/27/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var gridView: UICollectionView!
    
    var movies: Array<Movie> = []
    private var loader : Loader!
    private var loadingData: Bool = false
    private var totalPages: Int = 1
    private var actualPage: Int = 1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loader = Loader.init(view: self.view)
        movieDiscover()
    }
    
    func movieDiscover() {
        loader.showLoading()
        if !loadingData && actualPage <= totalPages{
            loadingData = true
            
            let url = URL(string: "\(Definitions.urlBase)/discover/movie?\(Definitions.appKey)&\(Definitions.language)&sort_by=popularity.desc&include_video=false&page=\(actualPage)")
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                self.loadingData = false
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
                        
                        self.totalPages = jsonResponse?["total_pages"] as! Int
                        self.actualPage += 1
                        
                        let jsonResult = jsonResponse?["results"]
                        guard let jsonArray = jsonResult as? [[String: Any]] else {
                            return
                        }
                        for dic in jsonArray{
                            let movie = Movie.init(movieDic: dic)
                            self.movies.append(movie)
                        }
                        DispatchQueue.main.async {
                            self.gridView.reloadData()
                            self.loader.hideLoading()
                        }
                        
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: Collection view protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieReusableView", for: indexPath) as! MovieViewCell
        let movie = movies[indexPath.row]
        cell.image.sd_setImage(with: URL(string: movie.getPosterUrl()), placeholderImage: UIImage(named: "clapperboard.png"))
        
        cell.name_lbl.text = movie.getTitle()
        cell.year_lbl.text = movie.getYear()
        cell.setRating(movie.getVoteAverage())
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = movies.count - 1
        if !loadingData && indexPath.row == lastElement {
            movieDiscover()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movie = sender as? MovieViewCell
        let indexPath = gridView.indexPath(for: movie!)
        let detailVC = segue.destination as! DetailViewController
        detailVC.movie = self.movies[(indexPath?.row)!]
    }
}



