//
//  VicesTableViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 2/24/22.
//

import UIKit

class VicesTableViewController: UITableViewController {
    enum Section {
        case main
    }

    // MARK: - Properties

    private var editingIndex: IndexPath?
    private lazy var dataSource = VicesTableViewDataSource(tableView: self.tableView)

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.estimatedRowHeight = 92
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.dragInteractionEnabled = true
        tableView.dropDelegate = self

        dataSource.applySnapshot()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - Methods

    func presentSaveVice(vice: Vice?) {
        let create = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveViceViewController") as! SaveViceViewController
        create.delegate = self
        create.vice = vice
        present(create, animated: true)
    }

    func addVice(_ vice: Vice) {
        guard !isDuplicate(vice: vice) else {
            return
        }
        dataSource.models.append(vice)
        dataSource.applySnapshot()
        dataSource.saveVices()
        UserReviews.incrementReviewActionCount()
    }

    func isDuplicate(vice: Vice) -> Bool {
        /// fine for now, duplicates cause a crash, could indicate in some way to user
        guard !(dataSource.models.contains { $0 == vice }) else {
            return true
        }
        return false
    }

    // MARK: - IBAction

    @IBAction func didTapAddVice(_ sender: UIBarButtonItem) {
        /// these are maybe not great but help you get started, really just want to presentSaveVices most of the time
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let nicotine = UIAlertAction(title: "🍺", style: .default) { _ in
            self.addVice(.init(name: "🍺 Alcohol", reason: nil))
        }
        alert.addAction(nicotine)
        let alcohol = UIAlertAction(title: "🚬", style: .default) { _ in
            self.addVice(.init(name: "🚬 Nicotine", reason: nil))
        }
        alert.addAction(alcohol)
        let custom = UIAlertAction(title: "Other", style: .default) { _ in
            self.presentSaveVice(vice: nil)
        }
        alert.addAction(custom)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        alert.view.tintColor = .systemPurple
        present(alert, animated: true)
    }

    // MARK: - Notifications

    @objc func willEnterForeground() {
        dataSource.reloadSnapshot()
    }
}

// MARK: - UITableViewDelegate

extension VicesTableViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            self.dataSource.models.remove(at: indexPath.row)
            self.dataSource.applySnapshot()
            self.dataSource.saveVices()
            UserReviews.incrementReviewActionCount()
            completion(true)
        }
        ///  models[indexPath.row].quittingDate
        ///  only show if this date is not in today
        ///  also should probably dbl check before commiting action
        let reset = UIContextualAction(
            style: .normal,
            title: "Reset"
        ) {  (_, _, completion) in
            let new = Vice(
                name: self.dataSource.models[indexPath.row].name,
                quittingDate: .todayMonthDayYear(),
                reason: self.dataSource.models[indexPath.row].reason
            )
            if !self.isDuplicate(vice: new) {
                self.dataSource.models[indexPath.row] = new
                self.dataSource.applySnapshot()
                self.dataSource.saveVices()
                UserReviews.incrementReviewActionCount()
            }
            completion(true)
        }
        reset.backgroundColor = .systemIndigo
        return UISwipeActionsConfiguration(actions: [delete, reset])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingIndex = indexPath
        presentSaveVice(vice: dataSource.models[indexPath.row])
    }
}

// MARK: - UITableViewDropDelegate

extension VicesTableViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}

// MARK: CreateViceViewControllerDelegate

extension VicesTableViewController: CreateViceViewControllerDelegate {
    func createViceViewController(_ vc: SaveViceViewController, didSave vice: Vice) {
        vc.dismiss(animated: true) { [weak self] in
            guard let this = self else {
                return
            }
            if this.editingIndex != nil {
                /// dry - method for edit
                if !(this.dataSource.models.contains { $0 == vice }) {
                    this.dataSource.models[this.editingIndex!.row] = vice
                    this.dataSource.applySnapshot()
                    this.dataSource.saveVices()
                    UserReviews.incrementReviewActionCount()
                }
                this.editingIndex = nil
            } else {
                this.addVice(vice)
            }
        }
    }

    func createViceViewControllerDidResign(_ vc: SaveViceViewController) {
        editingIndex = nil
    }
}
