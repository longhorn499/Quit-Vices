//
//  SettingsViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 2/24/22.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak private var versionNumberLabel: UILabel!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        versionNumberLabel.text = Bundle.main.versionNumberString
    }

}

fileprivate extension Bundle {
    var releaseVersionNumber: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
    var buildVersionNumber: String? { infoDictionary?["CFBundleVersion"] as? String }
    var versionNumberString: String { "\(releaseVersionNumber ?? "") (\(buildVersionNumber ?? ""))" }
}
