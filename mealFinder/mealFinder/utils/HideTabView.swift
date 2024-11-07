//
//  HideTabView.swift
//  mealFinder
//
//  Created by Shujie on 11/7/24.
//

import SwiftUI

struct HideTabBarView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HideTabBarController {
        return HideTabBarController()
    }

    func updateUIViewController(_ uiViewController: HideTabBarController, context: Context) {}
}

class HideTabBarController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tabBarController?.tabBar.isHidden = false
    }
}
