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

  let colorAttribute = Attribute("color")
  let promotionAttribute = Attribute("promotion")
  let categoryAttribute = Attribute("category")

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

    searcher.indexSearchData.filterState.onChange.subscribe(with: self) { filterState in
      // TODO: Fix the "FilterGroupType & SQLSyntaxConvertible" problem
      //      self.filterValueLabel.text = self.searcher.indexSearchData.filterState.toFilterGroups().compactMap({ $0 as? FilterGroupType & SQLSyntaxConvertible }).sqlForm.replacingOccurrences(of: "\"", with: "")

      self.filterValueLabel.attributedText = self.searcher.indexSearchData.filterState.toFilterGroups().compactMap({ $0 as? FilterGroupType & SQLSyntaxConvertible }).sqlFormWithSyntaxHighlighting(
        colorMap: [
          self.colorAttribute.name: .red,
          self.promotionAttribute.name: .blue,
          self.categoryAttribute.name: .green
        ])
    }

    // Top Left - Color A
    colorAViewModel = RefinementFacetsViewModel(selectionMode: .single)
    let colorAPresenter =
      RefinementFacetsPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)],
                                limit: 5)
    let colorAController = FacetsController(tableView: topLeftTableView, identifier: "topLeft")
    colorAViewModel.connectController(colorAController, with: colorAPresenter)
    colorAViewModel.connectSearcher(searcher, with: colorAttribute, operator: .and)

    // Top right - Color B
    colorBViewModel = RefinementFacetsViewModel(selectionMode: .single)
    let colorBPresenter = RefinementFacetsPresenter(sortBy: [.alphabetical(order: .descending)],
                                                    limit: 3)
    let colorBController = FacetsController(tableView: topRightTableView, identifier: "topRight")
    colorBViewModel.connectController(colorBController, with: colorBPresenter)
    colorBViewModel.connectSearcher(searcher, with: colorAttribute, operator: .and)

    // Bottom Left - Promotion
    promotionViewModel = RefinementFacetsViewModel()
    let promotionPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending)],
                                                       limit: 5)
    let promotionController = FacetsController(tableView: bottomLeftTableView, identifier: "bottomLeft")
    promotionViewModel.connectController(promotionController, with: promotionPresenter)
    promotionViewModel.connectSearcher(searcher, with: promotionAttribute, operator: .and)

    // Bottom Right - Category
    bottomRightViewModel = RefinementFacetsViewModel()
    let categoryRefinementListPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])
    let categoryController = FacetsController(tableView: bottomRightTableView, identifier: "bottomRight")
    bottomRightViewModel.connectController(categoryController, with: categoryRefinementListPresenter)
    bottomRightViewModel.connectSearcher(searcher, with: categoryAttribute, operator: .or)

    // predefined filter
    filterState.notify { (filterState) in
      filterState.add(Filter.Facet(attribute: colorAttribute, stringValue: "green"), toGroupWithID: FilterGroup.ID.and(name: colorAttribute.name))
    }

    searcher.search()

    searcher.onResultsChanged.subscribe(with: self) { (queryMetadata, result) in
      switch result {
      case .failure:
        self.filterValueLabel.text = "Network error"
      default:
        break
      }

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

    // clear button
    let clearButton = UIButton(type: .custom)
    clearButton.setTitleColor(.black, for: .normal)
    clearButton.setTitle("Clear", for: .normal)
    clearButton.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(clearButton)

    clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    clearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25).isActive = true
    clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
  }

  @objc func clearButtonTapped() {
    filterState.notify { (filterState) in
      filterState.removeAll()
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

extension Collection where Element == FilterGroupType & SQLSyntaxConvertible {


  public func sqlFormWithSyntaxHighlighting(colorMap: [String: UIColor]) -> NSAttributedString {
    return map { element in
      var color: UIColor = .darkText
      if let groupName = element.name, let specifiedColor = colorMap[groupName] {
        color = specifiedColor
      }

      return NSMutableAttributedString()
        .appendWith(color: color, weight: .regular, ofSize: 18.0, element.sqlForm.replacingOccurrences(of: "\"", with: ""))
      }.joined(separator: NSMutableAttributedString()
        .appendWith(weight: .semibold, ofSize: 18.0, " AND "))
  }

}

extension NSMutableAttributedString {

  @discardableResult func appendWith(color: UIColor = UIColor.darkText, weight: UIFont.Weight = .regular, ofSize: CGFloat = 12.0, _ text: String) -> NSMutableAttributedString{
    let attrText = NSAttributedString.makeWith(color: color, weight: weight, ofSize:ofSize, text)
    self.append(attrText)
    return self
  }

}
extension NSAttributedString {

  public static func makeWith(color: UIColor = UIColor.darkText, weight: UIFont.Weight = .regular, ofSize: CGFloat = 12.0, _ text: String) -> NSMutableAttributedString {

    let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: ofSize, weight: weight), NSAttributedString.Key.foregroundColor: color]
    return NSMutableAttributedString(string: text, attributes:attrs)
  }
}

extension Sequence where Iterator.Element: NSAttributedString {
  /// Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
  /// - parameters:
  ///     - separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
  func joined(separator: NSAttributedString = NSAttributedString(string: "")) -> NSAttributedString {
    var isFirst = true
    return self.reduce(NSMutableAttributedString()) {
      (r, e) in
      if isFirst {
        isFirst = false
      } else {
        r.append(separator)
      }
      r.append(e)
      return r
    }
  }

  /// Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
  /// - parameters:
  ///     - separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
  func joined(separator: String = "") -> NSAttributedString {
    return joined(separator: NSAttributedString(string: separator))
  }
}
