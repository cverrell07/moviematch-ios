//
//  MoviePosterHeader.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit

class MoviePosterHeader: UICollectionReusableView {
    static let identifier = "MoviePosterHeader"
    private let imageView = UIImageView()
    private let playButton = UIButton()
    private var trailer: Trailer?
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        gradientLayer.colors = [
            UIColor.appBackground.withAlphaComponent(0.1).cgColor,
            UIColor.appBackground.cgColor
        ]
        gradientLayer.locations = [0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.addSublayer(gradientLayer)
        
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.contentHorizontalAlignment = .fill
        playButton.contentVerticalAlignment = .fill

        addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80)
        ])

        playButton.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
    }

    func configure(movie: MovieDetail?, trailer: Trailer?) {
        guard let movie else { return }
        self.trailer = trailer
        playButton.isHidden = trailer == nil
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "")")
        loadImage(url)
    }

    private func loadImage(_ url: URL?) {
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }

    @objc private func playTrailer() {
        guard let trailer else { return }
        let url = URL(string: "https://www.youtube.com/watch?v=\(trailer.key)")
        if let url {
            UIApplication.shared.open(url)
        }
    }
}
