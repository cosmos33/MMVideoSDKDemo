//
//  NewFaceDecorationView.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/25.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class MakeupViewCell: UIView {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var cellTapped: ((MakeupViewCell) -> Void)?
    var blackView: UIView!
    
    var downloadIcon: UIImageView!
    var loadingView: UIImageView!

    var text: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
    
    var image: UIImage? {
        set {
            imageView.image = newValue
        }
        get {
            return imageView.image
        }
    }
    
    var selected: Bool = false {
        willSet {
            if newValue {
                blackView.layer.borderColor = UIColor(red: 0, green: 192.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
            } else {
                blackView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    var isDownloading: Bool = false {
        didSet {
            imageView.alpha = isDownloading ? 0.5 : 1.0
            isDownloading ? showLoadingView() : hideLoadingView()
            downloadIcon.isHidden = isDownloading
        }
    }
    
    var hasResource: Bool = false {
        didSet {
            downloadIcon.isHidden = hasResource
        }
    }
    
    func showLoadingView() {
        loadingView.isHidden = false
        displayLink.isPaused = false
    }
    
    func hideLoadingView() {
        loadingView.isHidden = true
        displayLink.isPaused = true
    }
    
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayDidRefresh(_:)))
        displayLink.add(to: RunLoop.main, forMode: .common)
        return displayLink
    }()
    
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

        blackView = UIView()
        blackView.isUserInteractionEnabled = true
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.backgroundColor = .black
        blackView.layer.borderWidth = 3
        //        UIColor(red: 0, green: 192.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
        blackView.layer.borderColor = UIColor.clear.cgColor
        addSubview(blackView)
        
        downloadIcon = UIImageView(image: UIImage(named: "icon_moment_download"))
        downloadIcon.translatesAutoresizingMaskIntoConstraints = false
        downloadIcon.isHidden = true
        addSubview(downloadIcon)
        
        loadingView = UIImageView(image: UIImage(named: "moment_play_loading"))
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.isHidden = true
        addSubview(loadingView)
        
        imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        blackView.addSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.isUserInteractionEnabled = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .white
        addSubview(titleLabel)
        
        blackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blackView.widthAnchor.constraint(equalTo: blackView.heightAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: blackView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: blackView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: blackView.widthAnchor, constant: -25).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: blackView.bottomAnchor, constant: 5).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: blackView.centerXAnchor).isActive = true
        
        downloadIcon.bottomAnchor.constraint(equalTo: blackView.bottomAnchor).isActive = true
        downloadIcon.rightAnchor.constraint(equalTo: blackView.rightAnchor).isActive = true
        downloadIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        downloadIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        loadingView.centerXAnchor.constraint(equalTo: downloadIcon.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: downloadIcon.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellClicked(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
    }
    
    @objc func cellClicked(_ tap: UITapGestureRecognizer) {
        cellTapped?(self)
    }
    
    @objc func displayDidRefresh(_ displayLink: CADisplayLink) {
        let transform = loadingView.transform
        
        let duration = 1.0
        let rotationAnglePerRefersh = (2.0 * Double.pi) / (duration * 60.0)
        loadingView.transform = transform.rotated(by: CGFloat(rotationAnglePerRefersh))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blackView.layer.cornerRadius = blackView.height / 2.0
    }
}

@objc protocol NewMakeupViewDelegate: NSObjectProtocol {
    func selected(view: NewMakeupView, type: NewMakeupView.MakeupCellType)
    func didClear(view: NewMakeupView)
}

class NewMakeupView: UIView {
    
    @objc enum MakeupCellType: Int {
        case none
        case daily
        case clearwater
        case freckle
        case leizi
    }
    
    @objc weak var delegate: NewMakeupViewDelegate?
    
    var cell0: MakeupViewCell!
    var cell1: MakeupViewCell!
    var cell2: MakeupViewCell!
    var cell3: MakeupViewCell!
    var cell4: MakeupViewCell!
    
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configUI()
    }
    
    func unselectedAllCell() {
        cell0.selected = false
        cell1.selected = false
        cell2.selected = false
        cell3.selected = false
        cell4.selected = false
    }

    func configUI() {
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "美妆"
        label.font = .systemFont(ofSize: 14)
        addSubview(label)
        
        cell0 = MakeupViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell0.translatesAutoresizingMaskIntoConstraints = false
        cell0.image = UIImage(named: "icon_moment_revoke_select");
        cell0.text = "无"
        cell0.selected = true
        cell0.cellTapped = { [unowned self] cell in
            self.unselectedAllCell()
            cell.selected = true
            self.delegate?.didClear(view: self)
        }
        addSubview(cell0)
        
        cell1 = MakeupViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell1.translatesAutoresizingMaskIntoConstraints = false
        cell1.image = UIImage(named: "cell1");
        cell1.text = "日常"
        cell1.selected = false
        cell1.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .daily)
        }
        addSubview(cell1)
        
        cell2 = MakeupViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell2.translatesAutoresizingMaskIntoConstraints = false
        cell2.image = UIImage(named: "cell2");
        cell2.text = "少年感"
        cell2.selected = false
        cell2.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .clearwater)
        }
        addSubview(cell2)
        
        cell3 = MakeupViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell3.translatesAutoresizingMaskIntoConstraints = false
        cell3.image = UIImage(named: "cell3");
        cell3.text = "小雀斑"
        cell3.selected = false
        cell3.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .freckle)
        }
        addSubview(cell3)
        
        cell4 = MakeupViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell4.translatesAutoresizingMaskIntoConstraints = false
        cell4.image = UIImage(named: "cell4");
        cell4.text = "探探"
        cell4.selected = false
        cell4.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .leizi)
        }
        addSubview(cell4)
        
        let stackView = UIStackView(arrangedSubviews: [cell0, cell1, cell2, cell3, cell4])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        addSubview(stackView)
        
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
        
        cell0.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell0.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cell1.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell1.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cell2.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell2.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cell3.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell3.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cell4.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell4.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    @objc func updateDownloading(isDownloading: Bool, type: NewMakeupView.MakeupCellType) {
        switch type {
        case .daily:
            cell1.isDownloading = isDownloading
        case .clearwater:
            cell2.isDownloading = isDownloading
        case .freckle:
            cell3.isDownloading = isDownloading
        case .leizi:
            cell4.isDownloading = isDownloading
        default:
            break
        }
    }
    
    @objc func updateHasResource(hasResource: Bool, type: NewMakeupView.MakeupCellType) {
        switch type {
        case .daily:
            cell1.hasResource = hasResource
        case .clearwater:
            cell2.hasResource = hasResource
        case .freckle:
            cell3.hasResource = hasResource
        case .leizi:
            cell4.hasResource = hasResource
        default:
            break
        }
    }
}
