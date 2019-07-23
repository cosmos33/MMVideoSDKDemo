//
//  MDRecordSpeedSlider.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/6.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class MDRecordSpeedSlider: UISlider {

    var valueLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configUI()
    }
    
    func configUI() {
        
        let valueLabel = UILabel()
        valueLabel.text = "0"
        valueLabel.textColor = .white
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 20))
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        
        self.valueLabel = valueLabel
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        let offsetY: CGFloat = 56.0 - (56.0 + 31.0) / 2.0
        return CGRect(origin: CGPoint(x: rect.minX, y: rect.minY + offsetY), size: rect.size)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let centerX = rect.minX + rect.width / 2.0
        valueLabel?.frame = CGRect(x: centerX - 30.0 / 2.0, y: rect.minY - 20.0 - 5, width: 30, height: 20)
        valueLabel?.text = String(format: "%.1fx", value);
        return rect
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 56);
    }

}
