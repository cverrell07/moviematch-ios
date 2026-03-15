//
//  MovieDetailViewController.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit
import RxSwift
import RxCocoa

class MovieDetailViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    init(movieId: Int) {
        self.viewModel = MovieDetailViewModel(movieId: movieId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupCollectionView()
        bindViewModel()
        viewModel.fetchAll.accept(())
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 300)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .appBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.register(MovieInfoViewCell.self, forCellWithReuseIdentifier: MovieInfoViewCell.identifier)
        collectionView.register(ReviewViewCell.self, forCellWithReuseIdentifier: ReviewViewCell.identifier)
        collectionView.register(
            MoviePosterHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MoviePosterHeader.identifier
        )
        
        view.addSubview(activityIndicator)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        activityIndicator.startAnimating()
    }

    private func bindViewModel() {
        viewModel.movie
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.activityIndicator.stopAnimating()
                self?.collectionView.reloadData()
                self?.updateHeaderSize()
            })
            .disposed(by: disposeBag)

        viewModel.reviews
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.activityIndicator.stopAnimating()
                self?.showErrorAlert(message)
            })
            .disposed(by: disposeBag)
    }

    private func updateHeaderSize() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        layout.headerReferenceSize = CGSize(
            width: view.frame.width,
            height: view.frame.width * 4 / 3 + statusBarHeight
        )
        layout.invalidateLayout()
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchAll.accept(())
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

extension MovieDetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieInfoViewCell.identifier,
                for: indexPath
            ) as! MovieInfoViewCell
            if let movie = viewModel.movie.value {
                cell.configure(movie: movie)
            }
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReviewViewCell.identifier,
            for: indexPath
        ) as! ReviewViewCell
        guard let review = viewModel.review(at: indexPath.item - 1) else {
            return UICollectionViewCell()
        }
        cell.configure(review: review)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MoviePosterHeader.identifier,
            for: indexPath
        ) as! MoviePosterHeader
        header.configure(movie: viewModel.movie.value, trailer: viewModel.trailer.value)
        return header
    }
}

extension MovieDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let threshold = viewModel.numberOfItems - 2
        guard indexPath.item >= threshold, viewModel.hasMoreReviews else { return }
        viewModel.fetchMoreReviews.accept(())
    }
}
