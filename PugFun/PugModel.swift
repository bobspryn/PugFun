//
//  PugModel.swift
//  PugFun
//
//  Created by Bob Spryn on 7/11/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import UIKit

struct Pug {
    let url: URL
    let image: UIImage?

    init(url: URL, image: UIImage?) {
        self.url = url
        self.image = image
    }
}

extension Pug: CustomStringConvertible {
    public var description: String {
        return "Pug url: \(url)\n \(String(describing: image))"
    }
}

extension Pug: Equatable {
    static func ==(lhs: Pug, rhs: Pug) -> Bool {
        return lhs.url == rhs.url && lhs.image == rhs.image
    }

}
