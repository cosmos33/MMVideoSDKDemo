//
//  VideoNewSpeedSlider.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/24.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class VideoNewSpeedSlider: UIView {
    
    var slider: UISlider!
    var leftLabel: UILabel!
    var rightLabel: UILabel!
//    var valueLabel: UILabel!
    
    @objc var valueChanged: ((VideoNewSpeedSlider, Float) -> Void)?

    @objc var value: Float {
        get {
            return slider.value
        }
        set {
            slider.value = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configUI()
    }
    
    func configUI() {
        slider = MDRecordSpeedSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = false
        slider.minimumValue = 0.2
        slider.maximumValue = 4.0
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        addSubview(slider)
        
        leftLabel = UILabel()
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.font = .systemFont(ofSize: 11)
        leftLabel.textColor = .white
        leftLabel.textAlignment = .left
        leftLabel.text = "0.2x"
        addSubview(leftLabel)
        
        rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = .systemFont(ofSize: 11)
        rightLabel.textColor = .white
        rightLabel.textAlignment = .right
        rightLabel.text = "4.0x"
        addSubview(rightLabel)
        
//        valueLabel = UILabel()
//        valueLabel.translatesAutoresizingMaskIntoConstraints = false
//        valueLabel.font = .systemFont(ofSize: 14)
//        valueLabel.textColor = .white
//        valueLabel.textAlignment = .left
//        valueLabel.text = "1.00"
//        addSubview(valueLabel)

        slider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        slider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: topAnchor).isActive = true

        leftLabel.leftAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        leftLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 8).isActive = true
        
        rightLabel.rightAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        rightLabel.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
    }
    
    @objc func sliderValueChanged(_ slider: UISlider) {
//        valueLabel.text = String(format: "%.2f", slider.value)
        valueChanged?(self, slider.value)
    }
}
