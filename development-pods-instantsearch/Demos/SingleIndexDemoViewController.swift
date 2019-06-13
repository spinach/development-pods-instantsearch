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
import SDWebImage

class SingleIndexDemoViewController: UIViewController {
  
  let stackView = UIStackView()
  
  let searcher: SingleIndexSearcher
  
  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  
  let statsViewModel: StatsViewModel
  let statsController: LabelStatsController
  
  let hitsViewModel: HitsViewModel<Movie>
  let hitsTableViewController: HitsTableViewController<Movie>
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.queryInputViewModel = .init()
    self.searchBarController = .init(searchBar: .init())
    self.statsViewModel = .init()
    self.statsController = .init(label: .init())
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
    
    statsViewModel.connectSearcher(searcher)
    statsViewModel.connectController(statsController)
    
    hitsViewModel.connectSearcher(searcher)
    hitsViewModel.connectController(hitsTableViewController)
    
    searcher.search()
  }

}

private extension SingleIndexDemoViewController {
  
  func configureUI() {
    view.backgroundColor = .white
    configureSearchBar()
    configureStatsLabel()
    configureStackView()
    configureLayout()
  }
  
  func configureSearchBar() {
    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal
  }
  
  func configureStatsLabel() {
    statsController.label.translatesAutoresizingMaskIntoConstraints = false
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
    let statsContainer = UIView()
    statsContainer.translatesAutoresizingMaskIntoConstraints = false
    statsContainer.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    statsContainer.addSubview(statsController.label)
    NSLayoutConstraint.activate([
      statsController.label.topAnchor.constraint(equalTo: statsContainer.layoutMarginsGuide.topAnchor),
      statsController.label.bottomAnchor.constraint(equalTo: statsContainer.layoutMarginsGuide.bottomAnchor),
      statsController.label.leadingAnchor.constraint(equalTo: statsContainer.layoutMarginsGuide.leadingAnchor),
      statsController.label.trailingAnchor.constraint(equalTo: statsContainer.layoutMarginsGuide.trailingAnchor),
    ])
    stackView.addArrangedSubview(statsContainer)
    stackView.addArrangedSubview(hitsTableViewController.view)
    
    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
    ])
    
    searchBarController.searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true

    statsController.label.heightAnchor.constraint(equalToConstant: 16).isActive = true

  }
  
}

