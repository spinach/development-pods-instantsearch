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

class RefinementListDemo: UIViewController {
  
  var colorAViewModel: SelectableFacetsViewModel!
  var colorBViewModel: SelectableFacetsViewModel!
  var categoryViewModel: SelectableFacetsViewModel!
  var promotionViewModel: SelectableFacetsViewModel!

  var tagListViewModel: FilterListViewModel.Tag!

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

    tagListViewModel = FilterListViewModel.Tag.init(items: [Filter.Tag(value: "tag 1"),Filter.Tag(value: "tag 1")])
    
    // Top Left - Color A
    colorAViewModel = RefinementFacetsViewModel(selectionMode: .single)
    let colorAPresenter = RefinementFacetsPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)], limit: 5)
    let colorATitleDescriptor = TitleDescriptor(text: "And, IsRefined-AlphaAsc, I=5", color: .init(hexString: "#ffcc0000"))
    let colorAController = FacetsController(tableView: topLeftTableView, titleDescriptor: colorATitleDescriptor)
    colorAViewModel.connectController(colorAController, with: colorAPresenter)
    
    
    // Top right - Color B
    colorBViewModel = RefinementFacetsViewModel(selectionMode: .single)
    let colorBPresenter = RefinementFacetsPresenter(sortBy: [.alphabetical(order: .descending)], limit: 3)
    let colorBTitleDescriptor = TitleDescriptor(text: "And, AlphaDesc, I=3", color: .init(hexString: "#ffcc0000"))
    let colorBController = FacetsController(tableView: topRightTableView, titleDescriptor: colorBTitleDescriptor)
    colorBViewModel.connectController(colorBController, with: colorBPresenter)
    
    // Bottom Left - Promotion
    promotionViewModel = RefinementFacetsViewModel()
    let promotionPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending)], limit: 5)
    let promotionTitleDescriptor = TitleDescriptor(text: "And, CountDesc, I=5", color: .init(hexString: "#ff669900"))
    let promotionController = FacetsController(tableView: bottomLeftTableView, titleDescriptor: promotionTitleDescriptor)
    promotionViewModel.connectController(promotionController, with: promotionPresenter)
    
    // Bottom Right - Category TODO: rename it
    categoryViewModel = RefinementFacetsViewModel()
    let categoryRefinementListPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])
    let categoryTitleDescriptor = TitleDescriptor(text: "Or, CountDesc-AlphaAsc, I=5", color: .init(hexString: "#ff0099cc"))
    let categoryController = FacetsController(tableView: bottomRightTableView, titleDescriptor: categoryTitleDescriptor)
    categoryViewModel.connectController(categoryController, with: categoryRefinementListPresenter)

  }

}

extension RefinementListDemo: SearcherPluggable {
  
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>) {
    
    // predefined filter
    searcher.indexSearchData.filterState.notify { (filterState) in
      filterState.add(Filter.Facet(attribute: colorAttribute, stringValue: "green"), toGroupWithID: FilterGroup.ID.and(name: colorAttribute.name))
    }
    
    colorAViewModel.connectSearcher(searcher, with: colorAttribute)
    colorBViewModel.connectSearcher(searcher, with: colorAttribute)
    promotionViewModel.connectSearcher(searcher, with: promotionAttribute)
    categoryViewModel.connectSearcher(searcher, with: categoryAttribute)

    colorAViewModel.connectFilterState(searcher.indexSearchData.filterState, with: colorAttribute, operator: .and)
    colorBViewModel.connectFilterState(searcher.indexSearchData.filterState, with: colorAttribute, operator: .and)
    promotionViewModel.connectFilterState(searcher.indexSearchData.filterState, with: promotionAttribute, operator: .and)
    categoryViewModel.connectFilterState(searcher.indexSearchData.filterState, with: categoryAttribute, operator: .or)


    tagListViewModel.connectFilterState(searcher.indexSearchData.filterState)
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
