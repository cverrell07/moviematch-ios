//
//  VideoModel.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

struct TrailerResponse: Codable {
    let results: [Trailer]
}

struct Trailer: Codable {
    let key: String
    let name: String
    let site: String
    let type: String
}
