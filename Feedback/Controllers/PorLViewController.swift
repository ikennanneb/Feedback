//
//  ViewController.swift
//  Feedback
//
//  Created by Ikenna on 3/7/24.
//

import UIKit
import FirebaseAuth

class PorLViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth()
    {
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

    
}

