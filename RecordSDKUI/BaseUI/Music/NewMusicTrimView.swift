//
//  NewMusicTrimView.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/25.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc protocol NewMusicTrimViewDelegate: NSObjectProtocol {
    func valueChanged(view: NewMusicTrimView, startPercent: CGFloat, endPercent: CGFloat)
}

class NewMusicTrimView: UIView, UIScrollViewDelegate {

    @objc weak var delegate: NewMusicTrimViewDelegate?
    
    var upperView: UIView!
    var scrollView: UIScrollView!
    var trimView: MDSMSelectIntervalProgressView!
    
    var startPercent: CGFloat = 0
    
    var widthConstraint: NSLayoutConstraint!
    
    @objc var duration: CGFloat = 0 {
        didSet {
            guard trimView.window != nil else {
                return
            }

            widthConstraint.isActive = false
            if duration <= 15 {
                widthConstraint = trimView.widthAnchor.constraint(equalTo: widthAnchor)
            } else {
                widthConstraint = trimView.widthAnchor.constraint(equalToConstant: duration * 22.0)
            }
            widthConstraint.isActive = true
            trimView.layoutIfNeeded()
        }
    }
    
    @objc var disable: Bool = true {
        didSet {
            scrollView.isUserInteractionEnabled = !disable
//            trimView.trackColor = disable ? .gray : UIColor(red: 0.0, green: 253.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
//            trimView.inactiveColor = disable ? .gray : UIColor.white.withAlphaComponent(0.2)
            trimView.disable = disable
        }
    }
    
    @objc var beginTime: CGFloat {
        set {
            startPercent = duration > 0 ? newValue / duration : 0
            scrollView.setContentOffset(CGPoint(x: startPercent * scrollView.contentSize.width - scrollView.contentInset.left, y: 0), animated: false)
            updateTrimView(start: startPercent, end: (duration > 0 ? (newValue + 15) / duration : 0))
        }
        get {
            return startPercent * duration
        }
    }
    
    @objc var currentValue: CGFloat {
        set {
            trimView.currentValue = newValue
        }
        get {
            return trimView.currentValue
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

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layer.cornerRadius = 5
        scrollView.delegate = self
        scrollView.bounces = true
        addSubview(scrollView)
        
        trimView = MDSMSelectIntervalProgressView()
        trimView.translatesAutoresizingMaskIntoConstraints = false
        trimView.backgroundColor = .clear
        trimView.marginLineHightColor = .clear
        trimView.marginLineColor = .clear
        trimView.progressColor = UIColor(red: 0.0, green: 156.0 / 255.0, blue: 1.0, alpha: 1.0)
        trimView.trackColor = UIColor(red: 0.0, green: 253.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
        trimView.inactiveColor = UIColor.white.withAlphaComponent(0.2)
        trimView.selectAreaBgColor = .clear
        trimView.disable = false
        trimView.beginValue = 0
        trimView.currentValue = 0
        trimView.endValue = 1
        trimView.linePadding = 6
        scrollView.addSubview(trimView)
        
        upperView = UIView()
        upperView.translatesAutoresizingMaskIntoConstraints = false
        upperView.isUserInteractionEnabled = false
        upperView.backgroundColor = .black
        upperView.alpha = 0.21
        upperView.layer.cornerRadius = 5
        addSubview(upperView)

        upperView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        upperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        upperView.widthAnchor.constraint(equalToConstant: 330).isActive = true
        
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: upperView.heightAnchor).isActive = true
        
        trimView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        trimView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        trimView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        trimView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
//        trimView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        trimView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.8).isActive = true
        widthConstraint = trimView.widthAnchor.constraint(equalTo: widthAnchor)
        widthConstraint.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: (bounds.width - upperView.width) / 2.0 , bottom: 0, right: (bounds.width - upperView.width) / 2.0)
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let (startPercent, endPercent) = currentPosition(scrollView: scrollView)
        updateTrimView(start: startPercent, end: endPercent)
    }
    
    @objc func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let (startPercent, endPercent) = currentPosition(scrollView: scrollView)
//        print(startPercent, endPercent)
        updateTrimView(start: startPercent, end: endPercent)
        
        self.startPercent = startPercent
        delegate?.valueChanged(view: self, startPercent: startPercent, endPercent: endPercent)
    }
    
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        
        let (startPercent, endPercent) = currentPosition(scrollView: scrollView)
        updateTrimView(start: startPercent, end: endPercent)
        
        self.startPercent = startPercent
        delegate?.valueChanged(view: self, startPercent: startPercent, endPercent: endPercent)
    }
    
    func currentPosition(scrollView: UIScrollView) -> (start: CGFloat, end: CGFloat) {
        let offsetX = scrollView.contentOffset.x + scrollView.contentInset.left
        let startPercent = offsetX / scrollView.contentSize.width
        let endPercent = (offsetX + upperView.width) / scrollView.contentSize.width
        return (startPercent, endPercent)
    }

    func updateTrimView(start: CGFloat, end: CGFloat) {
        trimView.beginValue = start < 0.0 ? 0.0 : start
        trimView.endValue = end > 1.0 ? 1.0 : end
        trimView.currentValue = trimView.beginValue
    }
}
