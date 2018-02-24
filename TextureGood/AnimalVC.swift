//
//  AnimalVC.swift
//  TextureGood
//
//  Created by Nick Lin on 2018/2/24.
//  Copyright © 2018年 Nick Lin. All rights reserved.
//

import UIKit
import PINRemoteImage

class AnimalVC: UIViewController {

    let flowLayout = UICollectionViewFlowLayout()
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
    lazy var viewModel: AnimalViewModel = AnimalViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "原生 UIViewController"
        view.backgroundColor = .white
        viewModel.loadingDelegate = self
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: AnimalCollectionViewCell.self)
        collectionView.mLay(pin: .zero)
        collectionView.backgroundColor = .white
        flowLayout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.itemSize.width = (UIScreen.main.bounds.width - 26) / 2
        flowLayout.itemSize.height = flowLayout.itemSize.width + 173
        viewModel.loadData()
    }
}

extension AnimalVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: AnimalCollectionViewCell.self, for: indexPath)
        if let model = viewModel.model(at: indexPath.item) {
            cell.configCell(with: model)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.isLastData(index: indexPath.item) {
            viewModel.loadMoreData()
        }
    }
}

extension AnimalVC: ViewModelLoadingDelegate {
    func loadingDone() {
        self.collectionView.reloadData()
    }

    func loadingFail(_ error: Error?) {
        if let error = error {
            print(error)
        }
    }

}

class AnimalCollectionViewCell: UICollectionViewCell {
    // height = 201 + imgWidth
    fileprivate let imgView = UIImageView()
    fileprivate let shelterLabel = UILabel()
    fileprivate let kindLabel = UILabel()
    fileprivate let genderLabel = UILabel()
    fileprivate let bodySizeLabel = UILabel()
    fileprivate let colourLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    fileprivate func setupUI() {
        imgView.image = UIImage(named: "test.jpg")
        contentView.addSubview(imgView)
        contentView.addSubview(shelterLabel)
        contentView.addSubview(kindLabel)
        contentView.addSubview(genderLabel)
        contentView.addSubview(bodySizeLabel)
        contentView.addSubview(colourLabel)

        imgView.mLay(.width, .equal, contentView)
        imgView.mLay(.height, .equal, imgView, .width, constant: 0)
        imgView.mLay(pin: .init(top: 0, left: 0, right: 0))

        shelterLabel.mLay(.width, .equal, contentView, multiplier: 0.9, constant: 0)
        shelterLabel.mLay(.centerX, .equal, contentView)
        shelterLabel.mLay(.height, 25)
        shelterLabel.mLay(.top, .equal, imgView, .bottom, constant: 8)

        kindLabel.mLay(.width, .equal, contentView, multiplier: 0.9, constant: 0)
        kindLabel.mLay(.centerX, .equal, contentView)
        kindLabel.mLay(.height, 25)
        kindLabel.mLay(.top, .equal, shelterLabel, .bottom, constant: 8)

        genderLabel.mLay(.width, .equal, contentView, multiplier: 0.9, constant: 0)
        genderLabel.mLay(.centerX, .equal, contentView)
        genderLabel.mLay(.height, 25)
        genderLabel.mLay(.top, .equal, kindLabel, .bottom, constant: 8)

        bodySizeLabel.mLay(.width, .equal, contentView, multiplier: 0.9, constant: 0)
        bodySizeLabel.mLay(.centerX, .equal, contentView)
        bodySizeLabel.mLay(.height, 25)
        bodySizeLabel.mLay(.top, .equal, genderLabel, .bottom, constant: 8)

        colourLabel.mLay(.width, .equal, contentView, multiplier: 0.9, constant: 0)
        colourLabel.mLay(.centerX, .equal, contentView)
        colourLabel.mLay(.height, 25)
        colourLabel.mLay(.top, .equal, bodySizeLabel, .bottom, constant: 8)

        contentView.backgroundColor = .white
        layer.cornerRadius = 10
        layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
    }

    func configCell(with model: AnimalDataModel) {
        imgView.pin_setImage(from: model.imageURL)
        shelterLabel.text = model.shelterName
        kindLabel.text = model.kind
        genderLabel.text = model.gender
        bodySizeLabel.text = model.bodySize
        colourLabel.text = model.colour
    }

    override func prepareForReuse() {
        imgView.image = UIImage(named: "test.jpg")
        shelterLabel.text = nil
        kindLabel.text = nil
        genderLabel.text = nil
        bodySizeLabel.text = nil
        colourLabel.text = nil
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        let className = cellType.className
        register(cellType, forCellWithReuseIdentifier: className)
    }

    func register<T: UICollectionViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as! T
        // swiftlint:enable force_cast
    }
}
