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
        tableView.tableFooterView = UIView()
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
            self?.userInput(shouldEnable: true)
            self?.tableView.reloadData()
            self?.tableView.scroll(to: .top, animated: true)
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
        searchVenues()
    }
}

// MARK: TableView data source and delegate methods
extension VenueListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.venuesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let venueCell = tableView.dequeueReusableCell(withIdentifier: "venueCell", for: indexPath) as? VenueTableViewCell else { fatalError("failed to load venueCell")}
        let venue = viewModel.venue(at: indexPath.item)
        venueCell.configure(for: venue)
        return venueCell
    }
}

extension UITableView {
    
    public func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
    func scroll(to: scrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    enum scrollsTo {
        case top,bottom
    }
}
