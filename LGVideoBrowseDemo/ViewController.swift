//
//  ViewController.swift
//  LGVideoBrowseDemo
//
//  Created by liangang zhan on 2024/3/31.
//

import UIKit
import SnapKit
import Lantern
import Kingfisher

class ViewController: UIViewController {

    lazy var displayView: DisplayView = {
        let view = DisplayView(frame: CGRect(x: 0, y: (UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.width)/2.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width))
        view.backgroundColor = .white
        view.onTapHandler = { [weak self] in
            self?.onTapLantern()
        }
        return view
    }()
    
    private lazy var firstView: UIImageView = {
        let firstView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        firstView.contentMode = .scaleAspectFit
        firstView.isUserInteractionEnabled = true
        firstView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickTap)))
        return firstView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: 2 * UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)

        scrollView.addSubview(firstView)
        if let url = VideoPlayerManager.shared.list.first {
            firstView.kf.setImage(with: URL(string: url))
        }
        
        let displayBgView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        displayBgView.addSubview(displayView)
        scrollView.addSubview(displayBgView)
        

        VideoPlayerManager.shared.createPlayer()
        if let _ = VideoPlayerManager.shared.avPlayerLayer {
            VideoPlayerManager.shared.avPlayerLayer?.frame = displayView.bounds
            displayView.layer.addSublayer(VideoPlayerManager.shared.avPlayerLayer!)
            VideoPlayerManager.shared.play()
        }
    }
    
    @objc private func clickTap() {
        
    }
    
    func onTapLantern() {
        let lantern = Lantern()
        let cards = VideoPlayerManager.shared.list
        lantern.numberOfItems = {
            cards.count
        }
        lantern.cellClassAtIndex = { index in
            LanternImageCell.self
        }
        lantern.reloadCellAtIndex = { [weak self] context in
            guard let self = self else { return }
            LanternLog.high("reload cell!")
            
            let collectionPath = IndexPath(item: context.index, section: 0)
//            let collectionCell = self.pagerView.cvView?.cellForItem(at: collectionPath) as? CustomPagerCell
//            let placeholder = collectionCell?.targetImageView.image
            
            let item = VideoPlayerManager.shared.list[context.index]
            if let lanternCell = context.cell as? LanternImageCell {
                print("ViewController reloadCellAtIndex \(context.index)")

                if item.contains(".mp4"), let _ = URL(string: item) {
                    VideoPlayerManager.shared.configureView(lanternCell)
                } else {
                    lanternCell.imageView.kf.setImage(with: URL(string: item))
                }
            }
        }
        
        lantern.didChangedPageIndex = { [weak self] index in
            guard let self = self else { return }
            print("ViewController didChangedPageIndex \(index)")
//            VideoPlayerManager.shared.didChangedPageIndex(index)
        }
        
        lantern.lanternDismiss = { [weak self] cell, index in
            guard let self = self else { return }
            VideoPlayerManager.shared.configureView(self.displayView)
//            self.videoPlayer.configurePlayerLayer(self.pagerView, count: cards.count - 1)
        }
        
//        lantern.transitionAnimator = LanternSmoothZoomAnimator(transitionViewAndFrame: { [weak self] (index, destinationView) -> LanternSmoothZoomAnimator.TransitionViewAndFrame? in
//            guard let self = self else { return nil }
//            let path = IndexPath(item: index, section: indexPath.section)
//            if let cell = self.pagerView.cvView?.cellForItem(at: path) as? CustomPagerCell {
//                let image = cell.targetImageView.image
//                let transitionView = UIImageView(image: image)
//                transitionView.contentMode = cell.targetImageView.contentMode
//                transitionView.clipsToBounds = true
//                let thumbnailFrame = cell.targetImageView.convert(cell.targetImageView.bounds, to: destinationView)
//                return (transitionView, thumbnailFrame)
//            }
//            guard let cell = self.pagerView.cvView?.cellForItem(at: indexPath) as? DanserMovieCell else {
//                return nil
//            }
//            
//            // 复制原始视图的CALayer
//            let transitionView = UIView(frame: UIScreen.main.bounds)
//
//            if let originalLayer = cell.layer.presentation() {
//                let copiedLayer = CALayer()
//                copiedLayer.contents = originalLayer.contents
//                copiedLayer.bounds = originalLayer.bounds
//                copiedLayer.position = originalLayer.position
//
//                // 将复制的CALayer添加到新的视图上
//                transitionView.layer.addSublayer(copiedLayer)
//            }
//
//            let thumbnailFrame = cell.contentView.convert(cell.contentView.bounds, to: destinationView)
//            return (transitionView, thumbnailFrame)
//        })
        // UIPageIndicator样式的页码指示器
        lantern.pageIndicator = cards.count == 1 ? nil : LanternDefaultPageIndicator()
        lantern.pageIndex = 1
        lantern.show()


    }

}

