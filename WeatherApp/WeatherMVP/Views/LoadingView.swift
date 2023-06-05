//
//  LoadingView.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 06.06.2023.
//

import UIKit

extension UIViewController {
    func startLoading() {
        let loadingView = LoadingView()
        view.addSubview(loadingView)
        loadingView.frame = UIScreen.main.bounds
        view.isUserInteractionEnabled = false
        loadingView.startLoading()
    }
    
    func stopLoading() {
        view.subviews.first(where: { $0 is LoadingView })?.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
}

class LoadingView: UIView {
    private(set) var activityIndicator = UIActivityIndicatorView()
    private let nonInteractionView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .clear
        nonInteractionView.backgroundColor = .black.withAlphaComponent(0.2)
        
        addSubview(nonInteractionView)
        nonInteractionView.translatesAutoresizingMaskIntoConstraints = false
        nonInteractionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nonInteractionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nonInteractionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nonInteractionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        nonInteractionView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: nonInteractionView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: nonInteractionView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
