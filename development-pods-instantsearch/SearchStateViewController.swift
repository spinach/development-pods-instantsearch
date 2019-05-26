//
//  SearchStateViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 24/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import InstantSearchCore

class SearchStateViewController: UIViewController {
  
  let mainStackView: UIStackView
  let titleLabel: UILabel
  let hitsCountLabel: UILabel
  let activityIndicator: UIActivityIndicatorView
  let filterStateViewController: FilterStateViewController
  let clearRefinementsButton: UIButton
  let loadableController: ActivityIndicatorController
  let statsController: StatsController
  let clearRefinementsController: ClearRefinementsController
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.mainStackView = UIStackView(frame: .zero)
    self.titleLabel = UILabel(frame: .zero)
    self.hitsCountLabel = UILabel(frame: .zero)
    self.activityIndicator = UIActivityIndicatorView(frame: .zero)
    self.filterStateViewController = FilterStateViewController()
    self.clearRefinementsButton = UIButton(frame: .zero)
    self.loadableController = ActivityIndicatorController(activityIndicator: activityIndicator)
    self.statsController = LabelStatsController(label: hitsCountLabel)
    self.clearRefinementsController = ClearRefinementsButtonController(button: clearRefinementsButton)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    configureMainStackView()
    configureTitleLabel()
    configureClearRefinementsButton()
    configureFilterStateViewController()
    configureHitsCountLabel()
    configureActivityIndicator()
    configureLayout()
  }
  
  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = 4
    mainStackView.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    mainStackView.isLayoutMarginsRelativeArrangement = true
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.addBackground(color: .white)
    mainStackView.alignment = .leading
    mainStackView.subviews.first.flatMap {
      $0.layer.borderWidth = 0.5
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.masksToBounds = true
      $0.layer.cornerRadius = 10
    }
  }
  
  func configureTitleLabel() {
    titleLabel.font = .boldSystemFont(ofSize: 25)
    titleLabel.text = "Filters"
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureHitsCountLabel() {
    hitsCountLabel.textColor = .black
    hitsCountLabel.font = .systemFont(ofSize: 12)
    hitsCountLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureActivityIndicator() {
    activityIndicator.style = .gray
    activityIndicator.hidesWhenStopped = true
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureClearRefinementsButton() {
    clearRefinementsButton.setImage(UIImage(named: "trash"), for: .normal)
    clearRefinementsButton.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureFilterStateViewController() {
    filterStateViewController.colorMap = [
      "_tags": UIColor(hexString: "#9673b4"),
      "size": UIColor(hexString: "#698c28"),
      "color": .red,
      "promotions": .blue,
      "category": .green
    ]
  }
  
  func configureLayout() {
    
    view.addSubview(mainStackView)

    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
    ])
    
    let topStackView = UIStackView(frame: .zero)
    topStackView.translatesAutoresizingMaskIntoConstraints = false
    topStackView.axis = .horizontal
    topStackView.distribution = .fill
    
    topStackView.addArrangedSubview(titleLabel)
    let view = UIView()
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    topStackView.addArrangedSubview(view)
    topStackView.addArrangedSubview(clearRefinementsButton)
    
    mainStackView.addArrangedSubview(topStackView)
    topStackView.leadingAnchor.constraint(equalTo: mainStackView.layoutMarginsGuide.leadingAnchor).isActive = true
    topStackView.trailingAnchor.constraint(equalTo: mainStackView.layoutMarginsGuide.trailingAnchor).isActive = true

    addChild(filterStateViewController)
    filterStateViewController.didMove(toParent: self)
    
    mainStackView.addArrangedSubview(filterStateViewController.stateLabel)
    
    let bottomStackView = UIStackView(frame: .zero)
    bottomStackView.translatesAutoresizingMaskIntoConstraints = false
    bottomStackView.axis = .horizontal
    bottomStackView.distribution = .fill
    
    bottomStackView.addArrangedSubview(hitsCountLabel)
    let view2 = UIView()
    view2.setContentHuggingPriority(.defaultLow, for: .horizontal)
    bottomStackView.addArrangedSubview(view2)
    bottomStackView.addArrangedSubview(activityIndicator)
    
    mainStackView.addArrangedSubview(bottomStackView)
    bottomStackView.leadingAnchor.constraint(equalTo: mainStackView.layoutMarginsGuide.leadingAnchor).isActive = true
    bottomStackView.trailingAnchor.constraint(equalTo: mainStackView.layoutMarginsGuide.trailingAnchor).isActive = true
    
    
  }
  
}

extension SearchStateViewController {
  
  func connectTo(_ filterState: FilterState) {
    filterStateViewController.connectTo(filterState)
    clearRefinementsController.connectTo(filterState)
  }
  
  func connectTo<R>(_ searcher: SingleIndexSearcher<R>) where R : Decodable, R : Encodable {
    loadableController.connectTo(searcher)
    statsController.connectTo(searcher)
    searcher.onResultsChanged.subscribe(with: self) { (queryMetadata, result) in
      switch result {
      case .failure:
        self.filterStateViewController.stateLabel.text = "Network error"
      case .success(let results):
        self.hitsCountLabel.text = "hits: \(results.totalHitsCount)"
      }
    }
    
    connectTo(searcher.filterState)
  }
  
  func connectTo(_ facetSearcher: FacetSearcher) {
    loadableController.connectTo(facetSearcher)
  }
  
}