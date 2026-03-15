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
    private let baseURL = "https://api.themoviedb.org/3/movie"
    
    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue("Bearer \(Config.tmdbToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func execute<T: Decodable>(_ request: URLRequest) -> Single<T> {
        return URLSession.shared.rx.response(request: request)
            .map { response, data -> Data in
                guard (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .map { try JSONDecoder().decode(T.self, from: $0) }
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
    func fetchMovies(page: Int = 1) -> Single<MovieResponse> {
        guard let url = URL(string: "\(baseURL)/popular?page=\(page)") else { return .error(URLError(.badURL)) }
        return execute(makeRequest(url: url))
    }
    
    func fetchMovieDetail(movieId: Int) -> Single<MovieDetail> {
        let urlString = "\(baseURL)/\(movieId)?append_to_response=videos"
        guard let url = URL(string: urlString) else { return .error(URLError(.badURL)) }
        return execute(makeRequest(url: url))
    }

    func fetchReviews(movieId: Int,
                      page: Int = 1) -> Single<ReviewResponse> {
        let urlString = "\(baseURL)/\(movieId)/reviews?page=\(page)"
        guard let url = URL(string: urlString) else { return .error(URLError(.badURL)) }
        return execute(makeRequest(url: url))
    }
}
