//
//  MovieModel.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    let voteCount: Int
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case releaseDate = "release_date"
    }
}
