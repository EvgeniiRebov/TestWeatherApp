//
//  InfoView.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import UIKit

class InfoView: UIView {
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .medium)
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    private lazy var measureSwitch: UISwitch = {
        let measureSwitch = UISwitch()
        measureSwitch.isOn = false
        measureSwitch.addTarget(self, action: #selector(changeUnit), for: .valueChanged)
        return measureSwitch
    }()
    
    private lazy var switchView: UIStackView = {
        let stack = UIStackView()
        let labelF = UILabel()
        labelF.text = "F"
        labelF.font = .systemFont(ofSize: 24)
        let labelC = UILabel()
        labelC.text = "C"
        labelC.font = .systemFont(ofSize: 24)
        stack.addArrangedSubview(labelF)
        stack.addArrangedSubview(measureSwitch)
        stack.addArrangedSubview(labelC)
        stack.distribution = .equalSpacing
        stack.spacing = 8
        stack.axis = .horizontal
        return stack
    }()
    
    private var model: WeatherItem?
    
    var changedUnit: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(cityLabel)
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        cityLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true

        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        valueLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 20).isActive = true

        addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        switchView.topAnchor.constraint(equalTo: valueLabel.topAnchor).isActive = true
        switchView.isHidden = true
    }
    
    @objc private func changeUnit() {
        UnitUserDefaults.setValue(measureSwitch.isOn ? UnitType.celsius.intValue : UnitType.fahrenheit.intValue)
        changedUnit?()
    }
    
    func configure(_ model: WeatherItem?) {
        guard let model = model else { return }
        self.model = model
        switchView.isHidden = false
        cityLabel.text = model.city
        valueLabel.text = String(Int(model.temperature)) + "°" + model.unit.short
        backgroundColor = backgroudColorWith(model)
    }
    
    private func backgroudColorWith(_ model: WeatherItem) -> UIColor {
        if model.unit == .fahrenheit {
            measureSwitch.isOn = false
        } else {
            measureSwitch.isOn = true
        }
        
        switch (model.temperature, model.unit) {
        case (..<10, .celsius), (..<50, .fahrenheit):
            return .lightBlue
        case (..<25, .celsius), (..<77, .fahrenheit):
            return .orange
        case (26..., .celsius), (78..., .fahrenheit):
            return .red
        default:
            return .white
        }
    }
}
