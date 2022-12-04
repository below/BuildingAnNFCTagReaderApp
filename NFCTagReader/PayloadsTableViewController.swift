/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Payload table view controller
*/

import UIKit
import CoreNFC

extension NFCTypeNameFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nfcWellKnown: return "NFC Well Known type"
        case .media: return "Media type"
        case .absoluteURI: return "Absolute URI type"
        case .nfcExternal: return "NFC External type"
        case .unknown: return "Unknown type"
        case .unchanged: return "Unchanged type"
        case .empty: return "Empty payload"
        @unknown default: return "Invalid data"
        }
    }
}

class PayloadsTableViewController: UITableViewController {

    // MARK: - Properties

    let reuseIdentifier = "reuseIdentifier"
    var message: NFCNDEFMessage = .init(records: [])
    var session: NFCNDEFReaderSession?
    var writeDelegate: NFCNDEFWriteDelegate?

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.message.records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let textLabel = cell.textLabel else {
            return cell
        }

        textLabel.text = "Invalid data"

        let payload = message.records[indexPath.row]
        switch payload.typeNameFormat {
        case .nfcWellKnown:
            if let type = String(data: payload.type, encoding: .utf8) {
                if let url = payload.wellKnownTypeURIPayload() {
                    textLabel.text = "\(payload.typeNameFormat.description): \(type), \(url.absoluteString)"
                } else {
                    textLabel.text = "\(payload.typeNameFormat.description): \(type)"
                }
            }
        case .absoluteURI:
            if let text = String(data: payload.payload, encoding: .utf8) {
                textLabel.text = text
            }
        case .media:
            if let type = String(data: payload.type, encoding: .utf8) {
                textLabel.text = "\(payload.typeNameFormat.description): " + type
            }
        case .nfcExternal, .empty, .unknown, .unchanged:
            fallthrough
        @unknown default:
            textLabel.text = payload.typeNameFormat.description
        }
        
        return cell
    }

    /// - Tag: beginWriting
    @IBAction func beginWrite(_ sender: Any) {
        let delegate = NFCNDEFWriteDelegate(
            message: self.message,
            viewController: self)
        self.writeDelegate = delegate
        session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        session?.begin()
    }
}
