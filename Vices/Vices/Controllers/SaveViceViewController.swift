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

class SaveViceViewController: UIViewController {

    // MARK: - Properties

    var vice: Vice?
    weak var delegate: CreateViceViewControllerDelegate?

    @IBOutlet weak private var quittingDatePicker: UIDatePicker!
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var reasonTextField: UITextField!
    @IBOutlet weak private var saveButton: SaveButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        /// if passed in, configure fields
        if vice != nil {
            nameTextField.text = vice!.name
            reasonTextField.text = vice!.reason
            quittingDatePicker.date = vice!.quittingDate
        }
        nameTextField.addTarget(self, action: #selector(self.nameChanged), for: .editingChanged)
        nameTextField.delegate = self
        nameChanged()

        reasonTextField.delegate = self

        /// best way for simple dismiss keyboard on tap background? don't want a keyboard "manager"
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Deinit

    deinit {
        delegate?.createViceViewControllerDidResign(self)
    }

    // MARK: - Methods

    @objc func nameChanged() {
        let empty = nameTextField.text?.isEmpty ?? true
        saveButton.isEnabled = !empty
    }

    // MARK: - IBAction

    @IBAction func didTapSave(_ sender: UIButton) {
        assert(!nameTextField.text!.isEmpty)
        
        let mdyComp = Calendar.current.dateComponents([.month, .day, .year], from: quittingDatePicker.date)
        let mdyDate = Date.monthDayYearDate(month: mdyComp.month!, day: mdyComp.day!, year: mdyComp.year!)
        let vice = Vice(name: nameTextField.text!, quittingDate: mdyDate, reason: reasonTextField.text)
        delegate?.createViceViewController(self, didSave: vice)
    }
}

// MARK: - UITextFieldDelegate

extension SaveViceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            reasonTextField.becomeFirstResponder()
            return true
        }
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Button

class SaveButton: UIButton {
    let animationDuration = 0.1

    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.alpha = self.isEnabled ? 1.0 : 0.6
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                UIView.animate(
                    withDuration: animationDuration,
                    animations: {
                        self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                    }
                )
            } else {
                UIView.animate(
                    withDuration: animationDuration,
                    animations: {
                        self.transform = CGAffineTransform.identity
                    }
                )
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel?.font = UIFont.systemFont(
            ofSize: 16,
            weight: .bold
        ).scaledFontforTextStyle(.body)
        titleLabel?.adjustsFontForContentSizeCategory = true
        backgroundColor = .systemPurple
        setTitleColor(.white, for: .normal)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48.0).isActive = true
    }
}

