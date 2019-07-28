//
//  Movie.swift
//  PrimerAppSwift
//
//  Created by Nicolas Herrera on 6/16/19.
//  Copyright © 2019 Nicolas Herrera. All rights reserved.
//

import Foundation

class Movie: NSObject {
    private var title : String = ""
    private var year : String = ""
    private var posterPath : String = ""
    private var voteAverage : Double = 0
    private var popularity : String = ""
    private var genres : Array<String> = []
    private var overview = ""
    var backdropPath = ""
    
    var id = 0
    
    
    init(movieDic: [String: Any]){
        self.id = movieDic["id"] as! Int
        guard let title = movieDic["title"] as? String else { return }
        self.title = title
        
        let date = movieDic["release_date"] as! String
        self.year = date
        
        self.popularity = (movieDic["popularity"] as! NSNumber).stringValue
        
        self.voteAverage = movieDic["vote_average"] as? Double ?? 0
        
        let base_url = "http://image.tmdb.org/t/p/"
        let file_size = "w500"
        
        var filePath = movieDic["poster_path"] as? String ?? ""
        var urlString = base_url + file_size + filePath
        self.posterPath = urlString
        
        filePath = movieDic["backdrop_path"] as? String ?? ""
        urlString = base_url + "w780" + filePath
        self.backdropPath = urlString
        
        
        self.overview = movieDic["overview"] as! String
    }
    
    func setGenres(from genresArray: [[String: Any]]) {
        self.genres.removeAll()
        for dic in genresArray{
            self.genres.append(dic["name"] as! String)
        }
    }
    
    func getGenresString() -> String {
        var genresStr = ""
        if (!genres.isEmpty) {
            genresStr = genres[0]
            for i in 1 ..< genres.count {
                genresStr = genresStr + ", " + genres[i]
            }
        }
        return genresStr
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getYear() -> String {
        return year
    }
    
    func getPosterUrl() -> String {
        return posterPath
    }
    
    func getBackdropUrl() -> String {
        return backdropPath
    }
    
    func getVoteAverage() -> Double {
        return voteAverage
    }
    
    func getOverview() -> String {
        return overview
    }
    
    func getPopularity() -> String {
        return popularity
    }
    
}
