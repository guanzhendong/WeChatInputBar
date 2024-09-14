//
//  EmojiBoardView.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/11.
//  Copyright © 2022 arthurguan. All rights reserved.
//

import UIKit

class EmojiBoardView: UIView {
    
    private let charData = ["a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u"]
    private var currentPage = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.register(CollectionCell.self, forCellWithReuseIdentifier: "ID")
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.delegate = self
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 50)
        
        addSubview(scrollView)
        scrollView.anchor(top: collectionView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        scrollView.contentSize = CGSize(width: bounds.width * 20, height: scrollView.bounds.height)
        
        for i in 0..<20 {
            let view = createCollectionView()
            view.frame = CGRect(x: bounds.width * CGFloat(i), y: 0, width: bounds.width, height: bounds.height - 50)
            scrollView.addSubview(view)
        }
        
    }
    
    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .white
        view.register(CollectionCell.self, forCellWithReuseIdentifier: "ID2")
        view.contentInset.bottom = saferAreaInsets.bottom
        return view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EmojiBoardView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == self.collectionView ? charData.count : 40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ID", for: indexPath) as! CollectionCell
            cell.titleLabel.text = charData[indexPath.row].uppercased()
            cell.titleLabel.font = .systemFont(ofSize: 14)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ID2", for: indexPath) as! CollectionCell
            cell.titleLabel.text = "\(indexPath.row)"
            cell.titleLabel.font = .systemFont(ofSize: 24)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        scrollView.setContentOffset(CGPoint(x: index * Int(scrollView.bounds.width), y: 0), animated: true)
    }
}

extension EmojiBoardView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else {
            return
        }
        
        let index = scrollView.contentOffset.x / scrollView.bounds.width
        let page = Int(index.rounded())
        
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) {
            cell.contentView.backgroundColor = .init(white: 0, alpha: 0.1)
        }
        if let cell = collectionView.cellForItem(at: IndexPath(item: page, section: 0)) {
            cell.contentView.backgroundColor = .red
            collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .centeredHorizontally, animated: true)
        }
        currentPage = page
    }
}
