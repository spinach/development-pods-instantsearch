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

protocol SearcherPluggable {
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>)
}

extension CGFloat {
  static let px16: CGFloat = 16
}

class RefinementListDemo: UIViewController {
  
  var colorAViewModel: SelectableFacetsViewModel!
  var colorBViewModel: SelectableFacetsViewModel!
  var bottomRightViewModel: SelectableFacetsViewModel!
  var promotionViewModel: SelectableFacetsViewModel!

  let colorAttribute = Attribute("color")
  let promotionAttribute = Attribute("promotions")
  let categoryAttribute = Attribute("category")
  
  var topLeftSortedFacetValues: [RefinementFacet] = []
  var topRightSortedFacetValues: [RefinementFacet] = []
  var bottomLeftSortedFacetValues: [RefinementFacet] = []
  var bottomRightSortedFacetValues: [RefinementFacet] = []
  
  let topLeftTableView = UITableView()
  let topRightTableView = UITableView()
  let bottomLeftTableView = UITableView()
  let bottomRightTableView = UITableView()
  var allTableViews: [UITableView] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    // Top Left - Color A
    colorAViewModel = RefinementFacetsViewModel(selectionMode: .single)
    let colorAPresenter =
      RefinementFacetsPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)],
                                limit: 5)
    
    let colorATitleDescriptor = TitleDescriptor(text: "And, IsRefined-AlphaAsc, I=5", color: UIColor(hexString: "#ffcc0000"))
    let colorAController = FacetsController(tableView: topLeftTableView, titleDescriptor: colorATitleDescriptor)
    colorAViewModel.connectController(colorAController, with: colorAPresenter)
    
    // Top right - Color B
    colorBViewModel = RefinementFacetsViewModel(selectionMode: .single)
    let colorBPresenter = RefinementFacetsPresenter(sortBy: [.alphabetical(order: .descending)],
                                                    limit: 3)
    let colorBTitleDescriptor = TitleDescriptor(text: "And, AlphaDesc, I=3", color: UIColor(hexString: "#ffcc0000"))
    let colorBController = FacetsController(tableView: topRightTableView, titleDescriptor: colorBTitleDescriptor)
    colorBViewModel.connectController(colorBController, with: colorBPresenter)
    
    // Bottom Left - Promotion
    promotionViewModel = RefinementFacetsViewModel()
    let promotionPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending)],
                                                       limit: 5)
    
    let promotionTitleDescriptor = TitleDescriptor(text: "And, CountDesc, I=5", color: UIColor(hexString: "#ff669900"))
    let promotionController = FacetsController(tableView: bottomLeftTableView, titleDescriptor: promotionTitleDescriptor)
    promotionViewModel.connectController(promotionController, with: promotionPresenter)
    
    // Bottom Right - Category
    bottomRightViewModel = RefinementFacetsViewModel()
    let categoryRefinementListPresenter = RefinementFacetsPresenter(sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])
    
    let categoryTitleDescriptor = TitleDescriptor(text: "Or, CountDesc-AlphaAsc, I=5", color: UIColor(hexString: "#ff0099cc"))
    let categoryController = FacetsController(tableView: bottomRightTableView, titleDescriptor: categoryTitleDescriptor)
    bottomRightViewModel.connectController(categoryController, with: categoryRefinementListPresenter)

  }

}

extension RefinementListDemo: SearcherPluggable {
  
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>) {
    
    // predefined filter
    searcher.indexSearchData.filterState.notify { (filterState) in
      filterState.add(Filter.Facet(attribute: colorAttribute, stringValue: "green"), toGroupWithID: FilterGroup.ID.and(name: colorAttribute.name))
    }
    
    colorAViewModel.connectSearcher(searcher, with: colorAttribute, operator: .and)
    colorBViewModel.connectSearcher(searcher, with: colorAttribute, operator: .and)
    promotionViewModel.connectSearcher(searcher, with: promotionAttribute, operator: .and)
    bottomRightViewModel.connectSearcher(searcher, with: categoryAttribute, operator: .or)
  }
  
}

extension RefinementListDemo {
  
  func setupUI() {
    
    let allTableViewsStackView = UIStackView()
    allTableViewsStackView.axis  = .vertical
    allTableViewsStackView.spacing = .px16
    allTableViewsStackView.distribution = .fillEqually
    
    allTableViewsStackView.translatesAutoresizingMaskIntoConstraints = false
    
    let topTableViewsStackView = UIStackView()
    topTableViewsStackView.axis = .horizontal
    topTableViewsStackView.spacing = .px16
    topTableViewsStackView.distribution = .fillEqually
    
    topTableViewsStackView.addArrangedSubview(topLeftTableView)
    topTableViewsStackView.addArrangedSubview(topRightTableView)
    
    let bottomTableViewsStackView = UIStackView()
    bottomTableViewsStackView.axis = .horizontal
    bottomTableViewsStackView.spacing = .px16
    bottomTableViewsStackView.distribution = .fillEqually
    
    bottomTableViewsStackView.addArrangedSubview(bottomLeftTableView)
    bottomTableViewsStackView.addArrangedSubview(bottomRightTableView)
    
    allTableViewsStackView.addArrangedSubview(topTableViewsStackView)
    allTableViewsStackView.addArrangedSubview(bottomTableViewsStackView)
    
    view.addSubview(allTableViewsStackView)
    
    NSLayoutConstraint.activate([
      allTableViewsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      allTableViewsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      allTableViewsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      allTableViewsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])

    allTableViews.append(contentsOf: [topLeftTableView, topRightTableView, bottomLeftTableView, bottomRightTableView])
    
    allTableViews.forEach {
      $0.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
      $0.alwaysBounceVertical = false
      $0.tableFooterView = UIView(frame: .zero)
      $0.backgroundColor =  UIColor(hexString: "#f7f8fa")
    }
    
    allTableViewsStackView.addBackground(color: .white)
    
  }
  
}
