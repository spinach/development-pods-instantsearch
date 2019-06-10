//
//  FilterListDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 26/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import InstantSearch

struct FilterListDemo {
  
  static func facet() -> FilterListDemoViewController<Filter.Facet> {
    
    let facetFilters: [Filter.Facet] = ["red", "blue", "green", "yellow", "black"].map {
      .init(attribute: "color", stringValue: $0)
    }
    
    return FilterListDemoViewController<Filter.Facet>(items: facetFilters, selectionMode: .multiple)
    
  }
  
  static func numeric() -> FilterListDemoViewController<Filter.Numeric> {
    
    let numericFilters: [Filter.Numeric] = [5, 10, 50, 100, 500].map { .init(attribute: "price", operator: .lessThanOrEqual, value: $0) }
    
    return FilterListDemoViewController<Filter.Numeric>(items: numericFilters, selectionMode: .single)
    
  }
  
  static func tag() -> FilterListDemoViewController<Filter.Tag> {
    
    let tagFilters: [Filter.Tag] = [
      "coupon", "free shipping", "free return", "on sale", "no exchange"]
    
    return FilterListDemoViewController<Filter.Tag>(items: tagFilters, selectionMode: .multiple)
    
  }
  
}

class FilterListDemoViewController<F: FilterType & Hashable>: UIViewController {
  
  let searcher: SingleIndexSearcher
  let filterListViewModel: FilterListViewModel<F>
  let filterListController: FilterListTableController<F>
  let searchStateViewController: SearchStateViewController
  
  init(items: [F], selectionMode: SelectionMode) {
    searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_filter_list"))
    filterListViewModel = FilterListViewModel(items: items, selectionMode: selectionMode)
    filterListController = FilterListTableController(tableView: .init())
    searchStateViewController = SearchStateViewController()
    super.init(nibName: nil, bundle: nil)
    searcher.isDisjunctiveFacetingEnabled = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupUI()
  }
  
}

private extension FilterListDemoViewController {
  
  func setup() {
    searcher.search()
    filterListViewModel.connect(to: filterListController)
    filterListViewModel.connectFilterState(searcher.filterState, operator: .or)
    searchStateViewController.connectSearcher(searcher)
  }
  
  func setupUI() {
    
    view.backgroundColor = .white
    
    let mainStackView = UIStackView()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor),
      mainStackView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
    ])
    
    addChild(searchStateViewController)
    searchStateViewController.didMove(toParent: self)
    searchStateViewController.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    mainStackView.addArrangedSubview(searchStateViewController.view)
    mainStackView.addArrangedSubview(filterListController.tableView)
    
  }
  
}
