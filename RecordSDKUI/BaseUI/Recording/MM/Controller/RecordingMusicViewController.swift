//
//  RecordingMusicViewController.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/22.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc protocol RecordingMusicViewControllerDelegate : NSObjectProtocol {
    func musicPicker(musicPicker: RecordingMusicViewController, didPick musicItem: MDMusicCollectionItem, timeRange: CMTimeRange)
    func musicPickerDidClearMusic(musicPicker: RecordingMusicViewController)
    func musicPickerDidCancel(musicPicker: RecordingMusicViewController)
}

class RecordingMusicViewController: UIViewController, MDMusicEditPalletControllerDelegate {
    
    static let reloadCurrentMusicItem: Notification.Name = Notification.Name("kMusicPickerReloadCurrentMusicItemNotification")
    
    @objc weak var delegate: RecordingMusicViewControllerDelegate?
    
    var currentMusicItem: MDMusicCollectionItem?
    var lastMusicItem: MDMusicCollectionItem?
    var selectedMusicItem: MDMusicCollectionItem?
    var currentTimeRange: CMTimeRange?
    
    var viewIsShowing: Bool {
        return isViewLoaded && (view.window != nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        musicPlayer?.removeTimeObserver(self)
    }
    
    init(musicItem: MDMusicCollectionItem?) {
        super.init(nibName: nil, bundle: nil)
        
        currentMusicItem = musicItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(musicEditPalletVC)
        musicEditPalletVC.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        musicEditPalletVC.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        musicEditPalletVC.endAppearanceTransition()
        
        guard let _ = musicPlayer?.currentItem else {
            return
        }
        play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        musicEditPalletVC.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        musicEditPalletVC.endAppearanceTransition()
        pause()
    }
    
    @objc static func show(musicItem: MDMusicCollectionItem, delegate: RecordingMusicViewControllerDelegate?) -> RecordingMusicViewController  {
        let vc = RecordingMusicViewController(musicItem: musicItem)
        vc.delegate = delegate
        vc.showMusicVC()
        return vc
    }
    
    @objc func goBack() {
        self.hideMusicVC()
        
        delegate?.musicPickerDidCancel(musicPicker: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrentMusicItem(_:)), name: RecordingMusicViewController.reloadCurrentMusicItem, object: nil)
    }
    
    // MARK: - player
    
    var musicPlayer: AVPlayer?
    var musicObserver: Any?
    
    @objc func play() {
        guard checkShouldPlay() else { return }
        musicPlayer?.play()
    }
    
    @objc func pause() {
        musicPlayer?.pause()
    }
    
    @discardableResult
    func playWithCheckAssetValid(item: MDMusicCollectionItem) -> Bool {
        var isValid = true
        if MDMusicResourceUtility.checkAssetValid(with: item.resourceUrl, sizeConstraint: false) {
            selected(musicCollectionItem: item)
            configPlayer(with: item)
            play()
        } else {
            isValid = false
        }
        return isValid
    }
    
    func configPlayer(with item: MDMusicCollectionItem) {
        guard item.resourceExist() else {
            return
        }
        
        let songAsset = AVURLAsset(url: item.resourceUrl)
        let songItem = AVPlayerItem(asset: songAsset)
        
        musicPlayer?.replaceCurrentItem(with: songItem)
        musicPlayer?.pause()
    }
    
    func setupTimeObserver() {
        musicObserver.map { musicPlayer?.removeTimeObserver($0) }
        musicObserver = musicPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: DispatchQueue.main, using: { [weak self] (time) in
            self?.periodicTimeCallback(time: time)
        });
    }
    
    func checkShouldPlay() -> Bool {
        return viewIsShowing && (UIApplication.shared.applicationState == .active)
    }
    
    func selected(musicCollectionItem: MDMusicCollectionItem) {
        let oldItem = selectedMusicItem
        oldItem?.selected = false
        
        selectedMusicItem = musicCollectionItem
        selectedMusicItem?.selected = true
    }
    
    func resetPlayerZeroToPlay() {
        if let range = currentTimeRange, selectedMusicItem != nil && checkShouldPlay() {
            musicPlayer?.seek(to: range.start, toleranceBefore: .zero, toleranceAfter: .zero)
            play()
        }
    }
    
    // MARK: - MDMusicEditPalletController
    
    var musicEditPalletVC: MDMusicEditPalletController {
        let vc = MDMusicEditPalletController()
        vc.delegate = self
        return vc
    }
    
    var musicID: String {
        return musicEditPalletVC.currentSelectMusicItem.musicVo.musicID
    }
    
    var isLocalMusic: Bool {
        return musicEditPalletVC.currentSelectMusicItem.isLocal
    }
    
    func periodicTimeCallback(time: CMTime) {
        if self.musicEditPalletVC.viewIsShowing() {
            self.musicEditPalletVC.periodicTimeCallback(time)
        }
    }
    
    func setDefaultVolume(volume: CGFloat) {
        musicEditPalletVC.setOriginDefaultMusicVolume(volume)
    }
    
    func updateMusicItem(item: MDMusicCollectionItem, timeRange: CMTimeRange) {
        musicEditPalletVC.updateMusicItem(item, timeRange: timeRange)
    }
    
    @objc func showMusicVC() {
        view.addSubview(musicEditPalletVC.view)
        musicEditPalletVC.showAnimate(complete: nil)
    }
    
    @objc func hideMusicVC() {
        delegate?.musicPickerDidCancel(musicPicker: self)
        guard musicEditPalletVC.isShowed else {
            return
        }
        musicEditPalletVC.hideAnimation(complete: nil)
    }

   
    // MARK: - MDMusicEditPalletControllerDelegate Methods
    
    func musicEditPallet(_ musicEditPallet: MDMusicEditPalletController, didPickMusicItems musicItem: MDMusicCollectionItem, timeRange: CMTimeRange) {
        lastMusicItem = musicItem
        currentTimeRange = timeRange
        if musicItem.resourceExist() {
            playWithCheckAssetValid(item: musicItem)
        } else if (!musicItem.downLoading) {
            
        }
        delegate?.musicPicker(musicPicker: self, didPick: musicItem, timeRange: timeRange)
    }
    
    func musicEditPallet(_ musicEditPallet: MDMusicEditPalletController, didEditOriginalVolume originalVolume: CGFloat, musicVolume: CGFloat) {
        
    }
    
    func musicEditPalletDidClearMusic(_ musicEditPallet: MDMusicEditPalletController) {
        delegate?.musicPickerDidClearMusic(musicPicker: self)
    }
    
    // MARK: - Notifications
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        pause()
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        resetPlayerZeroToPlay()
    }
    
    @objc func audioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let interruptionType = userInfo[AVAudioSessionInterruptionTypeKey],
            let type = interruptionType as? AVAudioSession.InterruptionType,
            type == .ended else {
            return
        }
        
        guard let interruptionOptions = userInfo[AVAudioSessionInterruptionOptionKey],
            let options = interruptionOptions as? AVAudioSession.InterruptionOptions,
            options == .shouldResume else {
            return
        }
        
        resetPlayerZeroToPlay()
    }
    
    @objc func reloadCurrentMusicItem(_ notification: Notification) {
        guard musicPlayer?.currentItem == currentMusicItem else {
            return
        }
        let _ = currentMusicItem.map { playWithCheckAssetValid(item:$0) }
    }
    
}
