//
//  UITableView+Convenience.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 12/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
  
  func scrollToFirstNonEmptySection() {
    let firstNonEmptySection = (0...numberOfSections - 1).filter { numberOfRows(inSection: $0) > 0 }.first
    guard let existingFirstNonEmptySection = firstNonEmptySection else {
      return
    }
    let indexPath = IndexPath(row: 0, section: existingFirstNonEmptySection)
    scrollToRow(at: indexPath, at: .top, animated: false)
  }
  
}
