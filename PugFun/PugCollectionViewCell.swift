//
//  UICollectionViewCell.swift
//  PugFun
//
//  Created by Bob Spryn on 7/11/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import Foundation
import UIKit

class PugCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView
    public override init(frame: CGRect) {
        self.imageView = UIImageView()
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
        self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor)
        self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        self.imageView.backgroundColor = UIColor.purple
        self.backgroundColor = UIColor.green
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        self.imageView.image = nil
    }
}
