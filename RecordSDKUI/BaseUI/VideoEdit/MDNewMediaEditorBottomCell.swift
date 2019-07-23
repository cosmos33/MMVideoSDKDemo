//
//  MDNewMediaEditorBottomCell.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/21.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class MDNewMediaEditorBottomCell: UIView {
    
    public var title: String? {
        set {
            titleLabel?.text = newValue
        }
        get {
            return titleLabel?.text
        }
    }
    
    public var contentImage: UIImage? {
        set {
            contentImageView?.image = newValue
        }
        get {
            return contentImageView?.image
        }
    }
    
    var tapCallBack: ((MDNewMediaEditorBottomCell) -> Void)?
    var titleLabel: UILabel?
    var contentImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configUI()
    }
    
    func configUI() {
        isUserInteractionEnabled = true
        
        let bgImageView = UIImageView(image: UIImage(named: "mediaEditorBottomCellImageBG"))
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.isUserInteractionEnabled = true
        addSubview(bgImageView)
        
        let contentImageView = UIImageView()
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.isUserInteractionEnabled = true
        bgImageView.addSubview(contentImageView)
        self.contentImageView = contentImageView
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = true
        addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        bgImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bgImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bgImageView.widthAnchor.constraint(equalToConstant: 58.5).isActive = true
        bgImageView.heightAnchor.constraint(equalTo: bgImageView.widthAnchor).isActive = true
        
        contentImageView.centerXAnchor.constraint(equalTo: bgImageView.centerXAnchor).isActive = true
        contentImageView.centerYAnchor.constraint(equalTo: bgImageView.centerYAnchor).isActive = true
        contentImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
        contentImageView.widthAnchor.constraint(equalTo: contentImageView.heightAnchor).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: bgImageView.bottomAnchor, constant: 8).isActive = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(gesture)
    }
    
    @objc func tapAction(_ gesture: UITapGestureRecognizer) {
        tapCallBack?(self)
    }

}
