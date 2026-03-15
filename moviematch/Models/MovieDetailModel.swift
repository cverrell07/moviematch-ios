//
//  MovieDetailModel.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import Foundation

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genres: [Genre]
    let status: String?
    let homepage: String?
    let imdbId: String?
    let videos: TrailerResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case genres
        case status
        case homepage
        case imdbId = "imdb_id"
        case videos
    }
}

extension MovieDetail {
    var youtubeTrailerKey: String? {
        videos?.results.first {
            $0.site == "YouTube" && $0.type == "Trailer"
        }?.key
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}
