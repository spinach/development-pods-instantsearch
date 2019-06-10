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

  let searcher: SingleIndexSearcher
  let filterState: FilterState
  let facetSearcher: FacetSearcher
  let searchBarController: SearchBarController
  let categoryController: FacetListTableController
  let categoryListViewModel: SelectableFacetsViewModel
  let searchStateViewController: SearchStateViewController
  
  let queryInputViewModel: QueryInputViewModel
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    let index: Index = .demo(withName: "mobile_demo_facet_list_search")
    
    searcher = SingleIndexSearcher(index: index)
    filterState = .init()
    facetSearcher = FacetSearcher(index: index, facetName: Attribute("brand").name)
    
    queryInputViewModel = QueryInputViewModel()
    categoryListViewModel = FacetListViewModel(selectionMode: .multiple)

    searchBarController = SearchBarController(searchBar: .init())
    searchStateViewController = SearchStateViewController()
    categoryController = FacetListTableController(tableView: .init())

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
    searcher.connectFilterState(filterState)

    facetSearcher.search()
    facetSearcher.connectFilterState(filterState)

    searchStateViewController.connectSearcher(searcher)
    searchStateViewController.connectFilterState(filterState)
    searchStateViewController.connectFacetSearcher(facetSearcher)

    queryInputViewModel.connectController(searchBarController)
    queryInputViewModel.connectSearcher(facetSearcher, searchAsYouType: true)
    
    categoryListViewModel.connectFacetSearcher(facetSearcher)
    categoryListViewModel.connectFilterState(filterState, with: Attribute("brand"), operator: .or)
    categoryListViewModel.connect(to: categoryController)
    
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

