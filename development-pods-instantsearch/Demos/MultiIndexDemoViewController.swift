//
//  MultiIndexDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 09/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import InstantSearch
import UIKit

class MultiIndexDemoViewController: UIViewController, InstantSearchCore.MultiIndexHitsController {
  
  func reload() {
    tableView.reloadData()
  }
  
  func scrollToTop() {
    tableView.scrollToFirstNonEmptySection()
  }

  weak var hitsSource: MultiIndexHitsSource?
  
  let multiIndexSearcher: MultiIndexSearcher
  let searchBarController: SearchBarController
  let queryInputViewModel: QueryInputViewModel
  let multiIndexHitsViewModel: MultiIndexHitsViewModel
  let tableView: UITableView
  let cellIdentifier = "CellID"

  init() {
    tableView = .init(frame: .zero, style: .plain)
    
    let indices = [
      Section.actors.index,
      Section.movies.index,
    ]
    multiIndexSearcher = .init(client: .demo, indices: indices)
    
    let hitsViewModels: [AnyHitsViewModel] = [
      HitsViewModel<Actor>(infiniteScrolling: .off, showItemsOnEmptyQuery: true),
      HitsViewModel<Movie>(infiniteScrolling: .off, showItemsOnEmptyQuery: true)
    ]
    
    multiIndexHitsViewModel = .init(hitsViewModels: hitsViewModels)

    searchBarController = .init(searchBar: .init())
    queryInputViewModel = .init()
    
    super.init(nibName: nil, bundle: nil)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
    setupUI()
  }
  
}

private extension MultiIndexDemoViewController {
  
  func setup() {
    queryInputViewModel.connectSearcher(multiIndexSearcher, searchTriggeringMode: .searchAsYouType)
    queryInputViewModel.connectController(searchBarController)

    multiIndexHitsViewModel.connectSearcher(multiIndexSearcher)
    multiIndexHitsViewModel.connectController(self)
    
    multiIndexSearcher.search()
  }
  
  func configureTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  func setupUI() {
    
    view.backgroundColor = .white

    
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .fill
    
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
    
    searchBarController.searchBar.searchBarStyle = .minimal
    searchBarController.searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    stackView.addArrangedSubview(searchBarController.searchBar)
    stackView.addArrangedSubview(tableView)
    
  }

}

extension MultiIndexDemoViewController {
  
  enum Section: Int {
    
    case actors
    case movies
    
    init?(section: Int) {
      self.init(rawValue: section)
    }
    
    init?(indexPath: IndexPath) {
      self.init(rawValue: indexPath.section)
    }
    
    var title: String {
      switch self {
      case .actors:
        return "Actors"
      case .movies:
        return "Movies"
      }
    }
    
    var index: Index {
      switch self {
      case .actors:
        return .demo(withName: "mobile_demo_actors")
        
      case .movies:
        return .demo(withName: "mobile_demo_movies")
      }
    }
    
  }
  
}

extension MultiIndexDemoViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return hitsSource?.numberOfSections() ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsSource?.numberOfHits(inSection: section) ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Section(section: section)?.title
  }
  
}

extension MultiIndexDemoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let _ = Section(indexPath: indexPath) else { return 0 }
    return 80
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let section = Section(indexPath: indexPath) else { return }
    switch section {
    case .actors:
      try? hitsSource?.hit(atIndex: indexPath.row, inSection: indexPath.section).flatMap(CellConfigurator<Actor>.configure(cell))

    case .movies:
      try? hitsSource?.hit(atIndex: indexPath.row, inSection: indexPath.section).flatMap(CellConfigurator<Movie>.configure(cell))
    }
  }
  
}
