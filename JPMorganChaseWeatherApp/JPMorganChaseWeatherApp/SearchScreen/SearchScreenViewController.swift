//
//  SearchScreenViewController.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/13/23.
//

import Combine
import Foundation
import UIKit

class SearchScreenViewController: UIViewController {
    private let searchBarController = UISearchController(searchResultsController: nil)
    
    private let tableView = UITableView()
    private var tableViewDataSource: UITableViewDiffableDataSource<Sections, Geocode>?
    
    enum Sections: Int {
        // Leave this here for future cases
        case allCountries
    }
    
    private let dataSource = DataSource()
    private var cancellables = Set<AnyCancellable>()

    /// onFirstLaunchLocation is to determine if location is requested upon first launch or user action
    private var onFirstLaunchLocation = true
    private let userLocation: UserLocation
    private let defaults: Defaults
    
    private var forecastViewController: ForecastViewController?

    init(userLocation: UserLocation = UserLocation(),
         defaults: Defaults = Defaults()) {
        self.userLocation = userLocation
        self.defaults = defaults

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "JP Morgan Chase Weather App"
        view.backgroundColor = .white
        setupSearchBar()
        layoutViews()
        configureTableView()
        userLocation.getCoordinates()
        userLocationSubscription()
    }

    private func setupSearchBar() {
        searchBarController.searchBar.delegate = self
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = searchBarController
        searchBarController.searchBar.showsBookmarkButton = true
        searchBarController.searchBar.setImage(UIImage(named: "navigation"), for: .bookmark, state: .normal)
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
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.identifier)
        tableViewDataSource = UITableViewDiffableDataSource<Sections, Geocode>(tableView: tableView) {
            [weak self] in
            self?.tableView(tableView: $0, cellforRow: $2, at: $1)
        }
    }

    private func geocoding(query: String) {
        dataSource.geocoding(type: Geocode.self, query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    // TODO: Display appropriate error message
                    break
                }
            }, receiveValue: { [weak self] cities in
                guard !cities.isEmpty else {
                    // Show no results message
                    return
                }
                self?.applySnapshot(cities: cities)
            })
            .store(in: &cancellables)
    }
    
    private func weather(coordinates: Coordinates) {
        dataSource.fetchWeather(type: Forecast.self, coordinates: coordinates)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    // TODO: Display appropriate error message
                    break
                }
            }, receiveValue: { [weak self] forecast in
                self?.pushForecastViewController(using: forecast)
            })
            .store(in: &cancellables)
    }
    
    private func pushForecastViewController(using forecast: Forecast) {
        let forecastViewController = ForecastViewController(forecast: forecast,
                                                            dataSource: dataSource)
        forecastViewController.modalPresentationStyle = .formSheet
        forecastViewController.preferredContentSize = .init(width: 500, height: 800)
        self.forecastViewController = forecastViewController
        present(forecastViewController, animated: true)
    }
}

extension SearchScreenViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            applySnapshot(cities: [])
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        
        geocoding(query: searchBarText)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        onFirstLaunchLocation = false
        userLocation.getCoordinates()
    }
    
    private func userLocationSubscription() {
        userLocation.userLocationSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    switch error.kind {
                    case .restricted, .denied, .notDetermined:
                        if let onFirstLaunch = self?.onFirstLaunchLocation,
                           onFirstLaunch {
                            // If first launch then try last search city in Defaults
                            self?.tryLastSavedSeach()
                        }
                    case .error:
                        break
                    }
                    print("!!! \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] coordinates in
                self?.weather(coordinates: coordinates)
            })
            .store(in: &cancellables)
    }
    
    private func tryLastSavedSeach() {
        guard let savedCoordinates = defaults.savedCoordinates else { return }
        weather(coordinates: savedCoordinates)
    }
}

extension SearchScreenViewController: UITableViewDelegate {
    private func applySnapshot(cities: [Geocode]) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, Geocode>()
        snapshot.appendSections([.allCountries])
        snapshot.appendItems(cities, toSection: .allCountries)
        tableViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    private func tableView(tableView: UITableView,
                   cellforRow row: Geocode,
                   at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier) as? CityTableViewCell
        else { return UITableViewCell() }

        cell.applyModel(city: row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let city = tableViewDataSource?.itemIdentifier(for: indexPath) else { return }
        let coordinates = Coordinates(latitude: city.lat, longitude: city.lon)
        // Save city name
        defaults.savedCoordinates = coordinates
        weather(coordinates: coordinates)
    }
}
