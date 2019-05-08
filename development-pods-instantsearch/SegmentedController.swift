//
//  SegmentedController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 08/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore

class SegmentedController: NSObject, RefinementFacetsViewController {
  
  var onClick: ((Facet) -> Void)?
  
  var segmentedControl: UISegmentedControl
  
  var selectableItems: [RefinementFacet] = []
  
  func setSelectableItems(selectableItems: [(item: Facet, isSelected: Bool)]) {
    self.selectableItems = selectableItems
  }
  
  func reload() {
    segmentedControl.removeAllSegments()
   
    for (index, item) in selectableItems.enumerated() {
      segmentedControl.insertSegment(withTitle: item.item.value, at: index, animated: false)
      if item.isSelected {
        segmentedControl.selectedSegmentIndex = index
      }
    }
  }
  
  public init(segmentedControl: UISegmentedControl) {
    self.segmentedControl = segmentedControl
    super.init()
    segmentedControl.addTarget(self, action: #selector(didSelectSegment(_:)), for: .valueChanged)
  }
  
  @objc private func didSelectSegment(_ segmentedControl: UISegmentedControl) {
    let item = selectableItems[segmentedControl.selectedSegmentIndex].item
    onClick?(item)
  }
  
}
