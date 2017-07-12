//
//  ViewController.swift
//  PugFun
//
//  Created by Bob Spryn on 7/11/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import UIKit
import Changeset
import RxSwift
import RxCocoa

class ViewController: UICollectionViewController {
    let viewModel: PugViewModel = PugViewModel()
    let disposables = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(PugCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PugCollectionViewCell.self))
        self.viewModel.changes
            .drive(onNext: { edits in
                self.collectionView?.update(with: edits)
            }).addDisposableTo(self.disposables)
        // TODO move away from VC accessing the main context and use first responder or action dispatcher
        PugContext.shared.fetchImages()
    }
}

extension ViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows()
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: PugCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PugCollectionViewCell.self),
                                                                             for: indexPath) as! PugCollectionViewCell
        let pug = self.viewModel.pug(forItemAtIndexPath: indexPath)

        if (pug.image == nil) {
            // TODO move away from VC accessing the main context and use first responder or action dispatcher
            PugContext.shared.downloadImageForPug(pug: pug)
        } else {
            cell.imageView.image = pug.image
        }
        cell.backgroundColor = UIColor.green

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item + 1 == self.viewModel.numberOfRows() {
            // TODO move away from VC accessing the main context and use first responder or action dispatcher
            PugContext.shared.fetchImages()
        }
    }
}

