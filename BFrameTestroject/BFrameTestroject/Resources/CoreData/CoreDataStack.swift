//
//  CoreDataManager.swift
//  BFrameTestroject
//
//  Created by paololee on 11/14/25.
//

import UIKit
import CoreData

class CoreDataStack{
    static let shared: CoreDataStack = CoreDataStack(modelName: "BFrameTestroject")
    
    private let modelName: String
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }
    var backgroundContext: NSManagedObjectContext! //Background에서 동작
    
    private init(modelName: String){
        self.modelName = modelName
        container = NSPersistentContainer(name: modelName)

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error loading store: \(error)")
            }
        }

        //데이터 저장관련
        //backgroundContext의 변경사항을 viewContext가 자동으로 반영
        container.viewContext.automaticallyMergesChangesFromParent = true
        //데이터충돌(merge Conflict)발생 시 현재 컨텍스트의 값을 우선
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        //UI업데이트를 막지않기 위해 background용 Context를 따로 생성
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
//            fatalError(error.localizedDescription)
        }
    }
}
