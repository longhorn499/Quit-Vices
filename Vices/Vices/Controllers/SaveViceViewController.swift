//
//  SaveViceViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

protocol CreateViceViewControllerDelegate: AnyObject {
    func createViceViewController(_ vc: SaveViceViewController, didSave vice: Vice)
    func createViceViewControllerDidResign(_ vc: SaveViceViewController)

}

// TODO: simple keyboard dismissing from textField
class SaveViceViewController: UIViewController {

    var vice: Vice?
    weak var delegate: CreateViceViewControllerDelegate?

    @IBOutlet weak private var quittingDatePicker: UIDatePicker!
    /// doesn't look good
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        /// if passed in, configure fields
        if vice != nil {
            nameTextField.text = vice!.name
            quittingDatePicker.date = vice!.quittingDate
        }
        nameTextField.addTarget(self, action: #selector(self.nameChanged), for: .editingChanged)
        nameChanged()
    }

    deinit {
        delegate?.createViceViewControllerDidResign(self)
    }

    @objc func nameChanged() {
        let empty = nameTextField.text?.isEmpty ?? true
        saveButton.isEnabled = !empty
        /// animating this would look nice
        saveButton.backgroundColor = empty ? UIColor.systemPurple.withAlphaComponent(0.5) : UIColor.systemPurple
    }

    @IBAction func didTapSave(_ sender: UIButton) {
        assert(!nameTextField.text!.isEmpty)
        
        let mdyComp = Calendar.current.dateComponents([.month, .day, .year], from: quittingDatePicker.date)
        let mdyDate = Date.monthDayYearDate(month: mdyComp.month!, day: mdyComp.day!, year: mdyComp.year!)
        delegate?.createViceViewController(self, didSave: .init(name: nameTextField.text!, quittingDate: mdyDate))
    }
}
