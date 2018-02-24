//
//  WebServer.swift
//  TextureGood
//
//  Created by Nick Lin on 2018/2/24.
//  Copyright © 2018年 Nick Lin. All rights reserved.
//

import Foundation
import Alamofire

class WebServer: SessionManager {
    static let shared = WebServer()
    private convenience init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.init(configuration: config, delegate: SessionDelegate(), serverTrustPolicyManager: nil)
    }

    func request(method: HTTPMethod, url: String, parameters: [String: Any]? = nil, handle: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        request(url, method: method, parameters: parameters).validate().response { response in
            handle(response.data, response.response, response.error)
        }
    }

    func getAnimalData(with index: Int, size: Int, handle: (([[String: Any]]?, Error?) -> Void)?) {
//        http://data.coa.gov.tw/Service/OpenData/AnimalOpenData.aspx?$top=10&$skip=0
        let url = "http://data.coa.gov.tw/Service/OpenData/AnimalOpenData.aspx"
        var para: [String: Any] = [:]
        para["$top"] = size
        para["$skip"] = index
        print(para)
        request(method: .get, url: url, parameters: para) { data, _, error in
            guard error == nil, let data = data else {
                handle?(nil, error)
                return
            }
            do {
                let arrayDic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers ) as? [[String: Any]]
                handle?(arrayDic, nil)
            } catch {
                print(error)
                handle?(nil, error)
            }

        }
    }
}

struct AnimalDataModel {

    var imageURL: URL?
    var shelterName: String
    var kind: String
    var gender: String
    var bodySize: String
    var colour: String
    init(_ dic: [String: Any]) {
        self.imageURL = URL(string: dic["album_file"] as? String ?? String())
        self.shelterName = dic["shelter_name"] as? String ?? String()
        self.kind = dic["animal_kind"] as? String ?? String()
        self.gender = dic["animal_sex"] as? String ?? String()
        self.bodySize = dic["animal_bodytype"] as? String ?? String()
        self.colour = dic["animal_colour"] as? String ?? String()
    }

}

protocol ViewModelLoadingDelegate: class {
    func loadingDone()
    func loadingFail(_ error: Error?)
}

class AnimalViewModel {
    weak var loadingDelegate: ViewModelLoadingDelegate?
    fileprivate var models: [AnimalDataModel] = []

    var count: Int {
        return models.count
    }

    func model(at index: Int) -> AnimalDataModel? {
        return index >= count ? nil : models[index]
    }

    func isLastData(index: Int) -> Bool {
        return index + 1 == count
    }

    func loadData() {
        loadAnimalData()
    }

    func loadMoreData() {
        loadAnimalData()
    }

    private func loadAnimalData() {
        WebServer.shared.getAnimalData(with: count, size: 15) { arrDic, error in
            guard let arrDic = arrDic else {
                DispatchQueue.main.async {
                    self.loadingDelegate?.loadingFail(error)
                }
                return
            }
            let models = arrDic.map { AnimalDataModel($0) }
            if self.models.isEmpty {
                self.models = models
            } else {
                self.models += models
            }
            DispatchQueue.main.async {
                self.loadingDelegate?.loadingDone()
            }
        }
    }
}
