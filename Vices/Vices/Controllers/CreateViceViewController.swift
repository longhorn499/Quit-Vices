//
//  CreateViceViewController.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

protocol CreateViceViewControllerDelegate: AnyObject {
    func createViceViewController(_ vc: CreateViceViewController, didSave vice: Vice)
}

// TODO: Wrap in scrollview, keyboard dismissing
// Create -> Save
class CreateViceViewController: UIViewController {

    var vice: Vice?
    weak var delegate: CreateViceViewControllerDelegate?

    @IBOutlet weak private var quittingDatePicker: UIDatePicker!
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

        quittingDatePicker.maximumDate = .now
    }

    @objc func nameChanged() {
        let empty = nameTextField.text?.isEmpty ?? true
        saveButton.isEnabled = !empty
        saveButton.backgroundColor = empty ? UIColor.systemPurple.withAlphaComponent(0.5) : UIColor.systemPurple
    }

    @IBAction func didTapSave(_ sender: UIButton) {
        assert(!nameTextField.text!.isEmpty)
        delegate?.createViceViewController(self, didSave: .init(emoji: nil, name: nameTextField.text!, quittingDate: quittingDatePicker.date))
    }
}
