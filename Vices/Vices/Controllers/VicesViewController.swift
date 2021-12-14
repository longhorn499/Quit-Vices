//
//  VicesViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit
import WidgetKit

class VicesViewController: UIViewController {

    enum Section {
        case main
    }

    // MARK: - Properties

    private var models: [Vice] = {
        if let v: [Vice] = try? Cache.read(path: "vices") {
            return v
        }
        return []
    }()

    private var editingIndex: IndexPath?

    private lazy var dataSource = UITableViewDiffableDataSource<Section, Vice>(
        tableView: self.tableView
    ) { [weak self] tableView, indexPath, _ in
        guard let `self` = self else {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViceTableViewCell", for: indexPath) as! ViceTableViewCell
        cell.configure(vice: self.models[indexPath.row])
        return cell
    }

    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.estimatedRowHeight = 92
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        applySnapshot()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - Methods

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Vice>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models)
        dataSource.apply(snapshot)
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
        models.append(vice)
        applySnapshot()
        saveVices()
        UserReviews.incrementReviewActionCount()
    }

    func isDuplicate(vice: Vice) -> Bool {
        /// fine for now, duplicates cause a crash, could indicate in some way to user
        guard !(models.contains { $0 == vice }) else {
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
        var s = dataSource.snapshot()
        s.reloadSections([.main])
        ///  reload quitting date label (may not work w/ out diff?)
        ///  just test
        dataSource.apply(s, animatingDifferences: true)
    }
}

// MARK: - UITableViewDelegate

extension VicesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            self.models.remove(at: indexPath.row)
            self.applySnapshot()
            self.saveVices()
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
                name: self.models[indexPath.row].name,
                quittingDate: .todayMonthDayYear(),
                reason: self.models[indexPath.row].reason
            )
            if !self.isDuplicate(vice: new) {
                self.models[indexPath.row] = new
                self.applySnapshot()
                self.saveVices()
                UserReviews.incrementReviewActionCount()
            }
            completion(true)
        }
        reset.backgroundColor = .systemIndigo
        return UISwipeActionsConfiguration(actions: [delete, reset])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingIndex = indexPath
        presentSaveVice(vice: models[indexPath.row])
    }
}

// MARK: CreateViceViewControllerDelegate

extension VicesViewController: CreateViceViewControllerDelegate {
    func createViceViewController(_ vc: SaveViceViewController, didSave vice: Vice) {
        vc.dismiss(animated: true) { [weak self] in
            guard let this = self else {
                return
            }
            if this.editingIndex != nil {
                /// dry - method for edit
                if !(this.models.contains { $0 == vice }) {
                    this.models[this.editingIndex!.row] = vice
                    this.applySnapshot()
                    this.saveVices()
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
