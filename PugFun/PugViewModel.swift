//
//  PugViewModel.swift
//  PugFun
//
//  Created by Bob Spryn on 7/11/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import Foundation
import Changeset
import RxSwift
import RxCocoa

// PugViewModel would usually do slightly more than just passing through things from a context (state store)
class PugViewModel {
    private let context: PugContext
    let changes: Driver<[Edit<Pug>]>
    init(context: PugContext = PugContext.shared) {
        self.context = context
        self.changes = context.changesets.asDriver(onErrorJustReturn: [])
    }

    func numberOfRows() -> Int {
        return self.context.pugs.count
    }

    func pug(forItemAtIndexPath indexPath: IndexPath) -> Pug {
        return self.context.pugs[indexPath.item]
    }
}
