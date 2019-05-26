//
//  SingleIndexDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearchCore
import InstantSearch

class SingleIndexDemoViewController: UIViewController {

  let searcher: SingleIndexSearcher<JSON>
  let searchBarController: SearchBarController
  let hitsViewModel: HitsViewModel<JSON>
  let hitsController: HitsTableController<HitsViewModel<JSON>>

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    let client = Client(appID: "latency", apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db")
    let index = client.index(withName: "bestbuy_promo")
    self.searcher = SingleIndexSearcher<JSON>(index: index)
    
    let searchBar = UISearchBar()
    self.searchBarController = SearchBarController(searchBar: searchBar)
    self.hitsViewModel = HitsViewModel()
    let tableView = UITableView(frame: .zero, style: .plain)
    self.hitsController = HitsTableController(tableView: tableView)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    searcher.search()
    searcher.indexSearchData.query.facets = ["category"]
    searchBarController.connectTo(searcher)
    hitsViewModel.connectSearcher(searcher)
    hitsViewModel.connectController(hitsController)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    hitsController.dataSource = HitsTableViewDataSource { (tableView, hit, indexPath) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
      cell.textLabel!.text = [String: Any](hit)?["name"] as? String
      return cell
    }
        
    setupUI()
    
  }

}

extension SingleIndexDemoViewController {
  
  fileprivate func setupUI() {
    
    let searchBar = searchBarController.searchBar
    let tableView = hitsController.tableView
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    
    view.addSubview(searchBar)

    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      searchBar.heightAnchor.constraint(equalToConstant: 40),
    ])
    
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
    ])

  }
  
}
