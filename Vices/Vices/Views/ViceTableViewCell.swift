//
//  ViceTableViewCell.swift
//  Vices
//
//  Created by Kevin Johnson on 10/4/21.
//

import UIKit

let formatter = RelativeDateTimeFormatter()

class ViceTableViewCell: UITableViewCell {

    @IBOutlet weak private var emojiLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(vice: Vice) {
        if vice.emoji != nil {
            emojiLabel.text = vice.emoji
            emojiLabel.isHidden = false
        } else {
            emojiLabel.isHidden = true
        }
        nameLabel.text = vice.name

        /// time
        let days = Calendar.current.dateComponents([.day], from: Date(), to: vice.quittingDate).day!
        formatter.localizedString(from: DateComponents(day: days))
        if days == 0 {
            timeLabel.text = "Today" // there is a formatter for this..
        } else {
            /// days should be negative
            assert(days < 0)
            print(days)
            timeLabel.text = formatter.localizedString(
                from: DateComponents(day: days)
            )
        }
    }
}
