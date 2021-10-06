//
//  VicesViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

// TODO: NEXT UP Fix cell layout with large text (days and name should expand.., or put it back in the stackView and change from vert to horizontal)
// TODO: Fix background color of nav bar going under table (that works w/ dark and light) https://stackoverflow.com/questions/48735718/grey-background-above-uitableview-when-large-titles-set
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
        try? Cache.save(models, path: "vices")
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let nicotine = UIAlertAction(title: "🍺", style: .default) { _ in
            self.addVice(.init(name: "🍺 Alcohol"))
        }
        alert.addAction(nicotine)
        let alcohol = UIAlertAction(title: "🚬", style: .default) { _ in
            self.addVice(.init(name: "🚬 Nicotine"))
        }
        alert.addAction(alcohol)
        let custom = UIAlertAction(title: "Custom", style: .default) { _ in
            self.presentSaveVice(vice: nil)
        }
        alert.addAction(custom)
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
            completion(true)
        }
        ///  models[indexPath.row].quittingDate
        ///  only show if this date is not in today
        ///  also should probably dbl check before commiting action
        let reset = UIContextualAction(
            style: .normal,
            title: "Reset"
        ) {  (_, _, completion) in
            let new = Vice(name: self.models[indexPath.row].name, quittingDate: .todayMonthDayYear())
            if !self.isDuplicate(vice: new) {
                self.models[indexPath.row] = new
                self.applySnapshot()
                self.saveVices()
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
