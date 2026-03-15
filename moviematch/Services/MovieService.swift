//
//  MovieService.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import Foundation
import RxSwift
import RxCocoa

class MovieService {
    static let shared = MovieService()
    private let baseURL = "https://api.themoviedb.org/3/movie/popular"

    func fetchMovies(page: Int = 1) -> Single<MovieResponse> {
        guard let url = URL(string: "\(baseURL)?page=\(page)") else {
            return .error(URLError(.badURL))
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.tmdbToken)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.rx.data(request: request)
            .map { try JSONDecoder().decode(MovieResponse.self, from: $0) }
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    func fetchMovieDetail(movieId: Int) -> Single<MovieDetail> {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)?append_to_response=videos"
        guard let url = URL(string: urlString) else {
            return .error(URLError(.badURL))
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.tmdbToken)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.rx.data(request: request)
            .map { try JSONDecoder().decode(MovieDetail.self, from: $0) }
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    func fetchReviews(movieId: Int, page: Int = 1) -> Single<ReviewResponse> {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/reviews?page=\(page)"
        guard let url = URL(string: urlString) else {
            return .error(URLError(.badURL))
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.tmdbToken)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.rx.data(request: request)
            .map { try JSONDecoder().decode(ReviewResponse.self, from: $0) }
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
}
