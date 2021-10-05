//
//  VicesViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

// TODO: Fix background color of nav bar going under table (that works w/ dark and light)
// TODO: Fix cell layout with large text (days and name should expand.., or put it back in the stackView and change from vert to horizontal)
// TODO: Guard against duplication crash if there are duplicates it will crash (keep original if duplicate introduced)
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

    /// hacky
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

    // MARK: - IBAction

    @IBAction func didTapAddVice(_ sender: UIBarButtonItem) {
        presentSaveVice(vice: nil)
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
        let reset = UIContextualAction(
            style: .normal,
            title: "Reset"
        ) {  (_, _, completion) in
            self.models[indexPath.row].quittingDate = .todayMonthDayYear()
            self.applySnapshot()
            self.saveVices()
            completion(true)
        }
        reset.backgroundColor = .systemIndigo
        let edit = UIContextualAction(
            style: .normal,
            title: "Edit"
        ) {  (_, _, completion) in
            self.editingIndex = indexPath
            self.presentSaveVice(vice: self.models[indexPath.row])
            completion(true)
        }
        edit.backgroundColor = .systemPurple
        return UISwipeActionsConfiguration(actions: [delete, reset, edit])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingIndex = indexPath
        presentSaveVice(vice: models[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let r = models.remove(at: sourceIndexPath.row)
        models.insert(r, at: destinationIndexPath.row)
    }
}

// MARK: - UITableViewDropDelegate

extension VicesViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}

// MARK: CreateViceViewControllerDelegate

extension VicesViewController: CreateViceViewControllerDelegate {
    func createViceViewController(_ vc: SaveViceViewController, didSave vice: Vice) {
        vc.dismiss(animated: true) { [weak self] in
            guard let this = self else {
                return
            }
            if this.editingIndex != nil {
                this.models[this.editingIndex!.row] = vice
                this.editingIndex = nil
            } else {
                this.models.append(vice)
            }
            this.applySnapshot()
            this.saveVices()
        }
    }

    func createViceViewControllerDidResign(_ vc: SaveViceViewController) {
        editingIndex = nil
    }
}
