//
//  FPNSearchCountryViewController.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import Foundation

public class FPNSearchCountryViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    public static var cellTextColor = UIColor.darkText

    var searchController: UISearchController?
	var list: [FPNCountry]?
	var results: [FPNCountry]?

	var delegate: FPNDelegate?
    var selected: FPNCountry
    var showSearchBar: Bool
    var showDialCode: Bool = true

    init(countries: [FPNCountry], selectedCountry: FPNCountry, showSearchBar: Bool = false) {
        self.selected = selectedCountry
        self.showSearchBar = showSearchBar
		super.init(style: .grouped)
		self.list = countries
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override public func viewDidLoad() {
		super.viewDidLoad()
        title = "Select a Country"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(dismissController))
        if showSearchBar {
            initSearchBarController()
        }
	}

    override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if #available(iOS 11.0, *) {
			navigationItem.hidesSearchBarWhenScrolling = false
		} else {
			// Fallback on earlier versions
		}
	}

    override public func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

//        searchController?.isActive = true
	}

	@objc private func dismissController() {
		dismiss(animated: true, completion: nil)
	}

	private func initSearchBarController() {
		searchController = UISearchController(searchResultsController: nil)
		searchController?.searchResultsUpdater = self
		searchController?.delegate = self

		if #available(iOS 9.1, *) {
			searchController?.obscuresBackgroundDuringPresentation = false
		} else {
			// Fallback on earlier versions
		}

		if #available(iOS 11.0, *) {
			navigationItem.searchController = searchController
		} else {
			searchController?.dimsBackgroundDuringPresentation = false
			searchController?.hidesNavigationBarDuringPresentation = true
			searchController?.definesPresentationContext = true

			//				searchController?.searchBar.sizeToFit()
			tableView.tableHeaderView = searchController?.searchBar
		}
		definesPresentationContext = true
	}

	private func getItem(at indexPath: IndexPath) -> FPNCountry {
		var array: [FPNCountry]!

		if let searchController = searchController, searchController.isActive && results != nil && results!.count > 0 {
			array = results
		} else {
			array = list
		}

		return array[indexPath.row]
	}

    override public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let searchController = searchController, searchController.isActive {
			if let count = searchController.searchBar.text?.count, count > 0 {
				return results?.count ?? 0
			}
		}
		return list?.count ?? 0
	}

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Countries"
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
		let country = getItem(at: indexPath)

		cell.textLabel?.text = country.name
        cell.textLabel?.textColor = FPNSearchCountryViewController.cellTextColor

        if showDialCode {
            cell.detailTextLabel?.text = country.phoneCode
        }
		cell.imageView?.image = country.flag

        if country.code == selected.code {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
		return cell
	}

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        self.selected = getItem(at: indexPath)
		delegate?.fpnDidSelect(country: getItem(at: indexPath))
		searchController?.isActive = false
		searchController?.searchBar.resignFirstResponder()
        dismissController()
	}

	// UISearchResultsUpdating

    public func updateSearchResults(for searchController: UISearchController) {
		if list == nil {
			results?.removeAll()
			return
		} else if searchController.searchBar.text == "" {
			results?.removeAll()
			tableView.reloadData()
			return
		}

		if let searchText = searchController.searchBar.text, searchText.count > 0 {
			results = list!.filter({(item: FPNCountry) -> Bool in
				if item.name.lowercased().range(of: searchText.lowercased()) != nil {
					return true
				} else if item.code.rawValue.lowercased().range(of: searchText.lowercased()) != nil {
					return true
				} else if item.phoneCode.lowercased().range(of: searchText.lowercased()) != nil {
					return true
				}
				return false
			})
		}
		tableView.reloadData()
	}

	// UISearchControllerDelegate

    public func didPresentSearchController(_ searchController: UISearchController) {
		DispatchQueue.main.async { [unowned self] in
			self.searchController?.searchBar.becomeFirstResponder()
		}
	}

    public func willDismissSearchController(_ searchController: UISearchController) {
		results?.removeAll()
	}

    public func didDismissSearchController(_ searchController: UISearchController) {
		dismissController()
	}
}
