//
//  URLConnection.swift
//  MoviesChallenge
//
//  Created by Nicolas Herrera on 3/2/20.
//  Copyright © 2020 Nicolas Herrera. All rights reserved.
//

import Foundation

class URLConnection {
    
    func requestURL(_ url: URL?, completionHandler: @escaping ([String: Any]?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                guard let dataResponse = data,
                    error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return }
                do{
                    //here dataResponse received from a network request
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: []) as? [String: Any]
                    
                    completionHandler(jsonResponse, error)
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
            else {
                completionHandler(nil, error)
            }
        
        }
        task.resume()
    }
    
}
