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
        
    }
    
    func configure(_ model: WeatherItem?) {
        guard let model = model else { return }
        switchView.isHidden = false
        cityLabel.text = model.city
        valueLabel.text = String(Int(model.temperature)) + "°" + model.unit
        backgroundColor = backgroudColorWith(model)
    }
    
    private func backgroudColorWith(_ model: WeatherItem) -> UIColor {
        var temperature = model.temperature
        if model.unit == "F" {
            temperature = (temperature - 32) * 5/9
            measureSwitch.isOn = false
        } else {
            measureSwitch.isOn = true
        }
        
        if temperature > 25 {
            return .red
        } else if temperature <= 25 && temperature >= 10 {
            return .orange
        } else {
            return .lightBlue
        }
    }
}
