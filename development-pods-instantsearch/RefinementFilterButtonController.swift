//
//  UIButton+SelectableViewController.swift
//  InstantSearchCore-iOS
//
//  Created by Vladislav Fitc on 03/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class RefinementFilterButtonController<F: FilterType>: RefinementFilterViewController {
  
  typealias Item = F
  
  public let button: UIButton
  
  public var onClick: ((Bool) -> Void)?
  
  public init(button: UIButton) {
    self.button = button
    button.addTarget(self, action: #selector(didToggleButton), for: .touchUpInside)
  }
  
  @objc func didToggleButton(_ button: UIButton) {
    onClick?(!button.isSelected)
  }
  
  func setSelected(_ isSelected: Bool) {
    self.button.isSelected = isSelected
  }
  
}