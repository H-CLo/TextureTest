//
//  MainVC.swift
//  TextureGood
//
//  Created by Nick Lin on 2018/2/24.
//  Copyright © 2018年 Nick Lin. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    lazy var button01: UIButton = {
        let button = UIButton()
        button.setTitle("原生", for: .normal)
        button.tag = 1001
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }()

    lazy var button02: UIButton = {
        let button = UIButton()
        button.setTitle("Texture", for: .normal)
        button.tag = 1002
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button01)
        view.addSubview(button02)

        button02.mLay(.centerX, .equal, view)
        button02.mLay(.centerY, .equal, view, multiplier: 0.8, constant: 0)
        button02.mLay(size: CGSize(width: 100, height: 50))

        button01.mLay(.centerX, .equal, view)
        button01.mLay(.centerY, .equal, view, multiplier: 1.2, constant: 0)
        button01.mLay(size: CGSize(width: 100, height: 50))
    }

    @objc func didTapButton(_ sender: UIButton) {
        if sender.tag == 1001 {
            self.navigationController?.pushViewController(AnimalVC(), animated: true)
        } else {
            self.navigationController?.pushViewController(AnimalASVC(), animated: true)
        }
    }
}
