//
//  MovieDetailViewModel.swift
//  moviematch
//
//  Created by Christopher Verrell on 15/03/26.
//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailViewModel {
    let movie: BehaviorRelay<MovieDetail?> = .init(value: nil)
    let trailer: BehaviorRelay<Trailer?> = .init(value: nil)
    let reviews: BehaviorRelay<[Review]> = .init(value: [])
    let error: PublishRelay<String> = .init()
    let fetchAll: PublishRelay<Void> = .init()
    let fetchMoreReviews: PublishRelay<Void> = .init()
    var numberOfItems: Int {
        movie.value == nil ? 0 : 1 + reviews.value.count
    }
    var hasMoreReviews: Bool {
        reviewPage <= reviewTotalPages
    }
    private let movieId: Int
    private var reviewPage = 1
    private var reviewTotalPages = 1
    private var isFetchingReviews = false
    private let disposeBag = DisposeBag()
    
    func review(at index: Int) -> Review? {
        guard index < reviews.value.count else { return nil }
        return reviews.value[index]
    }

    init(movieId: Int) {
        self.movieId = movieId
        bindInputs()
    }

    private func bindInputs() {
        fetchAll
            .flatMapLatest { [weak self] _ -> Single<MovieDetail> in
                guard let self else { return .never() }
                return MovieService.shared.fetchMovieDetail(movieId: self.movieId)
                    .catch { [weak self] err in
                        self?.error.accept(err.localizedDescription)
                        return .never()
                    }
            }
            .subscribe(
                onNext: { [weak self] detail in
                    guard let self else { return }
                    self.movie.accept(detail)
                    self.trailer.accept(
                        detail.videos?.results.first {
                            $0.type == "Trailer" && $0.site == "YouTube"
                        }
                    )
                    self.loadReviews()
                },
                onError: { [weak self] err in
                    self?.error.accept(err.localizedDescription)
                }
            )
            .disposed(by: disposeBag)

        fetchAll
            .subscribe(onNext: { [weak self] in
                self?.loadReviews()
            })
            .disposed(by: disposeBag)

        fetchMoreReviews
            .subscribe(onNext: { [weak self] in
                self?.loadReviews()
            })
            .disposed(by: disposeBag)
    }

    private func loadReviews() {
        guard !isFetchingReviews, reviewPage <= reviewTotalPages else { return }
        isFetchingReviews = true
        MovieService.shared.fetchReviews(movieId: movieId, page: reviewPage)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let self else { return }
                    self.isFetchingReviews = false
                    self.reviews.accept(self.reviews.value + response.results)
                    self.reviewTotalPages = response.totalPages
                    self.reviewPage += 1
                },
                onFailure: { [weak self] err in
                    self?.isFetchingReviews = false
                    self?.error.accept(err.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
