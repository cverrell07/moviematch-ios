//
//  ReviewCardCell.swift
//  moviematch
//
//  Created by Christopher Verrell on 15/03/26.
//

import UIKit

class ReviewViewCell: UICollectionViewCell {
    static let identifier = "ReviewViewCell"
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let timestampLabel = UILabel()
    private let ratingView = UIStackView()
    private let contentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        usernameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        usernameLabel.textColor = .white

        timestampLabel.font = .systemFont(ofSize: 12)
        timestampLabel.textColor = .white.withAlphaComponent(0.45)

        let headerStack = UIStackView(arrangedSubviews: [usernameLabel, timestampLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center

        ratingView.axis = .horizontal
        ratingView.spacing = 2
        ratingView.alignment = .center

        let metaStack = UIStackView(arrangedSubviews: [headerStack, ratingView])
        metaStack.axis = .vertical
        metaStack.spacing = 3
        metaStack.alignment = .leading

        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .white.withAlphaComponent(0.85)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping

        let rightStack = UIStackView(arrangedSubviews: [metaStack, contentLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 6
        rightStack.alignment = .leading

        let rootStack = UIStackView(arrangedSubviews: [avatarImageView, rightStack])
        rootStack.axis = .horizontal
        rootStack.spacing = 10
        rootStack.alignment = .top
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(rootStack)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),

            rightStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),

            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    func configure(review: Review) {
        let details = review.authorDetails
        setupUsername(name: details?.name,
                      username: details?.username)
        contentLabel.text = review.content
        timestampLabel.text = review.createdAt.formattedDate()
        setupRating(details?.rating)
        loadAvatar(details?.avatarPath)
    }
    
    private func setupUsername(name: String?,
                               username: String?) {
        if let name, !name.isEmpty {
            usernameLabel.text = name
        } else if let username, !username.isEmpty {
            usernameLabel.text = "@\(username)"
        } else {
            usernameLabel.text = "Anonymous"
        }
    }

    private func setupRating(_ rating: Int?) {
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let rating else { ratingView.isHidden = true; return }
        ratingView.isHidden = false

        let stars = rating / 2
        for i in 1...5 {
            let img: UIImage?
            if Int(i) <= stars {
                img = UIImage(systemName: "star.fill")
            } else if Int(i) - 1/2 <= stars {
                img = UIImage(systemName: "star.leadinghalf.filled")
            } else {
                img = UIImage(systemName: "star")
            }
            let iv = UIImageView(image: img)
            iv.tintColor = .systemYellow
            iv.widthAnchor.constraint(equalToConstant: 11).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 11).isActive = true
            ratingView.addArrangedSubview(iv)
        }
    }

    private func loadAvatar(_ path: String?) {
        avatarImageView.image = UIImage(named: "default_ava", in: Bundle.main, compatibleWith: nil)
        guard let path, !path.isEmpty else { return }
        let urlString: String
        if path.hasPrefix("http") {
            urlString = path.hasPrefix("/http") ? String(path.dropFirst()) : path
        } else {
            urlString = "https://image.tmdb.org/t/p/w92\(path)"
        }

        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.avatarImageView.image = image
            }
        }.resume()
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        guard let collectionView = superview as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return super.preferredLayoutAttributesFitting(layoutAttributes)
        }
        let width = collectionView.bounds.width
            - layout.sectionInset.left
            - layout.sectionInset.right
        let fittingSize = contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        layoutAttributes.frame.size = fittingSize
        return layoutAttributes
    }
}
