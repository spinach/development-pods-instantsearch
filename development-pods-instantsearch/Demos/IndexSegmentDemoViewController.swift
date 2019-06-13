//
//  IndexSegmentDemo.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 06/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearchCore
import InstantSearch

class IndexSegmentDemoViewController: UIViewController, InstantSearchCore.HitsController {

  var hitsSource: HitsViewModel<Movie>?

  func reload() {
    tableView.reloadData()
  }

  func scrollToTop() {
    guard tableView.numberOfRows(inSection: 0) > 0 else { return }
    tableView.scrollToRow(at: .zero, at: .top, animated: false)
  }

  typealias DataSource = HitsViewModel<Movie>

  let searcher: SingleIndexSearcher
  let filterState: FilterState
  let queryInputViewModel: QueryInputViewModel
  let searchBarController: SearchBarController
  let hitsViewModel: HitsViewModel<Movie>
  let indexSegmentViewModel: IndexSegmentViewModel

  let indexTitle: Index = .demo(withName: "mobile_demo_movies")
  let indexYearAsc: Index = .demo(withName: "mobile_demo_movies_year_asc")
  let indexYearDesc: Index = .demo(withName: "mobile_demo_movies_year_desc")

  let indexes: [Int: Index]

  let tableView: UITableView
  let alert = UIAlertController(title: "Change Index", message: "Please select a new index", preferredStyle: .actionSheet)

  private let cellIdentifier = "CellID"

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_movies"))
    self.filterState = .init()
    self.searchBarController = SearchBarController(searchBar: .init())
    self.hitsViewModel = HitsViewModel()
    self.queryInputViewModel = QueryInputViewModel()
    indexes = [
      0 : indexTitle,
      1 : indexYearAsc,
      2 : indexYearDesc
    ]
    indexSegmentViewModel = IndexSegmentViewModel(items: indexes)
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
    searcher.search()
    searcher.connectFilterState(filterState)

    hitsViewModel.connectSearcher(searcher)
    hitsViewModel.connectFilterState(filterState)
    hitsViewModel.connectController(self)

    queryInputViewModel.connectController(searchBarController)
    queryInputViewModel.connectSearcher(searcher, searchTriggeringMode: .searchAsYouType)

    indexSegmentViewModel.connectSearcher(searcher: searcher)
    indexSegmentViewModel.connectController(SelectIndexController(alertController: alert)) { (index) -> String in
      switch index {
      case self.indexTitle: return "Default"
      case self.indexYearAsc: return "Year Asc"
      case self.indexYearDesc: return "Year Desc"
      default: return index.name
      }
    }

  }

}

extension IndexSegmentDemoViewController {

  fileprivate func setupUI() {

    view.backgroundColor = .white

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(self.editButtonTapped(sender:)))


    let searchBar = searchBarController.searchBar
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.searchBarStyle = .minimal
    searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = .px16
    
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

  @objc func editButtonTapped(sender: UIBarButtonItem) {

//    alert.addAction(UIAlertAction(title: "Main", style: .default , handler:{ (UIAlertAction)in
//      print("User click mobile_demo_movies")
//    }))
//
//    alert.addAction(UIAlertAction(title: "Year Ascending", style: .default , handler:{ (UIAlertAction)in
//      print("User click mobile_demo_movies_year_asc")
//    }))
//
//    alert.addAction(UIAlertAction(title: "Year Descending", style: .default , handler:{ (UIAlertAction)in
//      print("User click mobile_demo_movies_year_desc")
//    }))

    self.present(alert, animated: true, completion: nil)
  }

}

extension IndexSegmentDemoViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsViewModel.numberOfHits()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    hitsViewModel.hit(atIndex: indexPath.row).flatMap(CellConfigurator.configure(cell))
    return cell
  }

}

extension IndexSegmentDemoViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

}


