//
//  ActionButton.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit

class ActionButton: UIButton {

    // MARK: - Constant

    private enum C {

        static let height = CGFloat(56)
        static let spacing = CGFloat(8)

    }

    // MARK: - Model

    struct Model {

        var title: String
        var image: UIImage? = nil

    }

    // MARK: - Variables

    private var title: String?
    private var image: UIImage?
    private var shadowLayer: CAShapeLayer!

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        return activityIndicator
    }()

    override var isHighlighted: Bool {
        didSet {
            animate(isHighlighted: isHighlighted)
        }
    }

    var isLoading = false {
        didSet {
            guard oldValue != isLoading else { return }

            isLoading ? startLoading() : stopLoading()

            isUserInteractionEnabled = !isLoading
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        addIndicatorView()

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: C.height).isActive = true
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        setTitleColor(.black, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setup(_ model: Model) {
        setTitle(model.title, for: .normal)
    }

    func updateActivityIndicatorColor(color: UIColor) {
        activityIndicator.color = color
    }

}

// MARK: - Private

private extension ActionButton {

    func addIndicatorView() {
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
            centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor)
        ])
    }

    func startLoading() {
        activityIndicator.startAnimating()

        title = title(for: .normal)
        image = image(for: .normal)

        setTitle(nil, for: .normal)
        setImage(nil, for: .normal)
    }

    func stopLoading() {
        activityIndicator.stopAnimating()

        setTitle(title, for: .normal)
        setImage(image, for: .normal)
    }

}
