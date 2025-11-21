//
//  ViewController.swift
//  BFrameTestroject
//
//  Created by paololee on 11/12/25.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData
import RxDataSources

class MainVC: UIViewController {
    private let viewModel: ProductViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let mainCollctionView: UICollectionView
    private let bottomSubView: UIView = UIView()
    private let addButton: UIButton = UIButton()
    
    init(viewModel: ProductViewModel = ProductViewModel()){
        self.mainCollctionView = UICollectionView(frame: .zero, collectionViewLayout: MainVC.createCompositionalLayout())
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder){ fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewConfig()
        bindViewModel()
    }

}


#Preview("MainVC"){
    return UINavigationController(rootViewController: MainVC())
}

//MARK: - Function
extension MainVC{
    private func bindViewModel(){
        let dataSource = RxCollectionViewSectionedReloadDataSource<ProductSection>(configureCell: {dataSource, collectionView, indexPath, item in
            guard let cell: ProductCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionCell.identifier, for: indexPath) as? ProductCollectionCell else{ return UICollectionViewCell()}
            cell.configure(with: item)
            return cell
        })
        viewModel.products
            .map{[ProductSection(items: $0)]}
            .observe(on: MainScheduler.instance)
            .bind(to: mainCollctionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(onNext: {[weak self] in
                let newName: String = ["아이폰", "갤럭시 폴드", "플레이스테이션", "청소기", "전기밥솥", "키보드", "마우스", "헤드셋", "스피커", "노트북"].randomElement() ?? "상품이름"
                let newColor: String = UIColor().RandomColor().toHexString()
                let newRates: [Double] = (0..<4).map { _ in Double.random(in: 0...10) }
                self?.viewModel.addProductAction.accept(ProductInfo(name: newName, colorCode: newColor, rates: newRates))
            })
            .disposed(by: disposeBag)
        
        mainCollctionView.rx.modelSelected(Product.self)
            .subscribe(onNext: {[weak self] product in
                guard let self = self else{return}
                let nextVC = DetailVC(product: product, viewModel: self.viewModel)
                self.navigationController?.pushViewController(nextVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - SETUP
extension MainVC{
    private func setViewConfig(){
        setNavigation()
        setAttribute()
        setUI()
    }
    
    private func setNavigation(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .foregroundColor : UIColor.white,
            .font : UIFont.boldSystemFont(ofSize: 22)
        ]
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setAttribute(){
        view.backgroundColor = .white
        
        [mainCollctionView].forEach{
            $0.backgroundColor = .white
            $0.register(ProductCollectionCell.self, forCellWithReuseIdentifier: ProductCollectionCell.identifier)
        }
        
        [addButton].forEach{
            $0.setTitle("+", for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 30)
            $0.setTitleColor(.black, for: .normal)
            $0.backgroundColor = .systemGreen
            $0.layer.cornerRadius = 12
        }
    }
    
    private func setUI(){
        [mainCollctionView, bottomSubView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [addButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomSubView.addSubview($0)
        }
        
        
        NSLayoutConstraint.activate([
            mainCollctionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainCollctionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCollctionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainCollctionView.bottomAnchor.constraint(equalTo: bottomSubView.topAnchor),
            
            bottomSubView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSubView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSubView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSubView.heightAnchor.constraint(equalToConstant: 80),
            
            addButton.centerXAnchor.constraint(equalTo: bottomSubView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: bottomSubView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: bottomSubView.leadingAnchor, constant: 60),
            addButton.topAnchor.constraint(equalTo: bottomSubView.topAnchor, constant: 16),
        ])
    }
    
    private static func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout{
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            //Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.49), heightDimension: .fractionalWidth(0.49))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let space: CGFloat = UIScreen.main.bounds.size.width / 30
            item.contentInsets = NSDirectionalEdgeInsets(top: space, leading: space, bottom: space, trailing: space)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.49))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
}
