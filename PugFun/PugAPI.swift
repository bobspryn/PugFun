//
//  PugAPI.swift
//  PugFun
//
//  Created by Bob Spryn on 7/11/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PugAPI {
    func fetchImages(index: Int) -> Observable<Data>
    func downloadImage(url: URL) -> Observable<Data>
}

class DefaultPugAPI: PugAPI {
    // TODO: pass in URLSession with DI
    let session: URLSession = Foundation.URLSession.shared

    static let url: URL = URL(string:"https://pugme.herokuapp.com/bomb?count=50")!


    func fetchImages(index: Int) -> Observable<Data> {
        return session.rx.data(request: URLRequest(url: DefaultPugAPI.url))
    }

    func downloadImage(url: URL) -> Observable<Data> {
        return session.rx.data(request: URLRequest(url: url))
    }

}
