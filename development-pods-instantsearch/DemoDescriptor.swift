//
//  DemoDescriptor.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 06/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

struct DemoDescriptor {
  
  private static let appID = "latency"
  private static let apiKey = "1f6fd3a6fb973cb08419fe7d288fa4db"
  private static let client = Client(appID: "latency", apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db")
  
  let title: String
//  let appID: String
//  let searcher: Searcher
//  let indexName: String
//  let apiKey: String
//  let controller: UIViewController
  
  static let singleIndex = DemoDescriptor(title: "Single index")
  
}
