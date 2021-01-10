//
//  api.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 02.08.2020.
//

import Foundation

enum ApiError: Error {
    case notUrl(_ string: String)
    case serverError
}

class Api: ExtendInfoWriter, ExtendInfoReader, ApiSearcher {
    var host: String
    var res: TeaInfo?

    init(_ url: String) {
        host = url
    }

    func writeExtendInfo(info: TeaData, callback: @escaping (String, Error?) -> ()) throws {
        var data: Data
        let jsonEncoder = JSONEncoder()
        do {
            data = try jsonEncoder.encode(info)
        } catch {
            print(error.localizedDescription)
            throw error
        }

        DispatchQueue.global(qos: .utility).async {
            let result = self.makeNewRecord(data: data)

            DispatchQueue.main.async {
                switch result {
                case let .success(res):
                    let decoder = JSONDecoder()
                    do {
                        let json = String(decoding: res!, as: UTF8.self)
                        print(json)
                        let newInfo = try decoder.decode(TeaDataResponse.self, from: res!)
                        callback(newInfo.ID, nil)
                    } catch {
                        print(error.localizedDescription)
                        callback("", error)
                    }
                case let .failure(error):
                    callback("", error)
                }
            }
        }
    }

    func getExtendInfo(id: String, callback: @escaping (TeaData?, Error?) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            let result = self.readRecord(id: id)

            DispatchQueue.main.async {
                switch result {
                case let .success(res):
                    let decoder = JSONDecoder()
                    do {
                        let json = String(decoding: res!, as: UTF8.self)
                        print(json)
                        let newInfo = try decoder.decode(TeaDataResponse.self, from: res!)
                        callback(TeaData(name: newInfo.name, type: newInfo.type, description: newInfo.description), nil)
                    } catch {
                        print(error.localizedDescription)
                        callback(nil, error)
                    }
                case let .failure(error):
                    callback(nil, error)
                }
            }
        }
    }

    func search(prefix: String, callback: @escaping (TeaDataWithID?, Error?) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            let result = self.searchRecords(prefix: prefix)

            DispatchQueue.main.async {
                switch result {
                case let .success(res):
                    if res == nil {
                        callback(nil, nil)
                    }
                    let decoder = JSONDecoder()
                    do {
                        let newInfo = try decoder.decode([TeaDataResponse].self, from: res!)
                        if newInfo.count > 0 {
                            callback(TeaDataWithID(ID: newInfo[0].ID, name: newInfo[0].name, type: newInfo[0].type, description: newInfo[0].description), nil)
                        } else {
                            callback(nil, nil)
                        }
                    } catch {
                        print(error.localizedDescription)
                        callback(nil, error)
                    }
                case let .failure(error):
                    callback(nil, error)
                }
            }
        }
    }

    private func searchRecords(prefix: String) -> Result<Data?, ApiError> {
        guard let escapedPrefix = prefix.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else{
            print("fail escaping prefix: ", prefix)
            return .failure(.notUrl(host + "/all?name=" + prefix))
        }
        guard let url = URL(string: host + "/all?name=" + escapedPrefix) else {
            print("fail url: ", prefix)
            return .failure(.notUrl(host + "/all?name=" + escapedPrefix))
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        var result: Result<Data?, ApiError>!

        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let data = data {
                result = .success(data)
            } else {
                result = .failure(.serverError)
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return result
    }

    private func makeNewRecord(data: Data) -> Result<Data?, ApiError> {
        guard let url = URL(string: host + "/new_record") else {
            return .failure(.notUrl(host + "/new_record"))
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.httpBody = data

        var result: Result<Data?, ApiError>!

        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let data = data {
                result = .success(data)
            } else {
                result = .failure(.serverError)
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return result
    }

    private func readRecord(id: String) -> Result<Data?, ApiError> {
        guard let url = URL(string: host + "/" + id) else {
            return .failure(.notUrl(host + "/" + id))
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        var result: Result<Data?, ApiError>!

        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let data = data {
                result = .success(data)
            } else {
                result = .failure(.serverError)
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return result
    }
}
