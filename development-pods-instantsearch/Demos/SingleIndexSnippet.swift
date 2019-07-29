//
//  SingleIndexSnippet.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearch

class SingleIndexSnippetViewController: UIViewController {
  
  let searcher: SingleIndexSearcher
  
  let queryInputInteractor: QueryInputInteractor
  let searchBarController: SearchBarController
  
  let statsInteractor: StatsInteractor
  let statsController: LabelStatsController
  
  let hitsInteractor: HitsInteractor<JSON>
  let hitsTableController: HitsTableController<HitsInteractor<JSON>>
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    searcher = SingleIndexSearcher(appID: "latency",
                                   apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db",
                                   indexName: "mobile_demo_movies")
    
    queryInputInteractor = .init()
    searchBarController = .init(searchBar: UISearchBar())
    
    statsInteractor = .init()
    statsController = .init(label: UILabel())
    
    hitsInteractor = .init()
    hitsTableController = .init(tableView: UITableView())
    
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    configureUI()
  }
  
}

private extension SingleIndexSnippetViewController {
  
  func setup() {
    
    queryInputInteractor.connectSearcher(searcher)
    queryInputInteractor.connectController(searchBarController)
    
    statsInteractor.connectSearcher(searcher)
    statsInteractor.connectController(statsController)
    
    hitsInteractor.connectSearcher(searcher)
    hitsInteractor.connectController(hitsTableController)
    
    hitsTableController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
    hitsTableController.dataSource = .init(cellConfigurator: { tableView, hit, indexPath in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
      cell.textLabel?.text = [String: Any](hit)?["title"] as? String
      return cell
    })
    
    hitsTableController.delegate = .init(clickHandler: { tableView, hit, indexPath in
      
    })
    
    searcher.search()
  }
  
  func configureUI() {
    
    view.backgroundColor = .white
    
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 16
    stackView.axis = .vertical
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    stackView.isLayoutMarginsRelativeArrangement = true
    
    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    searchBar.searchBarStyle = .minimal
    stackView.addArrangedSubview(searchBar)
    
    let statsLabel = statsController.label
    statsLabel.translatesAutoresizingMaskIntoConstraints = false
    statsLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    stackView.addArrangedSubview(statsLabel)
    
    stackView.addArrangedSubview(hitsTableController.tableView)
    
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      ])
    
  }
  
}
