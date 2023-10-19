//
//  ForecastViewController.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/18/23.
//

import Combine
import Foundation
import UIKit

class ForecastViewController: UIViewController {    
    private let tableView = UITableView()
    private var tableViewDataSource: UITableViewDiffableDataSource<Sections, Forecast>?

    enum Sections: Int {
        // Leave this here for future cases
        case today  
    }
    
    private let forecast: Forecast
    private let dataSource: DataSource

    private var cancellables = Set<AnyCancellable>()

    init(forecast: Forecast,
         dataSource: DataSource) {
        self.forecast = forecast
        self.dataSource = dataSource

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        layoutViews()
        configureTableView()
    }

    private func layoutViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: tableView.separatorInset.top,
                                                left: tableView.separatorInset.left,
                                                bottom: tableView.separatorInset.bottom,
                                                right: 20)
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: ForecastTableViewCell.identifier)
        tableViewDataSource = UITableViewDiffableDataSource<Sections, Forecast>(tableView: tableView) {
            [weak self] in
            self?.tableView(tableView: $0, cellforRow: $2, at: $1)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Sections, Forecast>()
        snapshot.appendSections([.today])
        snapshot.appendItems([forecast], toSection: .today)
        tableViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

extension ForecastViewController: UITableViewDelegate {
    private func tableView(tableView: UITableView,
                   cellforRow row: Forecast,
                   at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCell.identifier) as? ForecastTableViewCell
        else { return UITableViewCell() }

        if let weatherIconId = row.weather.first?.icon {
            dataSource.fetchWeatherIcon(weatherIcon: weatherIconId)
                .receive(on: DispatchQueue.main)
                .sink { result in
                    switch result {
                    case .failure(let error):
                        // Log analytic event for missing weather Icon
                        print(error)
                    case .finished:
                        break
                    }
                } receiveValue: { image in
                    cell.applyImage(weatherIconImage: image)
                }
                .store(in: &cancellables)
        }
        cell.applyModel(forecast: row)
        return cell
    }
}
