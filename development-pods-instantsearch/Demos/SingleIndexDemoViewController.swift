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

struct Movie: Codable {
  let title: String
  let year: Int
  let image: URL
  let genre: [String]
}

struct Actor: Codable {
  let name: String
  let rating: Int
  let image_path: String
}

class SingleIndexDemoViewController: UIViewController, InstantSearchCore.HitsController {
  
  var hitsSource: HitsViewModel<Movie>?
  
  func reload() {
    tableView.reloadData()
  }
  
  func scrollToTop() {
    guard hitsViewModel.numberOfHits() > 0 else { return }
    tableView.scrollToRow(at: IndexPath(), at: .top, animated: false)
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
    self.searchBarController = SearchBarController(searchBar: .init())
    self.hitsViewModel = HitsViewModel()
    self.queryInputViewModel = QueryInputViewModel()
    self.tableView = UITableView(frame: .zero, style: .plain)
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
    hitsViewModel.connectFilterState(searcher.filterState)
    hitsViewModel.connectController(self)
    
    queryInputViewModel.connectController(searchBarController)
    queryInputViewModel.connectSearcher(searcher, searchAsYouType: true)
    
  }

}

class MovieTableDelegate: HitsTableViewDelegate<HitsViewModel<Movie>> {
  
  @objc override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
}

extension SingleIndexDemoViewController {
  
  fileprivate func setupUI() {
    
    view.backgroundColor = .white
    
    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    
    view.addSubview(searchBar)

    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      searchBar.heightAnchor.constraint(equalToConstant: 40),
    ])
    
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
    ])

  }
  
}

extension SingleIndexDemoViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsViewModel.numberOfHits()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    if let movie = hitsViewModel.hit(atIndex: indexPath.row) {
      cell.textLabel?.text = movie.title
      cell.detailTextLabel?.text = movie.genre.joined(separator: ", ")
      cell.imageView?.sd_setImage(with: movie.image, completed: { (_, _, _, _) in
        cell.setNeedsLayout()
      })
    }
    return cell
  }
  
}

extension SingleIndexDemoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
}


