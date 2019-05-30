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
import Kingfisher

struct Movie: Codable {
  let title: String
  let year: Int
  let image: URL
  let genre: [String]
}

class SingleIndexDemoViewController: UIViewController {

  let searcher: SingleIndexSearcher<Movie>
  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  let hitsViewModel: HitsViewModel<Movie>
  let hitsController: HitsTableController<HitsViewModel<Movie>>

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.searchBarController = SearchBarController(searchBar: .init())
    self.hitsViewModel = HitsViewModel()
    self.queryInputViewModel = QueryInputViewModel()
    self.hitsController = HitsTableController(tableView: .init())
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    hitsController.dataSource = HitsTableViewDataSource { (tableView, hit, indexPath) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
      cell.textLabel?.text = hit.title
      cell.detailTextLabel?.text = hit.genre.joined(separator: ", ")
      cell.imageView?.kf.setImage(with: hit.image)
      return cell
    }
    hitsController.delegate = MovieTableDelegate(clickHandler: { _, _, _ in })
        
    setupUI()
    
  }
  
  private func setup() {
    
    searcher.search()
    
    hitsViewModel.connect(to: searcher)
    hitsViewModel.connect(to: searcher.filterState)
    hitsViewModel.connect(to: hitsController)
    
    queryInputViewModel.connect(to: searchBarController)
    queryInputViewModel.connect(to: searcher, searchAsYouType: true)
    
  }

}

class MovieTableDelegate: HitsTableViewDelegate<HitsViewModel<Movie>> {
  
  @objc override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
}

extension SingleIndexDemoViewController {
  
  fileprivate func setupUI() {
    
    let searchBar = searchBarController.searchBar
    let tableView = hitsController.tableView
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    
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
