//
//  MovieCollectionViewCell.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    static let identifier = "MovieCollectionViewCell"
    private let posterImageView = UIImageView()
    private let ratingBadge = UILabel()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            transform = isHighlighted
            ? CGAffineTransform(scaleX: 0.96, y: 0.96)
            : .identity
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        setupPoster()
        setupInfo()
    }

    private func setupPoster() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 10

        ratingBadge.font = .boldSystemFont(ofSize: 12)
        ratingBadge.textColor = .white
        ratingBadge.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        ratingBadge.layer.cornerRadius = 6
        ratingBadge.clipsToBounds = true
        ratingBadge.textAlignment = .center

        contentView.addSubview(posterImageView)
        posterImageView.addSubview(ratingBadge)

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        ratingBadge.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            posterImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor,
                                                    multiplier: 4.0/3.0),

            ratingBadge.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            ratingBadge.rightAnchor.constraint(equalTo: posterImageView.rightAnchor, constant: -8),
            ratingBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            ratingBadge.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

    private func setupInfo() {
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        infoLabel.textColor = .white.withAlphaComponent(0.7)

        let stack = UIStackView(arrangedSubviews: [titleLabel, infoLabel])
        stack.axis = .vertical
        stack.spacing = 4

        contentView.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        let year = movie.releaseDate?.prefix(4) ?? ""
        infoLabel.text = "\(year)"
        ratingBadge.text = "⭐ \(String(format: "%.1f", movie.voteAverage))"
        if let path = movie.posterPath {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
            loadImage(url)
        }
    }

    private func loadImage(_ url: URL?) {
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
