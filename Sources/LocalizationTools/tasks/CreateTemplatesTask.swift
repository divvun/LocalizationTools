/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

struct CreateTemplatesTask {
    let l10nRepoPath: String

    private func copyEnLocaleToTemplates() {
        let source = URL(fileURLWithPath: "\(l10nRepoPath)/en/strings.xliff")
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("temp.xliff")
        let destination = URL(fileURLWithPath: "\(l10nRepoPath)/templates/strings.xliff")
        try! FileManager.default.copyItem(at: source, to: tmp)
        _ = try! FileManager.default.replaceItemAt(destination, withItemAt: tmp)
    }

    private func handleXML() throws {
        let url = URL(fileURLWithPath: "\(l10nRepoPath)/templates/strings.xliff")
        let xml = try! XMLDocument(contentsOf: url, options: .nodePreserveWhitespace)

        guard let root = xml.rootElement() else { return }

        try root.nodes(forXPath: "file").forEach { node in
            guard let node = node as? XMLElement else { return }
            node.removeAttribute(forName: "target-language")
        }

        try root.nodes(forXPath: "file/body/trans-unit/target").forEach { $0.detach() }
        try xml.xmlString.write(to: url, atomically: true, encoding: .utf8)
    }

    func run() {
        copyEnLocaleToTemplates()
        try! handleXML()
    }
}
