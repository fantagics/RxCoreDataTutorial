//
//  ProductsViewModel.swift
//  BFrameTestroject
//
//  Created by paololee on 11/14/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ProductViewModel {
    // Inputs
    let addProductAction = PublishRelay<ProductInfo>()
    let deleteProductAction = PublishRelay<Product>()
    let updateProductAction = PublishRelay<(Product, ProductInfo)>()

    // Outputs
    let products: Observable<[Product]>

    private let repository: ProductRepository
    private let disposeBag = DisposeBag()

    init(repository: ProductRepository = ProductRepository()) {
        self.repository = repository
        self.products = repository.productsObservable

        // Bind inputs to repository actions
        addProductAction
            .subscribe(onNext: { [weak repository] productInfo in
                repository?.createProduct(data: productInfo)
            })
            .disposed(by: disposeBag)

        deleteProductAction
            .subscribe(onNext: { [weak repository] product in
                repository?.delete(product: product)
            })
            .disposed(by: disposeBag)

        updateProductAction
            .subscribe(onNext: { [weak repository] pair in
                let (product, newProduct) = pair
                repository?.update(product: product, newProduct: newProduct)
            })
            .disposed(by: disposeBag)
    }
}
