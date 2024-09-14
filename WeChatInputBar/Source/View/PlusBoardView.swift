//
//  PlusBoardView.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/7.
//  Copyright © 2022 arthurguan. All rights reserved.
//

import UIKit

class PlusBoardView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = CollectionViewHorizontalFlowLayout()
        layout.minimumLineSpacing = 20
        layout.sectionInset = .init(top: 20, left: 20, bottom: 10, right: 20)
        let view = UICollectionView(frame: .null, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .white
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.register(CollectionCell.self, forCellWithReuseIdentifier: "ID")
        return view
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 2
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .groupTableViewBackground
        pc.currentPageIndicatorTintColor = .darkGray
        pc.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
        return pc
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.anchor(bottom: saferAreaLayoutGuide.bottomAnchor, paddingBottom: 20)
        
        addSubview(pageControl)
        pageControl.centerX(inView: self, topAnchor: collectionView.bottomAnchor, paddingTop: 0)

    }
    
    @objc func pageControlValueChanged() {
        let index = pageControl.currentPage
        collectionView.setContentOffset(CGPoint(x: index * Int(collectionView.bounds.width), y: 0), animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlusBoardView: UICollectionViewDataSource, UICollectionViewDelegate {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ID", for: indexPath) as! CollectionCell
        cell.titleLabel.text = "\(indexPath.row)"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / collectionView.bounds.width
        pageControl.currentPage = Int(page.rounded())
    }
}





class CollectionCell: UICollectionViewCell {
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.textAlignment = .center
        lb.font = .systemFont(ofSize: 30)
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .init(white: 0, alpha: 0.1)
        contentView.layer.cornerRadius = 5
        
        contentView.addSubview(titleLabel)
        titleLabel.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








class CollectionViewHorizontalFlowLayout: UICollectionViewFlowLayout {
    
    let numberOfColum: CGFloat = 4
    let numberOfRow: CGFloat = 2
    
    // 保存所有item
    fileprivate var attributesArr: [UICollectionViewLayoutAttributes] = []
    
    var viewWidth: CGFloat {
        collectionView?.bounds.width ?? 100
    }
    
    var viewHeight: CGFloat {
        collectionView?.bounds.height ?? 100
    }
    
    var marginTotal: CGFloat {
        minimumLineSpacing * (numberOfColum - 1)
    }
    
    var marginTotalV: CGFloat {
        minimumInteritemSpacing * (numberOfRow - 1)
    }
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collectionViewContentSize: CGSize {
        let itemsCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        let page =  CGFloat(itemsCount / Int(numberOfColum * numberOfRow))
        return CGSize(width: (page + 1) * viewWidth, height: viewHeight)
    }
    
    // MARK: - 重新布局
     override func prepare() {
         super.prepare()
         
         let itemW: CGFloat = (viewWidth - marginTotal - sectionInset.left - sectionInset.right) / numberOfColum
         let itemH: CGFloat = (viewHeight - marginTotalV - sectionInset.top - sectionInset.bottom) / numberOfRow
         
         // 设置itemSize
         itemSize = CGSize(width: itemW, height: itemH)
         
         
         var page: CGFloat = 0
         let itemsCount = collectionView?.numberOfItems(inSection: 0) ?? 0
         for itemIndex in 0..<itemsCount {
             let indexPath = IndexPath(item: itemIndex, section: 0)
             let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
             
             page = CGFloat(itemIndex / Int(numberOfColum * numberOfRow))
             // 通过一系列计算, 得到x, y值
             let x = sectionInset.left + (itemW + minimumLineSpacing) * CGFloat(itemIndex % Int(numberOfColum)) + page * viewWidth
             let y = sectionInset.top + (itemH + minimumInteritemSpacing) * CGFloat(Int((CGFloat(itemIndex) - page * numberOfRow * numberOfColum) / numberOfColum))
             
             
             attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
             // 把每一个新的属性保存起来
             attributesArr.append(attributes)
         }
         
     }
     
     override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
         var rectAttributes: [UICollectionViewLayoutAttributes] = []
         _ = attributesArr.map({
             if rect.contains($0.frame) {
                 rectAttributes.append($0)
             }
         })
         return rectAttributes
     }
}
