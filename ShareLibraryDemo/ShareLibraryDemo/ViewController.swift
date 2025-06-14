//
//  ViewController.swift
//  ShareLibraryDemo
//
//  Created by Rafael Valer - Personal on 07/05/23.
//

import SharedLibrary
import UIKit

class MyViewController: UIViewController {
    
    private lazy var button: UIButton = {
        let button = UIButton(configuration: .bordered())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Share", for: .normal)
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func shareTapped() {
        let vc = ShareImagePreviewViewController(requiredData: .init(image: UIImage(named: "patolino")!,
                                                                     backgroundType: .image(UIImage(named: "background")!),
                                                                     facebookId: "my-facebook-id"))
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

