//
//  FacetSearchDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 22/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import InstantSearch

class FacetSearchDemoViewController: UIViewController {

  let searcher: SingleIndexSearcher<JSON>
  let facetSearcher: FacetSearcher
  let searchBarController: SearchBarController
  let categoryController: FacetListTableController
  let categoryViewModel: SelectableFacetsViewModel
  let searchStateViewController: SearchStateViewController
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    let filterState = FilterState()
    let index: Index = .demo(withName: "mobile_demo_facet_list_search")
    self.searcher = SingleIndexSearcher(index: index, filterState: filterState)
    self.facetSearcher = FacetSearcher(index: index, filterState: filterState, facetName: Attribute("brand").name)

    let searchBar = UISearchBar()
    self.searchBarController = SearchBarController(searchBar: searchBar)
    
    self.searchStateViewController = SearchStateViewController()
    
    categoryViewModel = FacetListViewModel(selectionMode: .multiple)
    
    let tableView = UITableView()
    categoryController = FacetListTableController(tableView: tableView)

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    setup()


  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

}

private extension FacetSearchDemoViewController {
  
  func setup() {
    
    searcher.search()
    searchStateViewController.connectTo(searcher)

    facetSearcher.search()
//    searchBarController.connectTo(facetSearcher)
    searchStateViewController.connectTo(facetSearcher)
    categoryViewModel.connectTo(facetSearcher)
    categoryViewModel.connectTo(facetSearcher.filterState, with: Attribute("brand"), operator: .or)
    categoryViewModel.connectController(categoryController)
  }

  func setupUI() {
    
    view.backgroundColor = .white
    
    let mainStackView = UIStackView()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
    ])
    
    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal
    mainStackView.addArrangedSubview(searchBar)
    searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true

    searchStateViewController.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    addChild(searchStateViewController)
    searchStateViewController.didMove(toParent: self)
    mainStackView.addArrangedSubview(searchStateViewController.view)

    let tableView = categoryController.tableView
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    tableView.translatesAutoresizingMaskIntoConstraints = false

    mainStackView.addArrangedSubview(tableView)
    
  }

}

