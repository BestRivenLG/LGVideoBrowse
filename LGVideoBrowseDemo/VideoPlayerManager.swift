//
//  VideoPlayerManager.swift
//  LGVideoBrowseDemo
//
//  Created by liangang zhan on 2024/3/31.
//

import Foundation
import AVFoundation
import SJMediaCacheServer
import RxSwift
import RxCocoa

class VideoPlayerManager: NSObject {
    
    private let bag = DisposeBag()
    
    static let shared = VideoPlayerManager()
    
    var playerItem: AVPlayerItem?
    
    var player: AVPlayer?
    
    var avPlayerLayer: AVPlayerLayer?
    
    var isDisplay: Bool = false

//    let video = "http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4"
    let video = "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4"
    
    var list: [String] = ["https://img.3dmgame.com/uploads/images/news/20231115/1700003050_631016.jpg", "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4"]
    
    func createPlayer() {
//        DispatchQueue.global().async {
            guard let url = URL(string: self.video) else { return }
            guard let videoUrl = SJMediaCacheServer.shared().playbackURL(with: url) else { return }
            let item = AVPlayerItem(url: videoUrl)
            self.playerItem = item
            self.player = AVPlayer(playerItem: item)
            self.avPlayerLayer = AVPlayerLayer(player: self.player)
            self.avPlayerLayer?.contentsGravity = .resizeAspect
            self.avPlayerLayer?.player = self.player
//            DispatchQueue.main.async {
                self.setupDelegate()
//            }
//        }
    }
    
    func setupDelegate() {
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime)
            .take(until: self.rx.deallocated).subscribe(onNext: { [weak self] _ in
                self?.player?.seek(to: CMTime.zero)
                self?.play()
            }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .take(until: self.rx.deallocated).subscribe(onNext: { [weak self] _ in
                self?.enterForeground()
            }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .take(until: self.rx.deallocated).subscribe(onNext: { [weak self] _ in
                self?.enterBackground()
            }).disposed(by: bag)
    }
    
    func enterForeground() {
        if isDisplay {
            play()
        }
    }
    
    func enterBackground() {
        pause()
    }
    
    func viewWillAppear() {
        isDisplay = true
        play()
    }
    
    func viewDidDisappear() {
        isDisplay = false
        pause()
    }
    
    func configureView(_ view: UIView) {
        if avPlayerLayer?.superlayer == nil, let _ = avPlayerLayer {
            avPlayerLayer?.frame = view.bounds
            if avPlayerLayer != nil {
                view.layer.addSublayer(avPlayerLayer!)
            }
            player?.seek(to: CMTime.zero)
            player?.isMuted = false
        } else {
            avPlayerLayer?.removeFromSuperlayer()
            avPlayerLayer?.frame = view.bounds
            if avPlayerLayer != nil {
                view.layer.addSublayer(avPlayerLayer!)
            }
            player?.isMuted = false
        }
    }
    
    
    
    func didChangedPageIndex(_ index: Int) {
        let item = list[index]
        if item.contains(".mp4") {
            play()
        } else {
            stop()
        }
    }

}

extension VideoPlayerManager {
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        playerItem = nil
        player = nil
        avPlayerLayer = nil
    }
}
