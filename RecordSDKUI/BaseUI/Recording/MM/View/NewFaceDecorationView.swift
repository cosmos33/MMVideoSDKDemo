//
//  NewFaceDecorationView.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/25.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class DecorationViewCell: UIView {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var cellTapped: ((DecorationViewCell) -> Void)?
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

@objc protocol NewFaceDecorationViewDelegate: NSObjectProtocol {
    func selected(view: NewFaceDecorationView, type: NewFaceDecorationView.CellType)
    func didClear(view: NewFaceDecorationView, type: NewFaceDecorationView.CellType)
}

class NewFaceDecorationView: UIView {
    
    @objc enum CellType: Int {
        case none
        case gesture
        case expression
        case effect3D
        case segment
        case audio
        case sheepAudio;
        
        case gift0
        case gift1
        case gift2
        case gift3
        case gift4
    }
    
    @objc weak var delegate: NewFaceDecorationViewDelegate?
    
    var cell0: DecorationViewCell!
    var cell1: DecorationViewCell!
    var cell2: DecorationViewCell!
    var cell3: DecorationViewCell!
    var cell4: DecorationViewCell!
    var cell10: DecorationViewCell!
    var cell11: DecorationViewCell!
    
    var cell5: DecorationViewCell!
    var cell6: DecorationViewCell!
    var cell7: DecorationViewCell!
    var cell8: DecorationViewCell!
    var cell9: DecorationViewCell!
    
//    var label: UILabel!
    var switchButton: MDAlbumVideoSwitchButtonView!
    var scrollView1: UIScrollView!
    var scrollView2: UIScrollView!
    
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
        cell10.selected = false
        cell11.selected = false
    }
    
    func unselectedAllGift() {
        cell5.selected = false
        cell6.selected = false
        cell7.selected = false
        cell8.selected = false
        cell9.selected = false
    }

    func configUI() {
        
        switchButton = MDAlbumVideoSwitchButtonView()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.titles = ["贴纸", "道具"]
        addSubview(switchButton)
        switchButton.titleButtonClicked = { [weak self] (view: MDAlbumVideoSwitchButtonView?, index: Int)  in
            self?.scrollView1.isHidden = (index != 0)
            self?.scrollView2.isHidden = (index == 0)
        }
        
        switchButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        switchButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
        switchButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        switchButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        setupView1()
        setupView2()
    }
    
    func setupView2() {

            cell5 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
            cell5.translatesAutoresizingMaskIntoConstraints = false
            cell5.image = UIImage(named: "icon_moment_revoke_select");
            cell5.text = "无"
            cell5.selected = true
            cell5.cellTapped = { [unowned self] cell in
                self.unselectedAllGift()
                cell.selected = true
                self.delegate?.didClear(view: self, type: .gift0)
            }
            
            cell6 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
            cell6.translatesAutoresizingMaskIntoConstraints = false
            cell6.image = UIImage(named: "cell1");
            cell6.text = "礼物1"
            cell6.selected = false
            cell6.cellTapped = { [unowned self] cell in
                if cell.hasResource {
                    self.unselectedAllGift()
                    cell.selected = true
                }
                self.delegate?.selected(view: self, type: .gift1)
            }
            
            cell7 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
            cell7.translatesAutoresizingMaskIntoConstraints = false
            cell7.image = UIImage(named: "cell2");
            cell7.text = "礼物2"
            cell7.selected = false
            cell7.cellTapped = { [unowned self] cell in
                if cell.hasResource {
                    self.unselectedAllGift()
                    cell.selected = true
                }
                self.delegate?.selected(view: self, type: .gift2)
            }
            
            cell8 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
            cell8.translatesAutoresizingMaskIntoConstraints = false
            cell8.image = UIImage(named: "cell3");
            cell8.text = "礼物3"
            cell8.selected = false
            cell8.cellTapped = { [unowned self] cell in
                if cell.hasResource {
                    self.unselectedAllGift()
                    cell.selected = true
                }
                self.delegate?.selected(view: self, type: .gift3)
            }
            
            cell9 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
            cell9.translatesAutoresizingMaskIntoConstraints = false
            cell9.image = UIImage(named: "cell4");
            cell9.text = "礼物4"
            cell9.selected = false
            cell9.cellTapped = { [unowned self] cell in
                if cell.hasResource {
                    self.unselectedAllGift()
                    cell.selected = true
                }
                self.delegate?.selected(view: self, type: .gift4)
            }
            
            let stackView = UIStackView(arrangedSubviews: [cell5, cell6, cell7, cell8, cell9])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fillEqually
            stackView.spacing = 12

            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.bounces = true
            addSubview(scrollView)
            
            scrollView2 = scrollView
            
            scrollView.addSubview(stackView)
            
            scrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            scrollView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            scrollView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            
            cell5.widthAnchor.constraint(equalToConstant: 60).isActive = true
            cell5.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            cell6.widthAnchor.constraint(equalToConstant: 60).isActive = true
            cell6.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            cell7.widthAnchor.constraint(equalToConstant: 60).isActive = true
            cell7.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            cell8.widthAnchor.constraint(equalToConstant: 60).isActive = true
            cell8.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            cell9.widthAnchor.constraint(equalToConstant: 60).isActive = true
            cell9.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        scrollView2.isHidden = true;
            
    }
    
    func setupView1() {
        
        cell0 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell0.translatesAutoresizingMaskIntoConstraints = false
        cell0.image = UIImage(named: "icon_moment_revoke_select");
        cell0.text = "无"
        cell0.selected = true
        cell0.cellTapped = { [unowned self] cell in
            self.unselectedAllCell()
            cell.selected = true
            self.delegate?.didClear(view: self, type: .none)
        }
        
        cell1 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell1.translatesAutoresizingMaskIntoConstraints = false
        cell1.image = UIImage(named: "cell1");
        cell1.text = "比心切换"
        cell1.selected = false
        cell1.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .gesture)
        }
        
        cell2 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell2.translatesAutoresizingMaskIntoConstraints = false
        cell2.image = UIImage(named: "cell2");
        cell2.text = "小猪脸变形"
        cell2.selected = false
        cell2.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .expression)
        }
        
        cell3 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell3.translatesAutoresizingMaskIntoConstraints = false
        cell3.image = UIImage(named: "cell3");
        cell3.text = "丘比特"
        cell3.selected = false
        cell3.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .effect3D)
        }
        
        cell4 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell4.translatesAutoresizingMaskIntoConstraints = false
        cell4.image = UIImage(named: "cell4");
        cell4.text = "掉钻石"
        cell4.selected = false
        cell4.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .segment)
        }
        
        cell10 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell10.translatesAutoresizingMaskIntoConstraints = false
        cell10.image = UIImage(named: "cell4");
        cell10.text = "小黄鸭"
        cell10.selected = false
        cell10.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .audio)
        }
        
        cell11 = DecorationViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
        cell11.translatesAutoresizingMaskIntoConstraints = false
        cell11.image = UIImage(named: "cell4");
        cell11.text = "绵羊音"
        cell11.selected = false
        cell11.cellTapped = { [unowned self] cell in
            if cell.hasResource {
                self.unselectedAllCell()
                cell.selected = true
            }
            self.delegate?.selected(view: self, type: .sheepAudio)
        }
        
        let stackView = UIStackView(arrangedSubviews: [cell0, cell1, cell2, cell3, cell4, cell10, cell11])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        //        addSubview(stackView)
        
        //        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
        //        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        addSubview(scrollView)
        
        self.scrollView1 = scrollView
        
        scrollView.addSubview(stackView)
        
        scrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
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
        
        cell10.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell10.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cell11.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cell11.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    @objc func updateDownloading(isDownloading: Bool, type: NewFaceDecorationView.CellType) {
        switch type {
        case .gesture:
            cell1.isDownloading = isDownloading
        case .expression:
            cell2.isDownloading = isDownloading
        case .effect3D:
            cell3.isDownloading = isDownloading
        case .segment:
            cell4.isDownloading = isDownloading
        case .gift1:
            cell6.isDownloading = isDownloading
        case .gift2:
            cell7.isDownloading = isDownloading
        case .gift3:
            cell8.isDownloading = isDownloading
        case .gift4:
            cell9.isDownloading = isDownloading
        case .audio:
            cell10.isDownloading = isDownloading
        case .sheepAudio:
            cell11.isDownloading = isDownloading;
        default:
            break
        }
    }
    
    @objc func updateHasResource(hasResource: Bool, type: NewFaceDecorationView.CellType) {
        switch type {
        case .gesture:
            cell1.hasResource = hasResource
        case .expression:
            cell2.hasResource = hasResource
        case .effect3D:
            cell3.hasResource = hasResource
        case .segment:
            cell4.hasResource = hasResource
        case .gift1:
            cell6.hasResource = hasResource
        case .gift2:
            cell7.hasResource = hasResource
        case .gift3:
            cell8.hasResource = hasResource
        case .gift4:
            cell9.hasResource = hasResource
        case .audio:
            cell10.hasResource = hasResource
        case .sheepAudio:
            cell11.hasResource = hasResource;
        default:
            break
        }
    }
}
