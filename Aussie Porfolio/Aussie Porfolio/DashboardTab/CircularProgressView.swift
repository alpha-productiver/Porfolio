import UIKit

final class CircularProgressView: UIView {

    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()

    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.text = "LVR"
        return label
    }()

    var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }

    var progressColor: UIColor = .systemGreen {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabels()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }

    private func setupLayers() {
        // Track layer (background circle)
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 12
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        // Progress layer (colored arc)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 12
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    private func setupLabels() {
        addSubview(percentageLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 0),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func updatePaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + (2 * CGFloat.pi)

        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }

    private func updateProgress() {
        progressLayer.strokeEnd = progress

        let percentage = Int(progress * 100)
        percentageLabel.text = "\(percentage)%"

        // Change color based on LVR level
        if progress < 0.6 {
            progressColor = .systemGreen
        } else if progress < 0.8 {
            progressColor = .systemOrange
        } else {
            progressColor = .systemRed
        }
    }

    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let clampedValue = min(max(value, 0), 1)

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.duration = 0.8
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }

        progress = clampedValue
    }
}
