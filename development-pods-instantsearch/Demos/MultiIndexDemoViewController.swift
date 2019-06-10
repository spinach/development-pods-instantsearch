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
import SDWebImage

class CellConfigurator<T> {
  static func configure(_ cell: UITableViewCell, with item: T) {}
}

extension CellConfigurator where T == Movie {
  
  static func configure(_ cell: UITableViewCell, with movie: T) {
    cell.textLabel?.text = movie.title
    cell.detailTextLabel?.text = movie.genre.joined(separator: ", ")
    cell.imageView?.sd_setImage(with: movie.image, completed: { (_, _, _, _) in
      cell.setNeedsLayout()
    })
  }
  
}

extension CellConfigurator where T == Actor {
  
  static func configure(_ cell: UITableViewCell, with actor: T) {
    cell.textLabel?.text = actor.name
    cell.detailTextLabel?.text = "rating: \(actor.rating)"
    let baseImageURL = URL(string: "https://image.tmdb.org/t/p/w45")
    let imageURL = baseImageURL?.appendingPathComponent(actor.image_path)
    cell.imageView?.sd_setImage(with: imageURL, completed: { (_, _, _, _) in
      cell.setNeedsLayout()
    })
  }
  
}

class MultiIndexDemoViewController: UIViewController, InstantSearchCore.MultiHitsController {
  
  func reload() {
    tableView.reloadData()
  }
  
  func scrollToTop() {
    let firstNonEmptySection = (0...tableView.numberOfSections - 1).filter { tableView.numberOfRows(inSection: $0) > 0 }.first
    guard let existingFirstNonEmptySection = firstNonEmptySection else {
      return
    }
    let indexPath = IndexPath(row: 0, section: existingFirstNonEmptySection)
    tableView.scrollToRow(at: indexPath, at: .top, animated: false)
  }
  
  let multiHitsViewModel: MultiHitsViewModel
  
  let moviesHitsViewModel = HitsViewModel<Movie>(infiniteScrolling: .off, showItemsOnEmptyQuery: true)
  let actorsHitsViewModel = HitsViewModel<Actor>(infiniteScrolling: .off, showItemsOnEmptyQuery: true)

  
  var hitsSource: MultiHitsSource? {
    get {
      return multiHitsViewModel
    }
    
    set {
      
    }
  }
  let multiIndexSearcher: MultiIndexSearcher
  let searchBarController: SearchBarController
  let queryInputViewModel: QueryInputViewModel
  let tableView: UITableView
  let cellIdentifier = "CellID"

  init() {
    let client: Client = .demo
    let moviesIndex: Index = .demo(withName: "mobile_demo_movies")
    let actorsIndex: Index = .demo(withName: "mobile_demo_actors")
    self.tableView = .init(frame: .zero, style: .plain)
    self.searchBarController = .init(searchBar: .init())
    self.queryInputViewModel = QueryInputViewModel()
    let actorsISD = IndexSearchData(index: actorsIndex)
    
    let moviesISD = IndexSearchData(index: moviesIndex)
    multiIndexSearcher = MultiIndexSearcher(client: client, indexSearchDatas: [actorsISD, moviesISD])
    
    
    self.multiHitsViewModel = MultiHitsViewModel(hitsViewModels: [actorsHitsViewModel, moviesHitsViewModel])
    super.init(nibName: nil, bundle: nil)
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    multiHitsViewModel.connectSearcher(multiIndexSearcher)
    multiHitsViewModel.connectController(self)
    multiIndexSearcher.search()
    setupUI()
    queryInputViewModel.connectSearcher(multiIndexSearcher, searchAsYouType: true)
    queryInputViewModel.connectController(searchBarController)
    
  }

  
}

private extension MultiIndexDemoViewController {
  
  func setupUI() {
    view.backgroundColor = .white
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    let mainStackView = UIStackView()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.distribution = .fill
    
    view.addSubview(mainStackView)
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
    
    searchBarController.searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    mainStackView.addArrangedSubview(searchBarController.searchBar)
    mainStackView.addArrangedSubview(tableView)
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
    
  }
  
}

extension MultiIndexDemoViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return multiHitsViewModel.numberOfSections()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return multiHitsViewModel.numberOfHits(inSection: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Actors"
    case 1:
      return "Movies"
    default:
      return nil
    }
  }
  
}

extension MultiIndexDemoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let section = Section(indexPath: indexPath) else { return 0 }

    switch section {
    case .actors:
      return 80
      
    case .movies:
      return 80
    }
    
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let section = Section(indexPath: indexPath) else { return }
    
    switch section {
    case .actors:
      if let actor = try? multiHitsViewModel.hit(at: indexPath) as Actor? {
        CellConfigurator<Actor>.configure(cell, with: actor)
      }
      
    case .movies:
      if let movie = try? multiHitsViewModel.hit(at: indexPath) as Movie? {
        CellConfigurator<Movie>.configure(cell, with: movie)
      }
    }
  }
  
}
