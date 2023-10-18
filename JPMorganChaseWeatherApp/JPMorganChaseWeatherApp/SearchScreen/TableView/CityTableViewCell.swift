//
//  CityTableViewCell.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/14/23.
//

import Foundation
import UIKit

class CityTableViewCell: UITableViewCell {
    static let identifier = "CityTableViewCell"
    
    private var cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var countryNameLabel: UILabel = {
        let label = UILabel()
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
        contentView.addSubview(stateLabel)
        contentView.addSubview(countryNameLabel)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cityNameLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            cityNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cityNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stateLabel.leadingAnchor.constraint(equalTo: cityNameLabel.leadingAnchor),
            stateLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor),
            stateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            countryNameLabel.leadingAnchor.constraint(equalTo: stateLabel.trailingAnchor),
            countryNameLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor),
            countryNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            countryNameLabel.bottomAnchor.constraint(equalTo: stateLabel.bottomAnchor)
        ])

        stateLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func applyModel(city: Geocode) {
        cityNameLabel.text = city.name
        stateLabel.text = city.state + ", "
        countryNameLabel.text = city.country
    }
}
