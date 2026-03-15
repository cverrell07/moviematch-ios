//
//  MovieListViewModel.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import Foundation
import RxSwift
import RxCocoa

class MovieListViewModel {
    let movies: BehaviorRelay<[Movie]> = .init(value: [])
    let fetchNextPage: PublishRelay<Void> = .init()
    let error: PublishRelay<String> = .init()

    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private let disposeBag = DisposeBag()

    init() {
        fetchNextPage
            .filter { [weak self] in
                guard let self else { return false }
                return !self.isFetching && self.currentPage <= self.totalPages
            }
            .flatMapLatest { [weak self] _ -> Single<MovieResponse> in
                guard let self else { return .never() }
                self.isFetching = true
                return MovieService.shared.fetchMovies(page: self.currentPage)
                    .catch { [weak self] err in
                        self?.isFetching = false
                        self?.error.accept(err.localizedDescription)
                        return Single<MovieResponse>.never()
                    }
            }
            .subscribe(
                onNext: { [weak self] response in
                    guard let self else { return }
                    self.isFetching = false
                    self.movies.accept(self.movies.value + response.results)
                    self.totalPages = response.totalPages
                    self.currentPage += 1
                },
                onError: { [weak self] _ in
                    self?.isFetching = false
                }
            )
            .disposed(by: disposeBag)
    }
    
    func reset() {
        currentPage = 1
        totalPages = 1
        isFetching = false
        movies.accept([])
    }
}
