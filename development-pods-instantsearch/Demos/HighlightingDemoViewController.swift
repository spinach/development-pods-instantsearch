//
//  HighlightingDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 17/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import InstantSearch

class HighlightingDemoViewController: UIViewController {
  
  typealias HitType = Hit<Movie>
  
  let stackView = UIStackView()

  let searcher: SingleIndexSearcher

  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  
  let hitsViewModel: HitsViewModel<HitType>
  let hitsTableViewController: HitsTableViewController<HitType>
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.queryInputViewModel = .init()
    self.searchBarController = .init(searchBar: .init())
    self.hitsViewModel = .init()
    self.hitsTableViewController = HitsTableViewController()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
    
    queryInputViewModel.connectSearcher(searcher, searchTriggeringMode: .searchAsYouType)
    queryInputViewModel.connectController(searchBarController)
        
    hitsViewModel.connectSearcher(searcher)
    hitsViewModel.connectController(hitsTableViewController)
    
    searcher.search()
  }

  
}

private extension HighlightingDemoViewController {
  
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
    
    searchBarController.searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
  }
  
}
