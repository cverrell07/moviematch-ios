//
//  Config.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit

struct Config {
    static var tmdbToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_TOKEN") as? String else {
            fatalError("TMDB_API_TOKEN not found")
        }
        
        return token
    }

}
