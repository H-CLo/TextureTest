//
//  AnimalASVC.swift
//  TextureGood
//
//  Created by Nick Lin on 2018/2/24.
//  Copyright © 2018年 Nick Lin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class AnimalASVC: ASViewController<ASCollectionNode> {

    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var viewModel: AnimalViewModel = AnimalViewModel()

    init() {
        let collectionNode = ASCollectionNode(collectionViewLayout: self.flowLayout)
        super.init(node: collectionNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Texture ASViewController"
        node.delegate = self
        node.dataSource = self
        node.leadingScreensForBatching = 2
        flowLayout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.itemSize.width = (UIScreen.main.bounds.width - 26) / 2
        flowLayout.itemSize.height = flowLayout.itemSize.width + 173
        viewModel.loadingDelegate = self
        viewModel.loadData()
    }
}

extension AnimalASVC: ViewModelLoadingDelegate {
    func loadingDone() {
        self.node.reloadData()
    }

    func loadingFail(_ error: Error?) {
        if let error = error {
            print(error)
        }
    }

}

extension AnimalASVC: ASCollectionDelegate, ASCollectionDataSource {

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [weak self] in
            let cellNode = AnimalCellNode()
            guard let `self` = self else { return cellNode }
            guard let model = self.viewModel.model(at: indexPath.item) else { return cellNode }
            cellNode.configCell(with: model)
            return cellNode
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: flowLayout.itemSize, max: flowLayout.itemSize)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.viewModel.loadMoreData()
        context.completeBatchFetching(true)
    }
}

class AnimalCellNode: ASCellNode {
    fileprivate let imgNode = ASNetworkImageNode()
    fileprivate let shelterTextNode = ASTextNode()
    fileprivate let kindTextNode = ASTextNode()
    fileprivate let genderTextNode = ASTextNode()
    fileprivate let bodySizeTextNode = ASTextNode()
    fileprivate let colourTextNode = ASTextNode()

    override init() {
        super.init()
        addSubnode(imgNode)
        addSubnode(shelterTextNode)
        addSubnode(kindTextNode)
        addSubnode(genderTextNode)
        addSubnode(bodySizeTextNode)
        addSubnode(colourTextNode)
        imgNode.defaultImage = UIImage(named: "test.jpg")
        cornerRadius = 10
        borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        borderWidth = 1
        clipsToBounds = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let ratioSpec = ASRatioLayoutSpec(ratio: 1, child: imgNode)
        ratioSpec.style.height = ASDimension.init(unit: .points, value: constrainedSize.max.width)
        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.justifyContent = .spaceAround
        stackSpec.children = [shelterTextNode, kindTextNode, genderTextNode, bodySizeTextNode, colourTextNode]
        stackSpec.style.height = ASDimension.init(unit: .points, value: constrainedSize.max.height - constrainedSize.max.width)
        let inset = ASInsetLayoutSpec.init(insets: .init(top: 0, left: 8, bottom: 0, right: 8), child: stackSpec)
        let mainSpec = ASStackLayoutSpec.vertical()
        mainSpec.children = [ratioSpec, inset]
        return mainSpec
    }

    func configCell(with model: AnimalDataModel) {
        imgNode.url = model.imageURL
        shelterTextNode.attributedText = getAttribString(with: model.shelterName)
        kindTextNode.attributedText = getAttribString(with: model.kind)
        genderTextNode.attributedText = getAttribString(with: model.gender)
        bodySizeTextNode.attributedText = getAttribString(with: model.bodySize)
        colourTextNode.attributedText = getAttribString(with: model.colour)
    }

    fileprivate func getAttribString(with str: String?) -> NSAttributedString {
        guard let str = str else { return NSAttributedString() }
        let attrib: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        return NSAttributedString(string: str, attributes: attrib)
    }
}
