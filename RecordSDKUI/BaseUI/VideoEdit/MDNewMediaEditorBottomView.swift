//
//  MDNewMediaEditorBottomView.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/21.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit
import Foundation

@objc protocol MDNewMediaEditorBottomViewDelegate: NSObjectProtocol {

    func buttonClicked(_ view: MDNewMediaEditorBottomView, title: String)
    
}

class MDNewMediaEditorBottomView: UIView {
    
    @objc public weak var delegate: MDNewMediaEditorBottomViewDelegate?
    
    var titles: [String]?
    var imageNames: [String]?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 20.5, bottom: 0, right: 20.5)
        addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 103).isActive = true
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        
        
        let titles = self.titles ?? ["滤镜", "配乐", "贴纸", "文字", "涂鸦", "封面", "变速", "特效", "人像"]
        let images = (self.imageNames ?? ["editFilters", "editMusic", "editStiker", "editText", "editDraw", "editThumbImage", "editSpeedVary", "editSpecial", "editPersonalImage"]).map({ (name) -> UIImage? in
            UIImage(named: name)
        })
        
        var cells = [MDNewMediaEditorBottomCell]()
        for (title, image) in zip(titles, images) {
            let cell = MDNewMediaEditorBottomCell()
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.widthAnchor.constraint(equalToConstant: 58.5).isActive = true
            cell.title = title
            cell.contentImage = image
            cell.tapCallBack = { [unowned self] (cell: MDNewMediaEditorBottomCell) in
                self.delegate?.buttonClicked(self, title: cell.title!)
            }
            cells.append(cell)
        }
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: cells)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        scrollView.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        return stackView
    }()
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, titles: nil, imageNames: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configUI()
    }
    
    @objc init(frame: CGRect, titles: [String]?, imageNames: [String]?) {
        super.init(frame: frame)
        
        self.titles = titles
        self.imageNames = imageNames;
        
        configUI()
    }
    
    func configUI() {
        let _ = scrollView
        let _ = stackView
    }
}
