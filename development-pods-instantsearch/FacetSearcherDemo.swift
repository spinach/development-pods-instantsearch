//
//  SearchForFaceValuesDemo.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 22/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import InstantSearch

class FacetSearcherDemo: UIViewController {

  var searchBarController: SearchBarController!
  let hitsViewModel = HitsViewModel<JSON>()
  var categoryViewModel: SelectableFacetsViewModel!
  let tableView = UITableView()
  let activityIndicator = UIActivityIndicatorView()
  let searchBar = UISearchBar()

  override func viewDidLoad() {
    super.viewDidLoad()

    searchBarController = SearchBarController(searchBar: searchBar)

    categoryViewModel = FacetListViewModel(selectionMode: .multiple)
    let categoryController = FacetListTableController(tableView: tableView)
    categoryViewModel.connectController(categoryController)


    setupUI()

  }

  //  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  //    if (segue.identifier == "refinementListSegue") {
  //      let refinementListController = segue.destination as! RefinementListController
  //      refinementListController.searcher = searcher
  //      refinementListController.filterState = filterState
  //      refinementListController.query = query
  //    }
  //  }

}

extension FacetSearcherDemo {

  fileprivate func setupUI() {
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(tableView)
    self.view.addSubview(searchBar)
    self.view.addSubview(activityIndicator)

    searchBar.searchBarStyle = .minimal
    activityIndicator.style = .gray

    activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
    activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

    searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
    searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
      ])


    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
  }

}

extension FacetSearcherDemo: SearcherPluggable {

  func plug<R>(_ searcher: SingleIndexSearcher<R>) where R : Decodable, R : Encodable {

  }

  func plug(_ facetSearcher: FacetSearcher) {

    categoryViewModel.connectTo(facetSearcher.filterState, with: Attribute("brand"), operator: .or)

    categoryViewModel.connectTo(facetSearcher)


    facetSearcher.search()
    searchBarController.connectTo(facetSearcher)

  }

}
