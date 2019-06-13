//
//  SearchInputDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 13/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import InstantSearch

class SearchInputDemoViewController: UIViewController {
  
  let searchTriggeringMode: SearchTriggeringMode
  
  let stackView = UIStackView()
  let searcher: SingleIndexSearcher
  
  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  
  let hitsViewModel: HitsViewModel<Movie>
  let hitsTableViewController: HitsTableViewController<Movie>

  
  init(searchTriggeringMode: SearchTriggeringMode) {
    self.searchTriggeringMode = searchTriggeringMode
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.searchBarController = .init(searchBar: .init())
    self.queryInputViewModel = .init()
    self.hitsViewModel = .init(infiniteScrolling: .off, showItemsOnEmptyQuery: true)
    self.hitsTableViewController = HitsTableViewController()
    super.init(nibName: .none, bundle: .none)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  private func setup() {
    
    hitsViewModel.connectSearcher(searcher)
    hitsViewModel.connectController(hitsTableViewController)
    
    queryInputViewModel.connectController(searchBarController)
    queryInputViewModel.connectSearcher(searcher, searchTriggeringMode: searchTriggeringMode)
    
    searcher.search()
    
  }
  
}

private extension SearchInputDemoViewController {
  
  func configureUI() {
    view.backgroundColor = .white
    configureSearchBar()
    configureStackView()
    configureLayout()
  }
  
  func configureSearchBar() {
    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal
  }
  
  func configureStackView() {
    stackView.spacing = .px16
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureLayout() {
    
    searchBarController.searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    addChild(hitsTableViewController)
    hitsTableViewController.didMove(toParent: self)
    
    stackView.addArrangedSubview(searchBarController.searchBar)
    stackView.addArrangedSubview(hitsTableViewController.view)
    
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
      ])
    
  }
  
}




