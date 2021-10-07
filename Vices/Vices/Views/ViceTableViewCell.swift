//
//  ViceTableViewCell.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

class ViceTableViewCell: UITableViewCell {

    // TODO: vertical or horizontal based on accessibility category
    @IBOutlet weak private var containerStackView: UIStackView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func configure(vice: Vice) {
        nameLabel.text = vice.name
        timeLabel.text = Formatters.quittingDay(vice.quittingDate)
    }

    private func setup() {
        nameLabel.font = UIFont.systemFont(
            ofSize: 24,
            weight: .semibold
        ).scaledFontforTextStyle(.body)
        timeLabel.font = UIFont.systemFont(
            ofSize: 24,
            weight: .regular
        ).scaledFontforTextStyle(.body)
    }
}
