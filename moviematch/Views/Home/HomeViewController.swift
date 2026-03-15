//
//  HomeViewController.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    private let viewModel = MovieListViewModel()
    private var collectionView: UICollectionView!
    private let disposeBag = DisposeBag()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "No movies available.\nPull to refresh."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground

        setupCollectionView()
        bindViewModel()
        viewModel.fetchNextPage.accept(())
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let width = (view.frame.width - 30) / 2
        layout.itemSize = CGSize(width: width, height: 300)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .appBackground
        collectionView.register(
            MovieCollectionViewCell.self,
            forCellWithReuseIdentifier: MovieCollectionViewCell.identifier
        )
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        collectionView.refreshControl = refreshControl

        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.viewModel.reset()
                self.viewModel.fetchNextPage.accept(())
            })
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        viewModel.movies
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                guard let self else { return }
                self.collectionView.reloadData()
                self.emptyStateView.isHidden = !movies.isEmpty
                self.collectionView.refreshControl?.endRefreshing()
            })
            .disposed(by: disposeBag)

        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self else { return }
                self.collectionView.refreshControl?.endRefreshing()
                self.showErrorAlert(message)
            })
            .disposed(by: disposeBag)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchNextPage.accept(())
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.value.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCollectionViewCell.identifier,
            for: indexPath
        ) as! MovieCollectionViewCell
        cell.configure(with: viewModel.movies.value[indexPath.row])
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies.value[indexPath.row]
        let detailVC = MovieDetailViewController(movieId: movie.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item >= viewModel.movies.value.count - 4 {
            viewModel.fetchNextPage.accept(())
        }
    }
}
