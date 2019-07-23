//
//  FilterDrawerSlider.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/22.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class FilterDrawerSlider: UIView {
    
    @objc var changeValue: ((FilterDrawerSlider, Float) -> Void)?
    
    @objc var defaultValue: Float = 0.0 {
        didSet {
            slider.value = defaultValue
        }
    }

    @objc var title: String? {
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }
    
    var label: UILabel!
    var slider: UISlider!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configUI()
    }
    
    func configUI() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        addSubview(label)
        
        slider = MDRecordSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        addSubview(slider)
        
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant:-3).isActive = true
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        slider.leftAnchor.constraint(equalTo: label.rightAnchor, constant:15).isActive = true
        slider.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        slider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
    }
    
    @objc func sliderValueChanged(_ slider: UISlider) {
        changeValue?(self, slider.value)
    }

}
