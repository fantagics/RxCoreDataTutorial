//
//  ProductRepository.swift
//  BFrameTestroject
//
//  Created by paololee on 11/17/25.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

class ProductRepository: NSObject{
    // public observable
    private let productsRelay = BehaviorRelay<[Product]>(value: [])
    var productsObservable: Observable<[Product]> { productsRelay.asObservable() }
    
    private let fetchedResultsController: NSFetchedResultsController<Product>//CoreData Product 옵저버
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
         backgroundContext: NSManagedObjectContext = CoreDataStack.shared.backgroundContext) {
        self.viewContext = context
        self.backgroundContext = backgroundContext
        
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Product.savedAt), ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            productsRelay.accept(fetchedResultsController.fetchedObjects ?? [])
        } catch {
            print("FRC performFetch error: \(error)")
        }
    }
}

extension ProductRepository: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let products = controller.fetchedObjects as? [Product] else { return }
        // Emit on main thread
        DispatchQueue.main.async {
            self.productsRelay.accept(products)
        }
    }
}

// MARK: - CRUD helpers
extension ProductRepository{
    func createProduct(data: ProductInfo){
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let product = Product(context: self.backgroundContext)
            product.id = UUID().uuidString
            product.savedAt = Date()
            product.name = data.name
            product.colorCode = data.colorCode
            product.rates = data.rates as NSArray
//            product.rates = (0..<4).map { _ in Double.random(in: 0...100) } as NSArray
            
            self.save(context: self.backgroundContext)
        }
    }

    func update(product: Product, newProduct: ProductInfo) {
        viewContext.perform {
            product.savedAt = Date()
            product.name = newProduct.name
            product.colorCode = newProduct.colorCode
            product.rates = newProduct.rates as NSArray
            self.save(context: self.viewContext)
        }
    }

    func delete(product: Product) {
        viewContext.perform {
            self.viewContext.delete(product)
            self.save(context: self.viewContext)
        }
    }

    private func save(context: NSManagedObjectContext) {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("CoreData Save Error: \(error)")
            context.rollback()
        }
    }
}
