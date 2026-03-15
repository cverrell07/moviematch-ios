//
//  MovieInfoView.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit

class MovieInfoViewCell: UICollectionViewCell {
    static let identifier = "MovieInfoViewCell"
    private let titleLabel = UILabel()
    private let ratingBadge = UIView()
    private let starIcon = UIImageView()
    private let ratingLabel = UILabel()
    private let metaLabel = UILabel()
    private let genreContainer = UIView()
    private let overviewLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overviewLabel.preferredMaxLayoutWidth = contentView.bounds.width
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        starIcon.image = UIImage(systemName: "star.fill")
        starIcon.tintColor = .black
        starIcon.contentMode = .scaleAspectFit
        starIcon.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.font = .systemFont(ofSize: 14, weight: .bold)
        ratingLabel.textColor = .black
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingBadge.backgroundColor = .systemYellow
        ratingBadge.layer.cornerRadius = 12
        ratingBadge.clipsToBounds = true
        ratingBadge.translatesAutoresizingMaskIntoConstraints = false

        let ratingStack = UIStackView(arrangedSubviews: [starIcon, ratingLabel])
        ratingStack.axis = .horizontal
        ratingStack.spacing = 4
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false

        ratingBadge.addSubview(ratingStack)

        metaLabel.font = .systemFont(ofSize: 14)
        metaLabel.textColor = .white.withAlphaComponent(0.7)
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        genreContainer.translatesAutoresizingMaskIntoConstraints = false

        overviewLabel.numberOfLines = 0
        overviewLabel.font = .systemFont(ofSize: 15)
        overviewLabel.textColor = .white
        overviewLabel.lineBreakMode = .byWordWrapping
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.textAlignment = .justified

        contentView.addSubview(ratingBadge)
        contentView.addSubview(metaLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(genreContainer)
        contentView.addSubview(overviewLabel)

        NSLayoutConstraint.activate([
            ratingBadge.topAnchor.constraint(equalTo: contentView.topAnchor),
            ratingBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingBadge.widthAnchor.constraint(equalToConstant: 60),
            ratingBadge.heightAnchor.constraint(equalToConstant: 26),

            ratingStack.topAnchor.constraint(equalTo: ratingBadge.topAnchor, constant: 4),
            ratingStack.bottomAnchor.constraint(equalTo: ratingBadge.bottomAnchor, constant: -4),
            ratingStack.leadingAnchor.constraint(equalTo: ratingBadge.leadingAnchor, constant: 8),
            ratingStack.trailingAnchor.constraint(equalTo: ratingBadge.trailingAnchor, constant: -8),

            starIcon.widthAnchor.constraint(equalToConstant: 14),
            starIcon.heightAnchor.constraint(equalToConstant: 14),

            metaLabel.centerYAnchor.constraint(equalTo: ratingBadge.centerYAnchor),
            metaLabel.leadingAnchor.constraint(equalTo: ratingBadge.trailingAnchor, constant: 10),
            metaLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: ratingBadge.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            genreContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            genreContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genreContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            genreContainer.heightAnchor.constraint(equalToConstant: 28),

            overviewLabel.topAnchor.constraint(equalTo: genreContainer.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(movie: MovieDetail) {
        let year = movie.releaseDate?.prefix(4) ?? ""
        let runtime = movie.runtime != nil ? "\(movie.runtime!) minutes" : ""

        titleLabel.text = movie.title
        ratingLabel.text = String(format: "%.1f", movie.voteAverage)
        metaLabel.text = "\(year) • \(runtime)"
        overviewLabel.text = movie.overview

        setupGenres(movie.genres)
    }

    private func setupGenres(_ genres: [Genre]) {
        genreContainer.subviews.forEach { $0.removeFromSuperview() }

        var previousLabel: UILabel?

        for genre in genres.prefix(3) {
            let label = PaddingLabel()
            label.text = genre.name
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius = 12
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false

            genreContainer.addSubview(label)

            if let previous = previousLabel {
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: 8),
                    label.centerYAnchor.constraint(equalTo: genreContainer.centerYAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: genreContainer.leadingAnchor),
                    label.centerYAnchor.constraint(equalTo: genreContainer.centerYAnchor)
                ])
            }

            previousLabel = label
        }

        if let last = previousLabel {
            last.trailingAnchor.constraint(lessThanOrEqualTo: genreContainer.trailingAnchor).isActive = true
        }
    }

    private func formatMoney(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.superview as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return super.preferredLayoutAttributesFitting(layoutAttributes)
        }

        let width = collectionView.bounds.width
            - layout.sectionInset.left
            - layout.sectionInset.right

        let targetSize = CGSize(width: width, height: 0)
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        layoutAttributes.frame.size = fittingSize
        return layoutAttributes
    }
}

class PaddingLabel: UILabel {

    var padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {

        let size = super.intrinsicContentSize

        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }
}
