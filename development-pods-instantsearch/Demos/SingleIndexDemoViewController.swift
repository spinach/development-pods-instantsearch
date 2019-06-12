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

class SingleIndexDemoViewController: UIViewController, InstantSearchCore.HitsController {
  
  weak var hitsSource: HitsViewModel<Movie>?
  
  func reload() {
    tableView.reloadData()
  }
  
  func scrollToTop() {
    guard tableView.numberOfRows(inSection: 0) > 0 else { return }
    tableView.scrollToRow(at: .zero, at: .top, animated: false)
  }
  
  typealias DataSource = HitsViewModel<Movie>

  let searcher: SingleIndexSearcher
  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  let hitsViewModel: HitsViewModel<Movie>
  
  let tableView: UITableView
  
  private let cellIdentifier = "CellID"

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.searchBarController = .init(searchBar: .init())
    self.hitsViewModel = .init()
    self.queryInputViewModel = .init()
    self.tableView = .init(frame: .zero, style: .plain)
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
  
  private func setup() {
    
    searcher.query = "quality sens"
    searcher.search()
    
    hitsViewModel.connectSearcher(searcher)
    hitsViewModel.connectController(self)
    
    queryInputViewModel.connectController(searchBarController)
    queryInputViewModel.connectSearcher(searcher, searchAsYouType: true)
    
  }

}

private extension SingleIndexDemoViewController {
  
  func setupUI() {
    
    view.backgroundColor = .white
    
    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal
    
    searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    
    let stackView = UIStackView()
    stackView.spacing = .px16
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(searchBar)
    stackView.addArrangedSubview(tableView)
    
    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
    ])

  }
  
}

extension SingleIndexDemoViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsSource?.numberOfHits() ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    hitsSource?.hit(atIndex: indexPath.row).flatMap(CellConfigurator<Movie>.configure(cell))
    return cell
  }
  
}

extension SingleIndexDemoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
}


