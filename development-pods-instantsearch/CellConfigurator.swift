//
//  CellConfigurator.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 12/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import SDWebImage

class CellConfigurator<T> {
  static func configure(_ cell: UITableViewCell) -> (T) -> Void {
    return { _ in }
  }
}

extension CellConfigurator where T == Movie {
  
  static func configure(_ cell: UITableViewCell) -> (T) -> Void {
    return { movie in
      cell.textLabel?.text = movie.title
      cell.detailTextLabel?.text = movie.genre.joined(separator: ", ")
      cell.imageView?.sd_setImage(with: movie.image, completed: { (_, _, _, _) in
        cell.setNeedsLayout()
      })
    }
  }
  
}

extension CellConfigurator where T == Actor {
  
  static func configure(_ cell: UITableViewCell) -> (T) -> Void {
    return { actor in
      cell.textLabel?.text = actor.name
      cell.detailTextLabel?.text = "rating: \(actor.rating)"
      let baseImageURL = URL(string: "https://image.tmdb.org/t/p/w45")
      let imageURL = baseImageURL?.appendingPathComponent(actor.image_path)
      cell.imageView?.sd_setImage(with: imageURL, completed: { (_, _, _, _) in
        cell.setNeedsLayout()
      })
    }
  }
  
}
