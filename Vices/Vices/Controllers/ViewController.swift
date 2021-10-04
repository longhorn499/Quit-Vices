//
//  ViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

/// mv
struct Vice: Hashable {
    let emoji: String?
    let name: String
    let quittingDate: Date

    init(emoji: String? = nil, name: String, quittingDate: Date = Date()) {
        self.emoji = emoji
        self.name = name
        self.quittingDate = quittingDate
    }
}

class VicesViewController: UIViewController {

    enum Section {
        case main
    }

    /// test
    private let models: [Vice] = [
        .init(emoji: "🚬", name: "Nicotine", quittingDate: Calendar.current.date(from: DateComponents(year: 2018, month: 10, day: 1))!),
        .init(emoji: "🍺", name: "Alcohol", quittingDate: Date()),
        .init(name: "Misc.", quittingDate: Date())
    ]

    private lazy var dataSource = UITableViewDiffableDataSource<Section, Vice>(
        tableView: self.tableView
    ) { [weak self] tableView, indexPath, _ in
        guard let `self` = self else {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViceTableViewCell", for: indexPath) as! ViceTableViewCell
        // TODO: tapping should delegate back to here.. to remove it
        cell.configure(vice: self.models[indexPath.row])
        return cell
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()


        applySnapshot()
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Vice>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models)
        dataSource.apply(snapshot)
    }

    // TODO: need to reload days coming from the background
}

