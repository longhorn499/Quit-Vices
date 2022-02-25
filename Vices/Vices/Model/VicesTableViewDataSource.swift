//
//  VicesTableViewDataSource.swift
//  Vices
//
//  Created by Kevin Johnson on 2/24/22.
//

import UIKit
import WidgetKit

class VicesTableViewDataSource: UITableViewDiffableDataSource<VicesTableViewController.Section, Vice> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<VicesTableViewController.Section, Vice>

    var models: [Vice]!

    convenience init(tableView: UITableView) {
        self.init(tableView: tableView, cellProvider: { tableView, indexPath, vice in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViceTableViewCell", for: indexPath) as! ViceTableViewCell
            cell.configure(vice: vice)
            return cell
        })
        if let v: [Vice] = try? Cache.read(path: "vices") {
            self.models = v
        } else {
            self.models = []
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = models.remove(at: sourceIndexPath.row)
        models.insert(moved, at: destinationIndexPath.row)
        applySnapshot()
        saveVices()
        UserReviews.incrementReviewActionCount()
    }

    func applySnapshot() {
        var s = Snapshot()
        s.appendSections([.main])
        s.appendItems(models)
        apply(s)
    }

    func reloadSnapshot() {
        var s = snapshot()
        s.reloadSections([.main])
        // reload quitting date label (may not work w/ out diff?)
        // just test
        apply(s, animatingDifferences: true)
    }

    func saveVices() {
        do {
            let data = try Cache.save(models, path: "vices")
            /// appgroup for sharing w/ widget, maybe silly to return data from Cache.save but it avoids doing same thing twice
            try data.write(to: AppGroup.vices.containerURL.appendingPathComponent("vices"))
            WidgetCenter.shared.reloadTimelines(ofKind: "VicesWidget")
        } catch {
            print("Error saving:", error)
        }
    }
}
