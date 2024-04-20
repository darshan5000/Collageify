//
//  MaterialActivityIndicator.swift
//  MaterialActivityIndicator
//
//  Created by Jans Pavlovs on 02/13/2018.
//  Copyright (c) 2018 Jans Pavlovs. All rights reserved.
//

import UIKit

@IBDesignable
public class MaterialActivityIndicatorView: UIView {
    @IBInspectable
    public var image: UIImage = .init() {
        didSet {
            imageView.image = image
        }
    }

    @IBInspectable
    public var color: UIColor = .red {
        didSet {
            indicator.strokeColor = color.cgColor
        }
    }

    @IBInspectable
    public var lineWidth: CGFloat = 4.0 {
        didSet {
            indicator.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    private let indicator = CAShapeLayer()
    private let imageView = UIImageView()
    private let animator = MaterialActivityIndicatorAnimator()

    private var isAnimating = false
    private let indicatorSize: CGFloat = 50

    convenience init() {
        self.init(frame: .zero)
        setup()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)

        indicator.strokeColor = color.cgColor
        indicator.fillColor = nil
        indicator.lineWidth = lineWidth
        indicator.strokeStart = 0.0
        indicator.strokeEnd = 0.0
        layer.addSublayer(indicator)

        let sizee: CGFloat = indicatorSize - 14
        let centerr = center
        imageView.frame = CGRect(origin: CGPoint(x: centerr.x - sizee / 2, y: centerr.y - sizee / 2), size: CGSize(width: sizee, height: sizee))
        imageView.layer.cornerRadius = 5 // sizee/2
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
}

public extension MaterialActivityIndicatorView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: indicatorSize, height: indicatorSize)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        indicator.frame = bounds

//        let diameter = bounds.size.min - indicator.lineWidth
        let diameter = indicatorSize
        let path = UIBezierPath(center: bounds.center, radius: diameter / 2)
        indicator.path = path.cgPath
    }
}

public extension MaterialActivityIndicatorView {
    func startAnimating() {
        guard !isAnimating else { return }
        animator.addAnimation(to: indicator)
        isAnimating = true
    }

    func stopAnimating() {
        guard isAnimating else { return }
        animator.removeAnimation(from: indicator)
        isAnimating = false
        removeFromSuperview()
    }
}
