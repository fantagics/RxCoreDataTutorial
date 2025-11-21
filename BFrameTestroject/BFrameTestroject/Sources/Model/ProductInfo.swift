//
//  ProductInfo.swift
//  BFrameTestroject
//
//  Created by paololee on 11/14/25.
//

import Foundation
import RxDataSources

struct ProductInfo{
    let name: String
    let colorCode: String
    let rates: [Double]
}

struct ProductSection{
    var items: [Product]
    //    typealias Item = Product
}
extension ProductSection: SectionModelType{
    init(original: ProductSection, items: [Product]) {
        self = original
        self.items = items
    }
}
