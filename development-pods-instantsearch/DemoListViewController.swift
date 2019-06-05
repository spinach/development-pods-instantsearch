//
//  DemoListViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 26/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import InstantSearch

typealias DemoHit = Hit<Demo>

struct Demo: Codable {
  
  let objectID: String
  let name: String
  let type: String
  let index: String
  
  enum ID: String {
    case singleIndex = "paging_single_searcher"
    case sffv = "facet_list_search"
    case toggle = "filter_toggle"
    case facetList = "facet_list"
    case segmented = "filter_segment"
    case facetFilterList = "filter_list_facet"
    case numericFilterList = "filter_list_numeric"
    case tagFilterList = "filter_list_tag"
    case filterNumericComparison = "filter_numeric_comparison"
  }
  
}


class DemoListViewController: UIViewController {
  
  let searcher: SingleIndexSearcher<DemoHit>
  let hitsViewModel: HitsViewModel<DemoHit>
  let searchBarController: SearchBarController
  
  let tableView: UITableView
  let searchController: UISearchController
  private let cellIdentifier = "cellID"
  var groupedDemos: [(groupName: String, demos: [Demo])]

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_home"))
    hitsViewModel = HitsViewModel(infiniteScrolling: .on(withOffset: 10), showItemsOnEmptyQuery: true)
    searchBarController = SearchBarController(searchBar: .init())
    groupedDemos = []
    hitsViewModel.connect(to: searcher)
    hitsViewModel.connect(to: searcher.filterState)
    searchController = UISearchController(searchResultsController: .none)
    searchController.dimsBackgroundDuringPresentation = false
    self.tableView = UITableView()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    definesPresentationContext = true
    searchController.searchResultsUpdater = self
    navigationItem.searchController = searchController
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    hitsViewModel.onResultsUpdated.subscribe(with: self) { results in
      let demos = results.hits.map { $0.object }
      self.updateDemos(demos)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  func configureCell(tableView: UITableView, hit: DemoHit, indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
//    cell.textLabel?.text = hit.object.name
//    return cell
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
    
    searcher.search()
    
  }
  
  func viewController(for index: Demo.ID) -> UIViewController {
    let viewController: UIViewController
    
    switch index {
    case .singleIndex:
      viewController = SingleIndexDemoViewController()
    case .sffv:
      viewController = FacetSearchDemoViewController()
    case .toggle:
      viewController = ToggleDemoViewController()
    case .facetList:
      viewController = RefinementListDemoViewController()
      
    case .segmented:
      viewController = SegmentedDemoViewController()

    case .filterNumericComparison:
      viewController = FilterNumericComparisonDemoViewController()
      
    case .facetFilterList:
      return FilterListDemo.facet()
      
    case .numericFilterList:
      return FilterListDemo.numeric()
      
    case .tagFilterList:
      return FilterListDemo.tag()

    }
    
    return viewController
  }
  
}

extension DemoListViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    searcher.query = searchController.searchBar.text
    searcher.search()
  }
}

extension DemoListViewController: UITableViewDataSource {
  
  func updateDemos(_ demos: [Demo]) {
    let demosPerType = Dictionary(grouping: demos, by: { $0.type })
    self.groupedDemos = demosPerType
      .sorted { $0.key < $1.key }
      .map { ($0.key, $0.value.sorted { $0.name < $1.name } ) }
    tableView.reloadData()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return groupedDemos.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groupedDemos[section].demos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let demo = groupedDemos[indexPath.section].demos[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    cell.textLabel?.text = demo.name
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return groupedDemos[section].groupName
  }
  
}

extension DemoListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let demo = groupedDemos[indexPath.section].demos[indexPath.row]
    
    print(demo.index)
    
    guard let demoID = Demo.ID(rawValue: demo.objectID) else {
      let notImplementedAlertController = UIAlertController(title: nil, message: "This demo is not implemented yet", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .cancel, handler: .none)
      notImplementedAlertController.addAction(okAction)
      navigationController?.present(notImplementedAlertController, animated: true, completion: .none)
      return
    }
    
    let viewController = self.viewController(for: demoID)
    viewController.title = demo.name
    
    navigationController?.pushViewController(viewController, animated: true)
  }
  
}
