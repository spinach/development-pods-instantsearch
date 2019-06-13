//
//  StatsDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 13/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import InstantSearchCore
import InstantSearch

class StatsDemoViewController: UIViewController {
  
  let stackView = UIStackView()
  
  let searcher: SingleIndexSearcher
  
  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  
  let statsViewModel: StatsViewModel
  let labelStatsControllerMS: LabelStatsController
  let attributedLabelStatsController: AttributedLabelStatsController
  
  init() {
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.searchBarController = .init(searchBar: .init())
    self.queryInputViewModel = .init()
    self.statsViewModel = .init()
    self.attributedLabelStatsController = AttributedLabelStatsController(label: .init())
    self.labelStatsControllerMS = LabelStatsController(label: .init())
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
    
    queryInputViewModel.connectController(searchBarController)
    queryInputViewModel.connectSearcher(searcher, searchTriggeringMode: .searchAsYouType)
    
    statsViewModel.connectSearcher(searcher)
    statsViewModel.connectController(labelStatsControllerMS) { stats -> String? in
      guard let stats = stats else {
        return nil
      }
      return "\(stats.totalHitsCount) hits in \(stats.processingTimeMS) ms"
    }
    
    statsViewModel.connectController(attributedLabelStatsController) { stats -> NSAttributedString? in
      guard let stats = stats else {
        return nil
      }
      let string = NSMutableAttributedString()
      string.append(NSAttributedString(string: "\(stats.totalHitsCount)", attributes: [NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 15)!]))
      string.append(NSAttributedString(string: "  hits"))
      return string
    }
    
    searcher.search()
    
  }
  
}

private extension StatsDemoViewController {
  
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
    
    stackView.addArrangedSubview(searchBarController.searchBar)
    let statsMSContainer = UIView()
    statsMSContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
    statsMSContainer.translatesAutoresizingMaskIntoConstraints = false
    statsMSContainer.layoutMargins = UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20)
    labelStatsControllerMS.label.translatesAutoresizingMaskIntoConstraints = false
    statsMSContainer.addSubview(labelStatsControllerMS.label)
    NSLayoutConstraint.activate([
      labelStatsControllerMS.label.topAnchor.constraint(equalTo: statsMSContainer.layoutMarginsGuide.topAnchor),
      labelStatsControllerMS.label.bottomAnchor.constraint(equalTo: statsMSContainer.layoutMarginsGuide.bottomAnchor),
      labelStatsControllerMS.label.leadingAnchor.constraint(equalTo: statsMSContainer.layoutMarginsGuide.leadingAnchor),
      labelStatsControllerMS.label.trailingAnchor.constraint(equalTo: statsMSContainer.layoutMarginsGuide.trailingAnchor),
    ])
    stackView.addArrangedSubview(statsMSContainer)
    
    let attributedStatsContainer = UIView()
    attributedStatsContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
    attributedStatsContainer.translatesAutoresizingMaskIntoConstraints = false
    attributedStatsContainer.layoutMargins = UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20)
    attributedLabelStatsController.label.translatesAutoresizingMaskIntoConstraints = false
    attributedStatsContainer.addSubview(attributedLabelStatsController.label)
    NSLayoutConstraint.activate([
      attributedLabelStatsController.label.topAnchor.constraint(equalTo: attributedStatsContainer.layoutMarginsGuide.topAnchor),
      attributedLabelStatsController.label.bottomAnchor.constraint(equalTo: attributedStatsContainer.layoutMarginsGuide.bottomAnchor),
      attributedLabelStatsController.label.leadingAnchor.constraint(equalTo: attributedStatsContainer.layoutMarginsGuide.leadingAnchor),
      attributedLabelStatsController.label.trailingAnchor.constraint(equalTo: attributedStatsContainer.layoutMarginsGuide.trailingAnchor),
      ])

    stackView.addArrangedSubview(attributedStatsContainer)
    stackView.addArrangedSubview(UIView())
    
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
    ])
    
  }
  
}
