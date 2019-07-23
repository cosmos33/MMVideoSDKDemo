//
//  FilterDrawerSliderPanel.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/22.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc protocol FilterDrawerSliderPanelDelegate: NSObjectProtocol {
    func sliderValueChanged(view: FilterDrawerSliderPanel, position: FilterDrawerSliderPanel.Position, value: Float)
}

class FilterDrawerSliderPanel: UIView {
    
    @objc enum Position: Int {
        case top
        case bottom
    }

    @objc weak var delegate: FilterDrawerSliderPanelDelegate?
    
    @objc var title1: String? {
        set {
            slider1.title = newValue
        }
        get {
            return slider1.title
        }
    }
    
    @objc var title2: String? {
        set {
            slider2.title = newValue
        }
        get {
            return slider2.title
        }
    }
    
    var slider1: FilterDrawerSlider!
    var slider2: FilterDrawerSlider!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configUI()
    }
    
    func configUI() {
        slider1 = createSlider()
        slider1.changeValue = { [unowned self] (view, value) in
            self.delegate?.sliderValueChanged(view: self, position: .top, value: value)
        }
        addSubview(slider1)
        
        slider2 = createSlider()
        slider2.changeValue = { [unowned self] (view, value) in
            self.delegate?.sliderValueChanged(view: self, position: .bottom, value: value)
        }
        addSubview(slider2)
        
        slider1.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        slider1.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        slider1.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        slider1.heightAnchor.constraint(equalToConstant: 56).isActive = true

        slider2.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        slider2.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        slider2.topAnchor.constraint(equalTo: slider1.bottomAnchor, constant: 10).isActive = true
        slider2.heightAnchor.constraint(equalTo: slider1.heightAnchor).isActive = true
    }

    func createSlider() -> FilterDrawerSlider {
        let slider = FilterDrawerSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }
}
