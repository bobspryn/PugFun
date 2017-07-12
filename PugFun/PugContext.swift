//
//  PugContext.swift
//  PugFun
//
//  Created by Bob Spryn on 7/11/17.
//  Copyright © 2017 Thumbworks. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Changeset

private struct PugRequest: Codable {
    let pugs: [String]
}

// This is similar in nature to a Store in flux
// it holds the state for a certain domain in an app, whether functionality like a session or a user flow
// all changes trickle down from here
// Methods on the context should basically be treated as "actions" and not return anything. All changes
// flow down from the top. undirectional in design
class PugContext: NSObject {
    var pugs: [Pug] = [] {
        didSet {
            let changes = Changeset.edits(from: oldValue, to: pugs)
            self.changesetSubject.onNext(changes)
        }
    }
    private let changesetSubject = PublishSubject<[Edit<Pug>]>()
    lazy var changesets: Observable<[Edit<Pug>]> = {
        self.changesetSubject.asObservable()
    }()

    let api: PugAPI
    private let imageRequests = PublishSubject<Observable<Data>>()
    private let downloadRequests = PublishSubject<(Pug, Observable<Data>)>()
    private let disposables = DisposeBag()
    private lazy var backgroundScheduler: ImmediateSchedulerType = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        return OperationQueueScheduler(operationQueue: operationQueue)
    }()

    static let shared: PugContext = PugContext()

    init(api: PugAPI = DefaultPugAPI()) {
        self.api = api
        super.init()
        self.imageRequests
            .switchLatest()
            .map{ jsonData -> [Pug] in
                let decoder = JSONDecoder()
                let response = try decoder.decode(PugRequest.self, from: jsonData)
                return response.pugs.flatMap({ (string) -> Pug? in
                    guard let url = URL(string: string),
                        let fixedURL = URL(string:"http://media.tumblr.com\(url.path)") else {
                        return nil
                    }
                    return Pug(url: fixedURL, image: nil)
                })
            }
            .debug()
            .subscribe(onNext: { pugs in
                self.pugs.append(contentsOf: pugs)
            })
            .addDisposableTo(self.disposables)

        let downloads = self.downloadRequests
            .observeOn(self.backgroundScheduler)
            .flatMap { values -> Observable<(Pug, UIImage)> in
                let (pug, request) = values
                return request
                    .map { data in
                        guard let image = UIImage(data: data) else {
                            // some error
                            throw NSError(domain: "Bad image data", code: 1, userInfo: nil)
                        }
                        return (pug, image.forceLazyImageDecompression())
                    }
            }

        downloads
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { values in
                let (oldPug, image) = values
                let pug = Pug(url: oldPug.url, image: image)
                guard let index = self.pugs.index(of: oldPug) else {
                    return
                }
                self.pugs[index] = pug
            }).addDisposableTo(self.disposables)
    }

    func fetchImages() {
        self.imageRequests.onNext(self.api.fetchImages(index: 0))
    }

    func downloadImageForPug(pug: Pug) {
        self.downloadRequests.onNext((pug, self.api.downloadImage(url: pug.url)))
    }
}


// stolen from an rx sample project
extension UIImage {
    func forceLazyImageDecompression() -> UIImage {
        #if os(iOS)
            UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
            self.draw(at: CGPoint.zero)
            UIGraphicsEndImageContext()
        #endif
        return self
    }
}

