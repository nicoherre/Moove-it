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
    var idVideoYT : String?
    
    var id = 0
    
    let TITLE           = "title"
    let RELEASE_DATE    = "release_date"
    let POPULARITY      = "popularity"
    let VOTE_AVERAGE    = "vote_average"
    let POSTER_PATH     = "poster_path"
    let BACKDROP_PATH   = "backdrop_path"
    let POSTER_SIZE     = "w500"
    let BACKDROP_SIZE   = "w780"
    let OVERVIEW        = "overview"
    
    init(movieDic: [String: Any]){
        self.id = movieDic["id"] as! Int
        guard let title = movieDic[TITLE] as? String else { return }
        self.title = title
        
        let date = movieDic[RELEASE_DATE] as! String
        self.year = date
        
        self.popularity = (movieDic[POPULARITY] as! NSNumber).stringValue
        self.voteAverage = movieDic[VOTE_AVERAGE] as? Double ?? 0
        
        if let filePath = movieDic[POSTER_PATH] as? String {
            self.posterPath = Definitions.urlImageBase + POSTER_SIZE + filePath
        }
        
        if let filePath = movieDic[BACKDROP_PATH] as? String {
            self.backdropPath = Definitions.urlImageBase + BACKDROP_SIZE + filePath
        }

        self.overview = movieDic[OVERVIEW] as! String
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
