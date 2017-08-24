//
//  OfflineURLProtocol.swift
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 24/08/2017.
//  Copyright © 2017 Artem Abramov. All rights reserved.
//

import Foundation

class OfflineURLProtocol: URLProtocol {

    enum OfflineURLProtocolErrors: Error {
        case noURLSpecified, other, noData
    }

    override func stopLoading() { }
    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        guard let requestURL = request.url else {
            client?.urlProtocol(self, didFailWithError: OfflineURLProtocolErrors.noURLSpecified)
            return
        }
        let loadData = { () -> Data? in
            switch self.request.httpMethod {
            case .some("GET"):
                guard let path = Bundle.main.path(forResource: requestURL.lastPathComponent, ofType: nil) else { return nil }
                return try? Data(contentsOf: URL(fileURLWithPath: path))
            default:
                return "Garbage".data(using: String.Encoding.utf8)
            }
        }
        guard let data = loadData() else {
            client?.urlProtocol(self, didFailWithError: OfflineURLProtocolErrors.noData)
            return
        }
        guard let response = HTTPURLResponse(url: requestURL, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type" : "application/xml; charset=utf-8"]) else {
            client?.urlProtocol(self, didFailWithError: OfflineURLProtocolErrors.other)
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
}
