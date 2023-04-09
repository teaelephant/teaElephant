//
// Created by Andrew Khasanov on 05.09.2020.
//

import Foundation
import TeaElephantSchema

protocol ExtendInfoReader {
	func getExtendInfo(id: String, callback: @escaping (TeaData?, Error?) -> Void)
}

protocol ShortInfoReader {
	func startReadInfo()
	func setOnRead(_ onRead: @escaping (_ meta: TeaMeta) -> Void)
}

class Reader: ObservableObject {
	@Published var detectedInfo: TeaInfo?
	@Published var error: Error?
	var extender: ExtendInfoReader
	var infoReader: ShortInfoReader

	init(infoReader: ShortInfoReader, extender: ExtendInfoReader) {
		self.extender = extender
		self.infoReader = infoReader
	}

	func readInfo() {
		infoReader.setOnRead(onReadMeta)
		infoReader.startReadInfo()
	}

	private func onReadMeta(_ meta: TeaMeta) {
		extender.getExtendInfo(id: meta.id) { (data, err) -> Void in
			if err != nil {
				self.error = err
				return
			}
			if data != nil {
				self.detectedInfo = TeaInfo(meta: meta, data: data!)
			}
		}
	}

	func processQRCode(_ code: String) {
		Network.shared.apollo.fetch(query: ReadQuery(id: code), resultHandler: { result in

			switch result {
			case .success(let graphQLResult):
				if let errors = graphQLResult.errors {
					self.error = errors.first
					return
				}
				guard let qr = graphQLResult.data?.qrRecord else {
					return
				}
				self.detectedInfo = TeaInfo(
                    meta: TeaMeta(id: qr.tea.id, expirationDate: ISO8601DateFormatter().date(from: qr.expirationDate)!, brewingTemp: qr.bowlingTemp ),
								data: TeaData(name: qr.tea.name, type: qr.tea.type, description: qr.tea.description)
				)
			case .failure(let error):
				self.error = error
			}
		})
	}
}
