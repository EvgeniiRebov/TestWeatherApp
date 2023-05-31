//
//  HistoryCell.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import UIKit

class HistoryCell: UITableViewCell {
    let topLabel = UILabel()
    let bottomLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        topLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true

        contentView.addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 8).isActive = true
        bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ model: WeatherItem) {
        topLabel.text = model.city + " " + String(Int(model.temperature)) + "°" + model.unit.short
        bottomLabel.text = model.date
    }
}
