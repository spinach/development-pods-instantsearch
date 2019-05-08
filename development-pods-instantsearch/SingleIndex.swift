//
//  MasterViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearchCore

class SingleIndexController: UIViewController, UITableViewDataSource {

  var searchBarWidget: SearchBarWidget!
  let hitsViewModel = HitsViewModel<JSON>()

  var tableView = UITableView()
  var activityIndicator = UIActivityIndicatorView()
  let searchBar = UISearchBar()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    setupUI()
    searchBarWidget = SearchBarWidget(searchBar: searchBar)

  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsViewModel.numberOfHits()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let rawHit = hitsViewModel.rawHitAtIndex(indexPath.row)
    cell.textLabel!.text = rawHit?["name"] as? String
    return cell
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

extension SingleIndexController {
  
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

extension SingleIndexController: SearcherPluggable {
  
  func plug<R>(_ searcher: SingleIndexSearcher<R>) where R : Decodable, R : Encodable {
    
    searcher.search()
    
    searcher.indexSearchData.query.facets = ["category"]
    
    searchBarWidget.subscribeToTextChangeHandler { text in
      searcher.setQuery(text: text)
      searcher.indexSearchData.query.page = 0
      searcher.search()
    }
    
    searcher.isLoading.subscribe(with: self) { isLoading in
      if isLoading {
        self.activityIndicator.startAnimating()
      } else {
        self.activityIndicator.stopAnimating()
      }
      
      }.onQueue(.main)
    
    searcher.onResultsChanged.subscribe(with: self) { [weak self] (queryMetada, result) in
      switch result {
      case .success(let result):
        let data = try! JSONEncoder().encode(result)
        let jsonResult = try! JSONDecoder().decode(SearchResults<JSON>.self, from: data)
        self?.hitsViewModel.update(jsonResult, with: queryMetada)
        
      case .failure(let error):
        print(error)
        break
      }
      
      self?.tableView.reloadData()
    }
    
    self.hitsViewModel.onNewPage.subscribe(with: self) { page in
      searcher.indexSearchData.query.page = UInt(page)
      searcher.search()
    }
  }
  
}
