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

class RefinementsDemo: UIViewController {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "mobile_demo_refinement_facet"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  var colorAViewModel: SelectableFacetsViewModel!
  var colorBViewModel: SelectableFacetsViewModel!
  var bottomRightViewModel: SelectableFacetsViewModel!
  var promotionViewModel: SelectableFacetsViewModel!

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


    // Top Left - Color A
    colorAViewModel = MenuFacetsViewModel()
    let colorAPresenter =
      RefinementFacetsPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)],
                                limit: 5)
    let colorAController = FacetsController(tableView: topLeftTableView, identifier: "topLeft")
    colorAViewModel.connectController(colorAController, with: colorAPresenter)
    colorAViewModel.connectSearcher(searcher, with: Attribute("color"), operator: .and)

    // Top right - Color B
    colorBViewModel = MenuFacetsViewModel()
    let colorBPresenter = RefinementFacetsPresenter(sortBy: [.alphabetical(order: .descending)],
                                                                    limit: 3)
    let colorBController = FacetsController(tableView: topRightTableView, identifier: "topRight")
    colorBViewModel.connectController(colorBController, with: colorBPresenter)
    colorBViewModel.connectSearcher(searcher, with: Attribute("color"), operator: .and)

    // Bottom Left - Promotion
    promotionViewModel = RefinementFacetsViewModel()
    let promotionPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending)],
                                                                      limit: 5)
    let promotionController = FacetsController(tableView: bottomLeftTableView, identifier: "bottomLeft")
    promotionViewModel.connectController(promotionController, with: promotionPresenter)
    promotionViewModel.connectSearcher(searcher, with: Attribute("promotion"), operator: .and)

    // Bottom Right - Category
    bottomRightViewModel = RefinementFacetsViewModel()
    let categoryRefinementListPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])
    let categoryController = FacetsController(tableView: bottomRightTableView, identifier: "bottomRight")
    bottomRightViewModel.connectController(categoryController, with: categoryRefinementListPresenter)
    bottomRightViewModel.connectSearcher(searcher, with: Attribute("category"), operator: .or)

    searcher.indexSearchData.filterState.onChange.subscribe(with: self) { filterState in
      self.filterValueLabel.text = self.searcher.indexSearchData.filterState.toFilterGroups().compactMap({ $0 as? FilterGroupType & SQLSyntaxConvertible }).sqlForm.replacingOccurrences(of: "\"", with: "")

      // TODO: Should be able to do this, but Getting FilterReadable error due to api protection.
      //filterValueLabel.text = filterState.toFilterGroups().compactMap({ $0 as? FilterGroupType & SQLSyntaxConvertible }).sqlForm.replacingOccurrences(of: "\"", with: "")
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
      $0.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
      $0.alwaysBounceVertical = false
      $0.tableFooterView = UIView(frame: .zero)
      $0.backgroundColor =  UIColor(hexString: "#f7f8fa")
    }
  }
}

//extension UITableView: RefinementFacetsView {
//  public func setSelectableItems(selectableItems: [(item: SelectableItem<FacetValue>, isSelected: Bool)]) {
//
//  }
//
//  public func onClickItem(onClick: (SelectableItem<FacetValue>) -> Void) {
//
//  }
//
//  public func reload() {
//
//  }
//
//
//}
