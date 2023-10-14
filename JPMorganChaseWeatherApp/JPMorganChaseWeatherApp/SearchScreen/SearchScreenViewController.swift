//
//  SearchScreenViewController.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/13/23.
//

import Foundation
import UIKit

class SearchScreenViewController: UIViewController {
    private let searchBarController = UISearchController(searchResultsController: nil)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        setupSearchBar()
    }

    private func setupSearchBar() {
        searchBarController.searchBar.delegate = self
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.searchBar.sizeToFit()
        navigationItem.searchController = searchBarController
    }
}

extension SearchScreenViewController: UISearchBarDelegate {
}
