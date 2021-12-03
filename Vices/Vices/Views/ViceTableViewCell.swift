//
//  ViceTableViewCell.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

// Get name to extend all the way to date when going multiline
// just need right mix of configurations, hugging priority, etc.
// looks okay rn
class ViceTableViewCell: UITableViewCell {

    @IBOutlet weak private var containerStackView: UIStackView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var reasonLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func configure(vice: Vice) {
        nameLabel.text = vice.name
        if vice.reason != nil {
            reasonLabel.text = vice.reason
            reasonLabel.isHidden = false
        } else {
            reasonLabel.isHidden = true
        }
        timeLabel.text = Formatters.quittingDay(vice.quittingDate)
    }

    private func setup() {
        nameLabel.font = UIFont.systemFont(
            ofSize: 24,
            weight: .semibold
        ).scaledFontforTextStyle(.body)
        reasonLabel.font = UIFont.systemFont(
            ofSize: 20,
            weight: .regular
        ).scaledFontforTextStyle(.body)
        timeLabel.font = UIFont.systemFont(
            ofSize: 20,
            weight: .regular
        ).scaledFontforTextStyle(.body)

        /// accessibility
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
            containerStackView.axis = .vertical
            containerStackView.alignment = .leading
            timeLabel.textAlignment = .left
        } else {
            containerStackView.axis = .horizontal
            containerStackView.alignment = .center
            timeLabel.textAlignment = .right
        }
    }
}
