//
//  DetailVC.swift
//  BFrameTestroject
//
//  Created by paololee on 11/19/25.
//

import UIKit
import RxSwift
import RxCocoa

class DetailVC: UIViewController {
    private let product: Product
    private let viewModel: ProductViewModel
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let nameTextView: UITextView = UITextView()
    private let backgroundColorWell: UIColorWell = UIColorWell()
    private let savedLabel: UILabel = UILabel()
    private let updateButton: UIButton = UIButton()
    private let deleteButton: UIButton = UIButton()
    
    init(product: Product, viewModel: ProductViewModel) {
        self.product = product
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewConfig()
        bindViewModel()
    }

}

#Preview("DetailVC"){
    return UINavigationController(rootViewController: MainVC())
}

//MARK: - Function
extension DetailVC{
    private func bindViewModel(){
        backgroundColorWell.rx.colorDidChange
            .subscribe(onNext: {[weak self] color in
                self?.view.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        let newName = nameTextView.rx.text.orEmpty.asObservable()
        let newColor = backgroundColorWell.rx.selectedColor.compactMap{$0}
        updateButton.rx.tap
            .withLatestFrom(Observable.combineLatest(newName, newColor))
            .map{ name, color in
                ProductInfo(name: name, colorCode: color.toHexString(), rates: [])
            }
            .subscribe(onNext: { [weak self] newProduct in
                guard let self = self else{return}
                self.viewModel.updateProductAction.accept((self.product, newProduct))
                self.savedLabel.text = formatted(date: Date())
                print("정보가 수정되었습니다.")
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else{return}
                self.viewModel.deleteProductAction.accept(self.product)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc private func didTapGesture(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    private func formatted(date: Date?) -> String? {
        guard let date = date else{return nil}
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

//MARK: - SETUP
extension DetailVC{
    private func setViewConfig(){
//        setNavigation()
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
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        [nameTextView].forEach{
            $0.text = product.name
            $0.backgroundColor = .white
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 30)
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.textAlignment = .center
            $0.textContainer.maximumNumberOfLines = 1
        }
        [backgroundColorWell].forEach{
            $0.supportsAlpha = false
            $0.selectedColor = UIColor(hexCode: product.colorCode ?? "#FFFFFF")
            self.view.backgroundColor = UIColor(hexCode: product.colorCode ?? "#FFFFFF")
        }
        [savedLabel].forEach{
            $0.text = formatted(date: product.savedAt)
            $0.font = .systemFont(ofSize: 16)
        }
        
        [updateButton, deleteButton].forEach{
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }
        [updateButton].forEach{
            $0.setTitle("Update", for: .normal)
            $0.backgroundColor = .green
        }
        [deleteButton].forEach{
            $0.setTitle("Delete", for: .normal)
            $0.backgroundColor = .red
        }
        
    }
    
    private func setUI(){
        let productStack: UIStackView = UIStackView()
        let buttonStack: UIStackView = UIStackView()
        [nameTextView, backgroundColorWell, savedLabel].forEach{
            productStack.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [productStack].forEach{
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 20
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [updateButton, deleteButton].forEach{
            buttonStack.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [buttonStack].forEach{
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fillEqually
            $0.spacing = 30
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            productStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            productStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productStack.bottomAnchor.constraint(lessThanOrEqualTo: buttonStack.topAnchor, constant: 30),
            
            nameTextView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60),
            nameTextView.heightAnchor.constraint(equalToConstant: 50),
            
            updateButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor),
            updateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
