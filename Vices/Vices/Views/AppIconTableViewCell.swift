//
//  AppIconTableViewCell.swift
//  Vices
//
//  Created by Kevin Johnson on 2/23/22.
//

import UIKit

class AppIconTableViewCell: UITableViewCell {
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var selectedImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.cornerRadius = 10
    }

    func configure(iconImageName: String, title: String, selected: Bool) {
        iconImageView.image = UIImage(named: iconImageName)
        titleLabel.text = title
        selectedImageView.isHidden = !selected
    }
}
