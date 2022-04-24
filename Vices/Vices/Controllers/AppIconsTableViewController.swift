//
//  AppIconsTableViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 2/23/22.
//

import UIKit

class AppIconsTableViewController: UITableViewController {
    var selected: Icons!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.selected = Icons(name: UIApplication.shared.alternateIconName)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Icons.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let icon = Icons(rawValue: indexPath.row) else {
            preconditionFailure()
        }

        let cell: AppIconTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AppIconTableViewCell", for: indexPath) as! AppIconTableViewCell
        cell.configure(
            iconImageName: icon.imageAssetName,
            title: icon.title,
            selected: selected == icon
        )
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let old = selected!
        guard let icon = Icons(rawValue: indexPath.row) else {
            preconditionFailure()
        }
        guard old != icon else { return }

        switch icon {
        case .noé:
            UIApplication.shared.setAlternateIconName(nil)
        case .vices:
            UIApplication.shared.setAlternateIconName("Drawing")
        }

        // fine
        selected = icon
        tableView.reloadRows(
            at: [IndexPath(row: old.rawValue, section: 0), IndexPath(row: icon.rawValue, section: 0)],
            with: .automatic
        )
    }
}
