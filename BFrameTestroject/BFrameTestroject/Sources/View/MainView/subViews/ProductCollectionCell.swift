//
//  ProductCollectionCell.swift
//  BFrameTestroject
//
//  Created by paololee on 11/12/25.
//

import UIKit

class ProductCollectionCell: UICollectionViewCell{
    static let identifier: String = String(describing: ProductCollectionCell.self)
    
    let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProductCollectionCell{
    func configure(with product: Product){
        titleLabel.text = product.name
        self.backgroundColor = UIColor(hexCode: product.colorCode ?? "#000000")
    }
}

extension ProductCollectionCell{
    private func setConfig(){
        setAttribute()
        setUI()
    }
    private func setAttribute(){
        self.layer.cornerRadius = 16
        
        [titleLabel].forEach{
            $0.font = .boldSystemFont(ofSize: 24)
            $0.textColor = .black
            $0.text = "TITLE"
        }
    }
    private func setUI(){
        [titleLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
