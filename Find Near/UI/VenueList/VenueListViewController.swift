//
//  VenueListViewController.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import UIKit

class VenueListViewController: UIViewController, UIBarPositioningDelegate, UISearchBarDelegate {

    // UI elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var venueCategorySegmentedControl: UISegmentedControl!
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    // Logic Componenets
    fileprivate let viewModel = VenueListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        prepareDefaultLocationForEnvoy()
    }
    
    // MARK: UI configurations
    @IBAction func changedVenueCategory(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            viewModel.updateVenueCategory(to: .restaurant)
        case 2:
            viewModel.updateVenueCategory(to: .bar)
        default:
            viewModel.updateVenueCategory(to: .coffeeShop)
        }
        searchVenues()
    }
    
    // Setup search bar
    fileprivate func setupSearchBar() {
        searchBar.delegate = self
        searchBar.sizeToFit()
        naviItem.titleView = searchBar
        searchBar.tintColor = UIColor.white
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor.darkGray
        }
        UITextField.self.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = UIColor.darkGray
        self.view.layoutIfNeeded()
    }
    
    // Configure Navigation bar to attach to top
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // Configure status bar to be light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Search Bar Delegate
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearchVenueAddress(to: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        userInput(shouldEnable: false)
        searchVenues()
    }
    
    fileprivate func searchVenues() {
        viewModel.searchVenues { [weak self] (error) in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            else {
                self?.tableView.reloadData()
            }
            self?.userInput(shouldEnable: true)
        }
    }
    
    fileprivate func userInput(shouldEnable: Bool) {
        searchBar.isUserInteractionEnabled = shouldEnable
        venueCategorySegmentedControl.isUserInteractionEnabled = shouldEnable
    }
    
    // For Evoy only
    fileprivate func prepareDefaultLocationForEnvoy() {
        let envoyAddress = "410 Townsend St, San Francisco, CA"
        searchBar.text = envoyAddress
        viewModel.updateSearchVenueAddress(to: envoyAddress)
    }
}

// MARK: TableView data source and delegate methods
extension VenueListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.venuesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let venueCell = tableView.dequeueReusableCell(withIdentifier: "venueCell", for: indexPath) as? VenueTableViewCell else { fatalError("failed to load venueCell")}
        return venueCell
    }
}
