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
    
    private var userLocation: UserLocation?

    init() {
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
        dataSource.geocoding(query: query)
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
                var snapshot = NSDiffableDataSourceSnapshot<Sections, Geocode>()
                snapshot.appendSections([.allCountries])
                snapshot.appendItems(cities, toSection: .allCountries)
                self?.tableViewDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .store(in: &cancellables)
    }
}

extension SearchScreenViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        
        geocoding(query: searchBarText)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        getUserLocation()
    }
    
    private func getUserLocation() {
        userLocation = UserLocation()
        userLocation?.getCoordinates()
        userLocation?.userLocationSubject
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("!!! \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }
}

extension SearchScreenViewController: UITableViewDelegate {
    func tableView(tableView: UITableView,
                   cellforRow row: Geocode,
                   at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier) as? CityTableViewCell
        else { return UITableViewCell() }

        cell.applyModel(city: row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Request weather for selected location using the coordinates
    }
}
