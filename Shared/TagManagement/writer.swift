//
// Created by Andrew Khasanov on 05.09.2020.
//

import Foundation

protocol ExtendInfoWriter {
    func writeExtendInfo(info: TeaData, callback: @escaping (String, Error?)->()) throws
}

protocol ShortInfoWriter {
    func writeData(info: TeaMeta) throws
}

class writer {
    var extend: ExtendInfoWriter
    var meta: ShortInfoWriter
    init(extend: ExtendInfoWriter, meta: ShortInfoWriter) {
        self.extend = extend
        self.meta = meta
    }

    func write(_ data: TeaData, expirationDate: Date, brewingTemp: Int) throws {
        try self.extend.writeExtendInfo(info: data) { (id, err) -> () in
            if err != nil {
                print(err!)
                return
            }
            print(id)
            let meta = TeaMeta(id: id, expirationDate: expirationDate, brewingTemp: brewingTemp)


            do {
                try self.meta.writeData(info: meta)
            } catch {
                print(error)
            }
        }
    }
}
