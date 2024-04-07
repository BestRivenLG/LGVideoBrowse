//
//  DisplayView.swift
//  LGVideoBrowseDemo
//
//  Created by liangang zhan on 2024/3/31.
//

import UIKit

class DisplayView: UIView {
    
    var onTapHandler: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTapHandler?()
    }
    
}
