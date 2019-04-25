//
//  RefinementList.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 11/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

class RefinementsDemo: UIViewController, UITableViewDataSource, UITableViewDelegate {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "mobile_demo_refinement_facet"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  var topLeftViewModel: RefinementFacetsViewModel!
  var topRightViewModel: RefinementFacetsViewModel!
  var bottomRightViewModel: RefinementFacetsViewModel!
  var bottomLeftViewModel: RefinementFacetsViewModel!

  var searcher: SingleIndexSearcher<JSON>!
  var searcherSFFV: FacetSearcher!
  var client: Client!
  var index: Index!
  var filterState: FilterState = FilterState()
  var query: Query = Query()
  var topLeftSortedFacetValues: [RefinementFacet] = []
  var topRightSortedFacetValues: [RefinementFacet] = []
  var bottomLeftSortedFacetValues: [RefinementFacet] = []
  var bottomRightSortedFacetValues: [RefinementFacet] = []

  let topLeftTableView = UITableView()
  let topRightTableView = UITableView()
  let bottomLeftTableView = UITableView()
  let bottomRightTableView = UITableView()
  var allTableViews: [UITableView] = []
  var filterValueLabel: UILabel!

  let px16: CGFloat = 16

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor =  UIColor(hexString: "#f7f8fa")

    setupUI()

    client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
    index = client.index(withName: ALGOLIA_INDEX_NAME)
    searcher = SingleIndexSearcher(index: index, query: query, filterState: filterState)
    query.facets = ["color", "promotion", "category"]
    searcher.search()

    topLeftViewModel = RefinementFacetsViewModel(selectionMode: .single)
    topLeftViewModel.connect(attribute: Attribute("color"), searcher: searcher, operator: .and)
//    let refinementListPresenter = RefinementListPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)], limit: 5)
//    topLeftViewModel.connect(refinementPresenter: RefinementListPresenter(), refinementFacetsView: topLeftTableView) { (selectableRefinements) in
//      self.topLeftSortedFacetValues = selectableRefinements
//    }

    topRightViewModel = RefinementFacetsViewModel(selectionMode: .single)
    topRightViewModel.connect(attribute: Attribute("color"), searcher: searcher, operator: .and)

    bottomLeftViewModel = RefinementFacetsViewModel(selectionMode: .multiple)
    bottomLeftViewModel.connect(attribute: Attribute("promotion"), searcher: searcher, operator: .and)

    bottomRightViewModel = RefinementFacetsViewModel(selectionMode: .multiple)
    bottomRightViewModel.connect(attribute: Attribute("category"), searcher: searcher, operator: .or)



    topLeftViewModel.onItemsChanged.subscribe(with: self) { [weak self] (facetValues) in
      let refinementListPresenter = RefinementListPresenter()
      self?.topLeftSortedFacetValues =
        refinementListPresenter.processFacetValues(
          selectedValues: Array(self?.topLeftViewModel.selections ?? Set()),
          resultValues: facetValues,
          sortBy: [.isRefined, .alphabetical(order: .ascending)],
          limit: 5)

      self?.topLeftTableView.reloadData()
    }

    topRightViewModel.onItemsChanged.subscribe(with: self) { [weak self] (facetValues) in
      let refinementListPresenter = RefinementListPresenter()
      self?.topRightSortedFacetValues =
        refinementListPresenter.processFacetValues(
          selectedValues: Array(self?.topRightViewModel.selections ?? Set()),
          resultValues: facetValues,
          sortBy: [.alphabetical(order: .descending)],
          limit: 3)

      self?.topRightTableView.reloadData()
    }

    bottomLeftViewModel.onItemsChanged.subscribe(with: self) { [weak self] (facetValues) in
      let refinementListPresenter = RefinementListPresenter()
      self?.bottomLeftSortedFacetValues =
        refinementListPresenter.processFacetValues(
          selectedValues: Array(self?.bottomLeftViewModel.selections ?? Set()),
          resultValues: facetValues,
          sortBy: [.count(order: .descending)],
          limit: 5)

      self?.bottomLeftTableView.reloadData()
    }

    bottomRightViewModel.onItemsChanged.subscribe(with: self) { [weak self] (facetValues) in
      let refinementListPresenter = RefinementListPresenter()
      self?.bottomRightSortedFacetValues =
        refinementListPresenter.processFacetValues(
          selectedValues: Array(self?.bottomRightViewModel.selections ?? Set()),
          resultValues: facetValues,
          sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])

      self?.bottomRightTableView.reloadData()
    }
  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sortedFacetValues = getSortedFacetValues(for: tableView)
    return sortedFacetValues.count
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sortedFacetValues = getSortedFacetValues(for: tableView)
    let viewModel = getViewModel(for: tableView)
    viewModel?.selectItem(forKey: sortedFacetValues[indexPath.row].item.value)

    filterValueLabel.text = searcher.indexSearchData.filterState.toFilterGroups().compactMap({ $0 as? FilterGroupType & SQLSyntaxConvertible }).sqlForm.replacingOccurrences(of: "\"", with: "")
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let sortedFacetValues = getSortedFacetValues(for: tableView)
    let selectableRefinement: RefinementFacet = sortedFacetValues[indexPath.row]

    let facetAttributedString = NSMutableAttributedString(string: selectableRefinement.item.value)
    let facetCountStringColor = [NSAttributedString.Key.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 14)]
    let facetCountString = NSAttributedString(string: " (\(selectableRefinement.item.count))", attributes: facetCountStringColor)
    facetAttributedString.append(facetCountString)

    cell.textLabel?.attributedText = facetAttributedString

    cell.accessoryType = selectableRefinement.isSelected ? .checkmark : .none

    return cell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 3 * px16))
    let label = UILabel(frame: CGRect(x: 5, y: px16, width: tableView.frame.width, height: px16))
    label.font = .systemFont(ofSize: 12)
    label.numberOfLines = 2
    label.textAlignment = .center
    view.addSubview(label)
    view.backgroundColor = UIColor(hexString: "#f7f8fa")
    label.textColor = .gray
    switch tableView {
    case topLeftTableView:
      label.text = "And, IsRefined-AphaAsc, I=5"
      label.textColor = UIColor(hexString: "#ffcc0000")
    case topRightTableView:
      label.text = "And, Alphadesc, I=3"
      label.textColor = UIColor(hexString: "#ffcc0000")
    case bottomLeftTableView:
      label.text = "And, CountDesc, I=5"
      label.textColor = UIColor(hexString: "#ff669900")
    case bottomRightTableView:
      label.text = "Or, CountDesc-AlphaAsc, I=5"
      label.textColor = UIColor(hexString: "#ff0099cc")
    default:
      break
    }

    return view
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 3 * px16
  }

  func getSortedFacetValues(for tableView: UITableView) -> [RefinementFacet] {
    switch tableView {
    case topLeftTableView: return topLeftSortedFacetValues
    case topRightTableView: return topRightSortedFacetValues
    case bottomLeftTableView: return bottomLeftSortedFacetValues
    case bottomRightTableView: return bottomRightSortedFacetValues
    default:
      return []
    }
  }

  func getViewModel(for tableView: UITableView) -> RefinementFacetsViewModel? {
    switch tableView {
    case topLeftTableView: return topLeftViewModel
    case topRightTableView: return topRightViewModel
    case bottomLeftTableView: return bottomLeftViewModel
    case bottomRightTableView: return bottomRightViewModel
    default:
      return nil
    }
  }
}

extension RefinementsDemo {
  fileprivate func setupUI() {
    // Top Stack View

    let titleLabel = UILabel()
    titleLabel.font = .boldSystemFont(ofSize: 25)
    filterValueLabel = UILabel()
    filterValueLabel.font = .systemFont(ofSize: 16)
    filterValueLabel.numberOfLines = 0
    titleLabel.text = "Filters"

    let topFilterStringStackView   = UIStackView()
    topFilterStringStackView.axis  = .vertical
    topFilterStringStackView.spacing = 10
    topFilterStringStackView.layoutMargins = UIEdgeInsets(top: 8, left: 15, bottom: 20, right: 15)
    topFilterStringStackView.isLayoutMarginsRelativeArrangement = true
    topFilterStringStackView.distribution = .equalSpacing

    topFilterStringStackView.translatesAutoresizingMaskIntoConstraints = false

    topFilterStringStackView.addArrangedSubview(titleLabel)
    topFilterStringStackView.addArrangedSubview(filterValueLabel)


    let allTableViewsStackView = UIStackView()
    allTableViewsStackView.axis  = .vertical
    allTableViewsStackView.spacing = px16
    allTableViewsStackView.distribution = .fillEqually

    allTableViewsStackView.translatesAutoresizingMaskIntoConstraints = false

    let topTableViewsStackView = UIStackView()
    topTableViewsStackView.axis = .horizontal
    topTableViewsStackView.spacing = px16
    topTableViewsStackView.distribution = .fillEqually

    topTableViewsStackView.addArrangedSubview(topLeftTableView)
    topTableViewsStackView.addArrangedSubview(topRightTableView)

    let bottomTableViewsStackView = UIStackView()
    bottomTableViewsStackView.axis = .horizontal
    bottomTableViewsStackView.spacing = px16
    bottomTableViewsStackView.distribution = .fillEqually

    bottomTableViewsStackView.addArrangedSubview(bottomLeftTableView)
    bottomTableViewsStackView.addArrangedSubview(bottomRightTableView)


    allTableViewsStackView.addArrangedSubview(topTableViewsStackView)
    allTableViewsStackView.addArrangedSubview(bottomTableViewsStackView)


    view.addSubview(topFilterStringStackView)
    view.addSubview(allTableViewsStackView)



    topFilterStringStackView.addBackground(color: .white)

    topFilterStringStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: px16).isActive = true
    topFilterStringStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -px16).isActive = true
    topFilterStringStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    topFilterStringStackView.heightAnchor.constraint(equalToConstant: 150).isActive = true

    topFilterStringStackView.bottomAnchor.constraint(equalTo: allTableViewsStackView.topAnchor, constant: 0).isActive = true

    allTableViewsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: px16).isActive = true
    allTableViewsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -px16).isActive = true
    allTableViewsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true

    allTableViews.append(contentsOf: [topLeftTableView, topRightTableView, bottomLeftTableView, bottomRightTableView])

    allTableViews.forEach {
      $0.delegate = self
      $0.dataSource = self
      $0.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
      $0.alwaysBounceVertical = false
      $0.tableFooterView = UIView(frame: .zero)
      $0.backgroundColor =  UIColor(hexString: "#f7f8fa")
    }
  }
}
