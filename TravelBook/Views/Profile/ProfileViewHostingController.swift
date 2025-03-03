//
//  NewProfileView.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 11/15/24.
//
import FirebaseAuth
import SwiftUI
import UIKit

class ProfileViewHostingController: UIHostingController<ProfileView> {
    // Custom initializer
    init(userName: String) {
        // Create the ProfileView
        let profileView = ProfileView(userName: userName, hostingController: nil)
        
        // Initialize the super class
        super.init(rootView: profileView)
        
        // Assign the hosting controller to the ProfileView
        rootView.hostingController = self
        
        navigationController?.navigationBar.isTranslucent = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
            // Configure the navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // Make the navigation bar non-transparent
            appearance.backgroundColor = UIColor.white // Set a background color (e.g., white)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Optional: Set title color
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] // Optional: Set large title color
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance // For compact heights
            navigationController?.navigationBar.isTranslucent = false // Disable translucency
            
            // Set navigation items
            navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                                                                                                         style: .plain,
                                                                                                         target: self,
                                                                                                         action: #selector(logoutMessage))
            navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
            navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                                                                         style: .plain,
                                                                                                         target: self,
                                                                                                         action: #selector(navigateToSettings))
            navigationController?.topViewController?.navigationItem.leftBarButtonItem?.tintColor = .black
            
            navigationController?.navigationBar.isHidden = false // Ensure the navigation bar is visible
    }
    
    public func didTapOnAchievements() {
        navigationController?.pushViewController(AchievementsViewHostingController(), animated: true)
    }
    
    public func didTapOnCountriesVisited() {
        navigateToVisitedCountries()
    }
    
    @objc func logoutMessage() {
        let alert = UIAlertController(title: "Log Out", message: "You're going to log out. Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let logoutAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.logout()
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        self.present(alert, animated: true)
    }
    
    @objc func navigateToSettings() {
        let settingsController = SettingsViewController(nibName: "SettingsView", bundle: nil)
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    func navigateToVisitedCountries() {
        let visitedCountriesController = VisitedCountriesViewController(nibName: "VisitedCountriesView", bundle: nil)
        navigationController?.pushViewController(visitedCountriesController, animated: true)
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            
            if let loginVC = self.navigationController?.viewControllers.filter({ $0 is LoginViewController }).first {
                navigationController?.setNavigationBarHidden(true, animated: false)
                self.navigationController?.popToViewController(loginVC, animated: true)
            }
        } catch {
            print("Error login out: \(error.localizedDescription)")
        }
    }
    
    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
