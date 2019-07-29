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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var gridView: UICollectionView!
    @IBOutlet weak var emptyResults_lbl : UILabel!
    
    var movies: Array<Movie> = []
    private var loader : Loader!
    private var loadingData: Bool = false
    private var totalPages: Int = 1
    private var actualPage: Int = 1
    var task : URLSessionDataTask?
    
    var searchResults : Array<Movie> = []
    let searchController = UISearchController(searchResultsController: nil)
    var searchPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        loader = Loader.init(view: self.view)
        movieDiscover()
    }
    
    func movieDiscover() {
        if !loadingData && actualPage <= totalPages{
            loadingData = true
            let url = URL(string: "\(Definitions.urlBase)/discover/movie?\(Definitions.appKey)&\(Definitions.language)&sort_by=popularity.desc&include_video=false&page=\(actualPage)")
            requestURL(url)
        }
    }
    
    func searchMovie(query: String){
        let urlStr = "\(Definitions.urlBase)/search/movie?\(Definitions.appKey)&\(Definitions.language)&query=\(query)&page=\(searchPage)"
        
        let url = URL(string: urlStr)
        task?.cancel()
        loadingData = false
        requestURL(url)
    }
    
    func searchNextPage(){
        if !loadingData && searchPage <= totalPages{
            loadingData = true
            searchPage += 1
            if let searchText = searchController.searchBar.text, searchText.count > 0 {
                self.searchMovie(query: searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            }
        }
    }
    
    func requestURL(_ url: URL?){
        loader.showLoading()
        let filterResult = !searchBarIsEmpty()
        task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            self.loadingData = false
            if (error != nil){
                print(error!)
                self.emptyResults_lbl.isHidden = false
            }
            else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                do{
                    //here dataResponse received from a network request
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String: Any]
                    
                    self.totalPages = jsonResponse?["total_pages"] as! Int
                    if !filterResult {
                        self.actualPage += 1
                    }
                    
                    let jsonResult = jsonResponse?["results"]
                    guard let jsonArray = jsonResult as? [[String: Any]] else {
                        return
                    }
                    for dic in jsonArray{
                        let movie = Movie.init(movieDic: dic)
                        if filterResult {
                            self.searchResults.append(movie)
                        } else {
                            self.movies.append(movie)
                        }
                    }
                    DispatchQueue.main.async {
                        self.emptyResults_lbl.isHidden = jsonArray.count > 0
                        self.gridView.reloadData()
                        self.loader.hideLoading()
                    }
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
            else {
                self.emptyResults_lbl.isHidden = false
            }
        
        }
        task!.resume()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    // MARK: - UISearchResultsUpdating method
    func updateSearchResults(for searchController: UISearchController) {
        // If the search bar contains text, filter our data with the string
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            self.searchPage = 1
            self.searchMovie(query: searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            self.searchResults.removeAll()
        }
        else {
            self.emptyResults_lbl.isHidden = self.movies.count > 0
        }
        self.gridView.reloadData()
    }
    
    
    // MARK: Collection view protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBarIsEmpty() {
            return movies.count
        }
        else {
            return searchResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieReusableView", for: indexPath) as! MovieViewCell
        let movie = searchBarIsEmpty() ? movies[indexPath.row] : searchResults[indexPath.row]
        cell.image.sd_setImage(with: URL(string: movie.getPosterUrl()), placeholderImage: UIImage(named: "clapperboard.png"))
        
        cell.name_lbl.text = movie.getTitle()
        cell.year_lbl.text = movie.getYear()
        cell.setRating(movie.getVoteAverage())
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = (searchBarIsEmpty() ? movies.count : searchResults.count) - 1
        if !loadingData && indexPath.row == lastElement {
            if searchBarIsEmpty() {
                movieDiscover()
            }
            else {
                searchNextPage()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movie = sender as? MovieViewCell
        let indexPath = gridView.indexPath(for: movie!)
        let detailVC = segue.destination as! DetailViewController
        let row = indexPath!.row
        detailVC.movie = searchBarIsEmpty() ? self.movies[row] : self.searchResults[row]
    }
}



