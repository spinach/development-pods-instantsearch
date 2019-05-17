//
//  RefinementListDemo.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 03/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

extension CGFloat {
  static let px16: CGFloat = 16
}

//TODO: FilterFormatter / Presenter


class RefinementListDemo: UIViewController {
  
  var colorAViewModel: SelectableFacetsViewModel!
  var colorBViewModel: SelectableFacetsViewModel!
  var categoryViewModel: SelectableFacetsViewModel!
  var promotionViewModel: SelectableFacetsViewModel!

  var filterListViewModel: FilterListViewModel.Numeric!

  let colorAttribute = Attribute("color")
  let promotionAttribute = Attribute("promotions")
  let categoryAttribute = Attribute("category")
  
  let topLeftTableView = UITableView()
  let topRightTableView = UITableView()
  let bottomLeftTableView = UITableView()
  let bottomRightTableView = UITableView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()

    let facetFilters: [Filter.Facet] = [
      .init(attribute: "f1", stringValue: "v1"),
      .init(attribute: "f2", stringValue: "v2"),
      .init(attribute: "f3", stringValue: "v3"),
    ]
    
    let numericFilters: [Filter.Numeric] = [
      .init(attribute: "size", range: 32...42),
      .init(attribute: "price", operator: .greaterThan, value: 100),
      .init(attribute: "count", operator: .equals, value: 20),
    ]
    
    let tags = (0...5).map { Filter.Tag(value: "Tag \($0)") }
    
    filterListViewModel = FilterListViewModel.Numeric(items: numericFilters)
    let presenter: FilterPresenter = { filter in
      switch filter {
      case .numeric(let numericFilter):
        switch numericFilter.value {
        case .range(let range):
          return "\(range.lowerBound) – \(range.upperBound)"
          
        case .comparison(let op, let val):
          return "\(op.description) \(val)"
        }
      default:
        return ""
      }
    }
    let tagListController = FilterListTableController<Filter.Numeric>(tableView: topLeftTableView)
    tagListController.filterFormatter = presenter
    filterListViewModel.connectController(tagListController)
    
    // Top Left - Color A
//    colorAViewModel = RefinementFacetsViewModel(selectionMode: .single)
//    let colorAPresenter = RefinementFacetsPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)], limit: 5)
//    let colorATitleDescriptor = TitleDescriptor(text: "And, IsRefined-AlphaAsc, I=5", color: .init(hexString: "#ffcc0000"))
//    let colorAController = FacetsController(tableView: topLeftTableView, titleDescriptor: colorATitleDescriptor)
//    colorAViewModel.connectController(colorAController, with: colorAPresenter)
    
    
    // Top right - Color B
    colorBViewModel = FacetListViewModel(selectionMode: .single)
    let colorBPresenter = FacetListPresenter(sortBy: [.alphabetical(order: .descending)], limit: 3)
    let colorBTitleDescriptor = TitleDescriptor(text: "And, AlphaDesc, I=3", color: .init(hexString: "#ffcc0000"))
    let colorBController = FacetListTableController(tableView: topRightTableView, titleDescriptor: colorBTitleDescriptor)
    colorBViewModel.connectController(colorBController, with: colorBPresenter)
    
    // Bottom Left - Promotion
    promotionViewModel = FacetListViewModel()
    let promotionPresenter = FacetListPresenter(sortBy: [.count(order: .descending)], limit: 5)
    let promotionTitleDescriptor = TitleDescriptor(text: "And, CountDesc, I=5", color: .init(hexString: "#ff669900"))
    let promotionController = FacetListTableController(tableView: bottomLeftTableView, titleDescriptor: promotionTitleDescriptor)
    promotionViewModel.connectController(promotionController, with: promotionPresenter)
    
    // Bottom Right - Category
    categoryViewModel = FacetListViewModel()
    let categoryRefinementListPresenter = FacetListPresenter(sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])
    let categoryTitleDescriptor = TitleDescriptor(text: "Or, CountDesc-AlphaAsc, I=5", color: .init(hexString: "#ff0099cc"))
    let categoryController = FacetListTableController(tableView: bottomRightTableView, titleDescriptor: categoryTitleDescriptor)
    categoryViewModel.connectController(categoryController, with: categoryRefinementListPresenter)

  }

}

extension RefinementListDemo: SearcherPluggable {
  
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>) {
    
    // predefined filter
    let greenColor = Filter.Facet(attribute: colorAttribute, stringValue: "green")
    let groupID = FilterGroup.ID.and(name: colorAttribute.name)
    searcher.filterState.notify(.add(filter: greenColor, toGroupWithID: groupID))
    
    filterListViewModel.connectFilterState(searcher.filterState, operator: .or)
//    colorAViewModel.connectSearcher(searcher, with: colorAttribute)
    colorBViewModel.connectSearcher(searcher, with: colorAttribute)
    promotionViewModel.connectSearcher(searcher, with: promotionAttribute)
    categoryViewModel.connectSearcher(searcher, with: categoryAttribute)

//    colorAViewModel.connectFilterState(searcher.indexSearchData.filterState, with: colorAttribute, operator: .and)
    colorBViewModel.connectFilterState(searcher.indexSearchData.filterState, with: colorAttribute, operator: .and)
    promotionViewModel.connectFilterState(searcher.indexSearchData.filterState, with: promotionAttribute, operator: .and)
    categoryViewModel.connectFilterState(searcher.indexSearchData.filterState, with: categoryAttribute, operator: .or)

  }
  
}

extension RefinementListDemo {
  
  func setupUI() {
    
    let mainStackView = UIStackView()
    mainStackView.axis = .vertical
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.spacing = 5
    
    let gridStackView = UIStackView()
    gridStackView.axis = .vertical
    gridStackView.spacing = .px16
    gridStackView.distribution = .fillEqually
    
    gridStackView.translatesAutoresizingMaskIntoConstraints = false
    
    let firstRow = UIStackView()
    firstRow.axis = .horizontal
    firstRow.spacing = .px16
    firstRow.distribution = .fillEqually
    
    firstRow.addArrangedSubview(topLeftTableView)
    firstRow.addArrangedSubview(topRightTableView)
    
    let secondRowStackView = UIStackView()
    secondRowStackView.axis = .horizontal
    secondRowStackView.spacing = .px16
    secondRowStackView.distribution = .fillEqually
    
    secondRowStackView.addArrangedSubview(bottomLeftTableView)
    secondRowStackView.addArrangedSubview(bottomRightTableView)
    
    gridStackView.addArrangedSubview(firstRow)
    gridStackView.addArrangedSubview(secondRowStackView)
    
    mainStackView.addArrangedSubview(gridStackView)
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    [topLeftTableView, topRightTableView, bottomLeftTableView, bottomRightTableView].forEach {
      $0.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
      $0.alwaysBounceVertical = false
      $0.tableFooterView = UIView(frame: .zero)
      $0.backgroundColor = UIColor(hexString: "#f7f8fa")
    }
    
    gridStackView.addBackground(color: .white)
    
  }
  
}
