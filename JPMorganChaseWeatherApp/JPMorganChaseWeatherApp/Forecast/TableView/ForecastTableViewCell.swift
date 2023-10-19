//
//  ForecastTableViewCell.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/18/23.
//

import Foundation
import UIKit

class ForecastTableViewCell: UITableViewCell {
    static let identifier = "ForecastTableViewCell"
    
    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline, compatibleWith: nil)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpHierarchy()
        setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUpHierarchy() {
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(weatherIconImageView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cityNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cityNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            cityNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weatherIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherIconImageView.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 20),
            weatherIconImageView.heightAnchor.constraint(equalTo: weatherIconImageView.widthAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 50),
            temperatureLabel.centerXAnchor.constraint(equalTo: weatherIconImageView.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func applyModel(forecast: Forecast) {
        cityNameLabel.text = forecast.name
        temperatureLabel.text = "\(forecast.temperature.temperature)°"
        descriptionLabel.text = forecast.weather.first?.description
    }
    
    func applyImage(weatherIconImage: UIImage) {
        weatherIconImageView.image = weatherIconImage
    }
}
