//
//  TableViewCell.swift
//  BSDRandom
//
//  Created by 전건우 on 05/05/2019.
//  Copyright © 2019 geonu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TableViewCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var selectSwitch: UISwitch!
    private var disposables: [Disposable] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(user: User, index: Int) {
        disposables.forEach { $0.dispose() }
        disposables = []
        nameLabel.text = user.name
        selectSwitch.isOn = user.isSelected
        disposables.append(selectSwitch.rx.controlEvent(.valueChanged).bind {
            Redux.shared.store.dispatch(AppAction.setUser(value: self.selectSwitch.isOn, index: index))
        })
    }

}
