//
//  RefinementListDemoViewController.swift
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

class RefinementListDemoViewController: UIViewController {
  
  let searcher: SingleIndexSearcher
  var colorAViewModel: SelectableFacetsViewModel!
  var colorBViewModel: SelectableFacetsViewModel!
  var categoryViewModel: SelectableFacetsViewModel!
  var promotionViewModel: SelectableFacetsViewModel!

  let searchStateViewController: SearchStateViewController

  let colorAttribute = Attribute("color")
  let promotionAttribute = Attribute("promotions")
  let categoryAttribute = Attribute("category")
  
  let topLeftTableView = UITableView()
  let topRightTableView = UITableView()
  let bottomLeftTableView = UITableView()
  let bottomRightTableView = UITableView()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    searcher = SingleIndexSearcher(index: .demo(withName:"mobile_demo_facet_list"))
    searchStateViewController = SearchStateViewController()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()

    // Top Left - Color A
    colorAViewModel = FacetListViewModel(selectionMode: .single)
    let colorAPresenter = FacetListPresenter(sortBy: [.isRefined, .alphabetical(order: .ascending)], limit: 5)
    let colorATitleDescriptor = TitleDescriptor(text: "And, IsRefined-AlphaAsc, I=5", color: .init(hexString: "#ffcc0000"))
    let colorAController = FacetListTableController(tableView: topLeftTableView, titleDescriptor: colorATitleDescriptor)
    colorAViewModel.connect(to: colorAController, with: colorAPresenter)
    
    // Top right - Color B
    colorBViewModel = FacetListViewModel(selectionMode: .single)
    let colorBPresenter = FacetListPresenter(sortBy: [.alphabetical(order: .descending)], limit: 3)
    let colorBTitleDescriptor = TitleDescriptor(text: "And, AlphaDesc, I=3", color: .init(hexString: "#ffcc0000"))
    let colorBController = FacetListTableController(tableView: topRightTableView, titleDescriptor: colorBTitleDescriptor)
    colorBViewModel.connect(to: colorBController, with: colorBPresenter)
    
    // Bottom Left - Promotion
    promotionViewModel = FacetListViewModel()
    let promotionPresenter = FacetListPresenter(sortBy: [.count(order: .descending)], limit: 5)
    let promotionTitleDescriptor = TitleDescriptor(text: "And, CountDesc, I=5", color: .init(hexString: "#ff669900"))
    let promotionController = FacetListTableController(tableView: bottomLeftTableView, titleDescriptor: promotionTitleDescriptor)
    promotionViewModel.connect(to: promotionController, with: promotionPresenter)
    
    // Bottom Right - Category
    categoryViewModel = FacetListViewModel()
    let categoryRefinementListPresenter = FacetListPresenter(sortBy: [.count(order: .descending), .alphabetical(order: .ascending)])
    let categoryTitleDescriptor = TitleDescriptor(text: "Or, CountDesc-AlphaAsc, I=5", color: .init(hexString: "#ff0099cc"))
    let categoryController = FacetListTableController(tableView: bottomRightTableView, titleDescriptor: categoryTitleDescriptor)
    categoryViewModel.connect(to: categoryController, with: categoryRefinementListPresenter)

    setup()

  }

}

private extension RefinementListDemoViewController {
  
  func setup() {
    // predefined filter
    let greenColor = Filter.Facet(attribute: colorAttribute, stringValue: "green")
    let groupID = FilterGroup.ID.and(name: colorAttribute.name)
    searcher.filterState.notify(.add(filter: greenColor, toGroupWithID: groupID))
    
    colorAViewModel.connectSearcher(searcher, with: colorAttribute)
    colorBViewModel.connectSearcher(searcher, with: colorAttribute)
    promotionViewModel.connectSearcher(searcher, with: promotionAttribute)
    categoryViewModel.connectSearcher(searcher, with: categoryAttribute)
    
    let filterState = searcher.filterState
    
    colorAViewModel.connectFilterState(filterState, with: colorAttribute, operator: .and)
    colorBViewModel.connectFilterState(filterState, with: colorAttribute, operator: .and)
    promotionViewModel.connectFilterState(filterState, with: promotionAttribute, operator: .and)
    categoryViewModel.connectFilterState(filterState, with: categoryAttribute, operator: .or)
    
    searchStateViewController.connectSearcher(searcher)
    
    searcher.search()
  }
  
}

extension RefinementListDemoViewController {
  
  func setupUI() {
    
    view.backgroundColor = .white
    
    let mainStackView = UIStackView()
    mainStackView.axis = .vertical
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.spacing = .px16
    
    addChild(searchStateViewController)
    searchStateViewController.didMove(toParent: self)
    searchStateViewController.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    mainStackView.addArrangedSubview(searchStateViewController.view)
    
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
