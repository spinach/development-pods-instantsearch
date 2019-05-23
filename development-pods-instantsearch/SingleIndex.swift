//
//  MasterViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearchCore
import InstantSearch

class SingleIndexController: UIViewController {

  var searchBarController: SearchBarController!
  let hitsViewModel = HitsViewModel<JSON>()
  var hitsController: HitsTableController<HitsViewModel<JSON>>!
  let tableView = UITableView()
  let activityIndicator = UIActivityIndicatorView()
  let searchBar = UISearchBar()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBarController = SearchBarController(searchBar: searchBar)
    
    hitsController = HitsTableController(tableView: tableView)
    
    hitsController.dataSource = HitsTableViewDataSource<HitsViewModel<JSON>>(cellConfigurator: { (tableView, rawHit, indexPath) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
      cell.textLabel!.text = [String: Any](rawHit)?["name"] as? String
      return cell
    })
        
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
    
    searchBarController.onSearch.subscribe(with: self) { text in
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
    
    if let searcher = searcher as? SingleIndexSearcher<JSON> {
      hitsViewModel.connectSearcher(searcher)
    }
    
    hitsViewModel.connectController(hitsController)
    
  }
  
}
