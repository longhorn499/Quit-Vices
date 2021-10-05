//
//  ViceTableViewCell.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

/// only create one, expensive to init - move to global place that's better
fileprivate let formatter = RelativeDateTimeFormatter()

class ViceTableViewCell: UITableViewCell {

    // TODO: vertical or horizontal based on accessibility category + decide on l/r styling of label
    @IBOutlet weak private var containerStackView: UIStackView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func configure(vice: Vice) {
        nameLabel.text = vice.name

        ///  time
        print(Date.todayMonthDayYear(), vice.quittingDate)
        let days = Calendar.current.dateComponents([.day], from: .todayMonthDayYear(), to: vice.quittingDate).day!
        formatter.localizedString(from: DateComponents(day: days))
        print("days:", days)
        if days == 0 {
            timeLabel.text = "Today" // there is a formatter for this..?
        } else {
            timeLabel.text = formatter.localizedString(
                from: DateComponents(day: days)
            )
        }
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
