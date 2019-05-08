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

protocol SearcherPluggable {
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>)
}

class RefinementsDemo: UIViewController {

  let colorAttribute = Attribute("color")
  let promotionsAttribute = Attribute("promotions")
  let categoryAttribute = Attribute("category")

  var searcher: SingleIndexSearcher<JSON>!
  var searcherSFFV: FacetSearcher!
  var client: Client!
  var index: Index!
  var filterState: FilterState = FilterState()
  var query: Query = Query()
  
  var demo: DemoDescriptor = .toggle

  let mainStackView = UIStackView()
  let headerStackView = UIStackView()
  let titleLabel = UILabel()
  let filterValueLabel = UILabel()
  let hitsCountLabel = UILabel()
  let clearButton = UIButton(type: .custom)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor =  UIColor(hexString: "#f7f8fa")
    
    client = Client(appID: demo.appID, apiKey: demo.apiKey)
    index = client.index(withName: demo.indexName)
    searcher = SingleIndexSearcher(index: index, query: query, filterState: filterState)
    
    setupUI()

    searcher.indexSearchData.filterState.onChange.subscribe(with: self) { filterState in
      self.filterValueLabel.attributedText = self.searcher.indexSearchData.filterState.toFilterGroups().compactMap({ $0 as? FilterGroupType & SQLSyntaxConvertible }).sqlFormWithSyntaxHighlighting(
        colorMap: [
          "_tags": UIColor(hexString: "#9673b4"),
          "size": UIColor(hexString: "#698c28"),
          self.colorAttribute.name: .red,
          self.promotionsAttribute.name: .blue,
          self.categoryAttribute.name: .green
        ])
    }
    
    searcher.search()

    searcher.onResultsChanged.subscribe(with: self) { (queryMetadata, result) in
      switch result {
      case .failure:
        self.filterValueLabel.text = "Network error"
      case .success(let results):
        self.hitsCountLabel.text = "hits: \(results.totalHitsCount)"
      }

    }
  }
}

extension RefinementsDemo {
  
  fileprivate func setupUI() {
    configureMainStackView()
    configureHeaderStackView()
    configureTitleLabel()
    configureFilterValueLabel()
    configureHitsCountLabel()
    configureClearButton()
    configureLayout()    
  }
  
  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureClearButton() {
    clearButton.setTitleColor(.black, for: .normal)
    clearButton.setTitle("Clear", for: .normal)
    clearButton.translatesAutoresizingMaskIntoConstraints = false
    clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
  }
  
  func configureTitleLabel() {
    titleLabel.font = .boldSystemFont(ofSize: 25)
    titleLabel.text = "Filters"
  }
  
  func configureFilterValueLabel() {
    filterValueLabel.font = .systemFont(ofSize: 16)
    filterValueLabel.numberOfLines = 0
  }
  
  func configureHitsCountLabel() {
    hitsCountLabel.textColor = .black
    hitsCountLabel.font = .systemFont(ofSize: 12)
  }
  
  func configureHeaderStackView() {
    headerStackView.axis = .vertical
    headerStackView.spacing = 10
    headerStackView.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    headerStackView.isLayoutMarginsRelativeArrangement = true
    headerStackView.distribution = .equalSpacing
    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    headerStackView.addBackground(color: .white)
    headerStackView.subviews.first.flatMap {
      $0.layer.borderWidth = 0.5
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.masksToBounds = true
      $0.layer.cornerRadius = 10
    }
  }
  
  func configureLayout() {
    headerStackView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    headerStackView.addArrangedSubview(titleLabel)
    headerStackView.addArrangedSubview(filterValueLabel)
    headerStackView.addArrangedSubview(hitsCountLabel)
    
    mainStackView.addArrangedSubview(headerStackView)
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .px16),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.px16),
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
    ])
    
    addChild(demo.controller)
    demo.controller.didMove(toParent: self)
    mainStackView.addArrangedSubview(demo.controller.view)
    
    demo.controller.plug(searcher)
    
    view.addSubview(clearButton)
    
    NSLayoutConstraint.activate([
      clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      clearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
      ])
  }

  @objc func clearButtonTapped() {
    filterState.notify(.removeAll)
  }
  
}

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
