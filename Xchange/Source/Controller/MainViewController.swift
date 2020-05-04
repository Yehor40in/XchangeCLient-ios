//
//  MainViewController.swift
//  Xchange
//
//  Created by Yehor Sorokin on 19.02.2020.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import UIKit
import Starscream

///--------------------------------------------------------
/// - TODO:
///
///         - Implement blocking logic
///
///
///--------------------------------------------------------


final class MainViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private var captureManager: CaptureManaging!
    private var networkingManager: NetworkManaging!
    private var logManager: LogManager!
    
    
    // MARK: - Auxilaries
    
    private var animator: UIViewPropertyAnimator?
    private var logStorage: [LogItem] = []
    
    var wasDisconnected: Bool = false
    
    // MARK: - Subviews
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private lazy var contentView: UIView = {
        let contentHeight = view.bounds.height
        let contentWidth = view.bounds.width
        let rect = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        return UIView(frame: rect)
    }()
    
    private lazy var menu: MenuView = {
        let menu = MenuView()
        menu.translatesAutoresizingMaskIntoConstraints = false
        return menu
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            table.backgroundColor = UIColor.systemIndigo
        } else {
            table.backgroundColor = UIColor.systemPurple
        }
        table.dataSource = self
        table.delegate = self
        table.register(LogCell.self, forCellReuseIdentifier: "LogCell")
        table.rowHeight = Config.logCellHeight
        return table
    }()
    
    
    // MARK: - Setup
    
    private func basicSetup() -> Void {
        networkingManager = NetworkingManager.shared
        networkingManager.delegate = self
        networkingManager.setupLocationManager()
        
        captureManager = CaptureManager.shared
        captureManager.requestAuthorization()
        captureManager.output?.setSampleBufferDelegate(networkingManager, queue: captureManager.captureQueue)
        
        logManager = LogManager.standard
        logStorage = logManager.getData()
    }
    
    private func setupNavigationItem() -> Void {
        navigationItem.title = Config.mainNavigationItemTitle
    }
    
    private func setupNavigationBar() -> Void {
        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = false
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar.items = [navigationItem]
    }

    private func setupSubviews() -> Void {
        view.addSubview(contentView)
        contentView.addSubview(navigationBar)
        contentView.addSubview(tableView)
        view.insertSubview(menu, belowSubview: contentView)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }
    
    private func setupConstraints() -> Void {
        
        let menuTrailingConstant: CGFloat = -(view.bounds.width - Config.menuWidth)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            navigationBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: Config.navBarHeight),
            menu.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menu.topAnchor.constraint(equalTo: view.topAnchor),
            menu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: menuTrailingConstant),
            menu.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menu.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            menu.widthAnchor.constraint(equalToConstant: Config.menuWidth),
            menu.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func applyColorScheme() -> Void {
        if #available(iOS 13.0, *) {
            contentView.backgroundColor = UIColor.systemIndigo
        } else {
            contentView.backgroundColor = UIColor.systemPurple
        }
        navigationBar.barTintColor = UIColor.systemBlue
    }
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        basicSetup()
        setupNavigationItem()
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        applyColorScheme()
    }
    
    
    // MARK: - Side Menu Animating
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) -> Void {
        switch recognizer.state {
        case .began:
            setupAnimator()
        case .changed:
            updateAnimation(at: recognizer.translation(in: recognizer.view))
        default:
            let fraction = calculateFraction(using: recognizer.translation(in: recognizer.view))
            finishAnimation(using: fraction)
        }
    }
    
    private func calculateFraction(using translation: CGPoint) -> CGFloat {
        return menu.isExpanded ? translation.x / Config.menuWidth : abs(translation.x / Config.menuWidth)
    }
    
    private func setupAnimator() -> Void {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) { [weak self] in
            guard let self = self else { return }
            if !self.menu.isExpanded {
                self.contentView.frame.origin = CGPoint(x: Config.menuWidth, y: 0)
                self.menu.stackView.layoutMargins = Config.menuExpandedInsets
                self.menu.visualView.effect = nil
            } else {
                self.contentView.frame.origin = CGPoint(x: 0, y: 0)
                self.menu.stackView.layoutMargins = Config.menuHiddenInsets
                self.menu.visualView.effect = UIBlurEffect(style: .dark)
            }
            self.menu.isExpanded = !self.menu.isExpanded
            self.view.layoutIfNeeded()
        }
        animator?.pauseAnimation()
    }
    
    private func updateAnimation(at point: CGPoint) -> Void {
        animator?.fractionComplete = calculateFraction(using: point)
    }
    
    private func finishAnimation(using fraction: CGFloat) -> Void {
        if fraction > 0.5 {
            animator?.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
        } else {
            animator?.stopAnimation(false)
            animator?.finishAnimation(at: .start)
            animator = nil
        }
    }
    
}


// MARK: - TableView DataSource

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logStorage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell") as? LogCell else {
            return UITableViewCell()
        }
        cell.item = logStorage[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Activity"
    }

}


// MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Remove", handler: { [weak self ] _, _, _ in
            guard let self = self else { return }
            
            if self.logManager.deleteRecord(self.logStorage[indexPath.row]) {
                self.logStorage.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
            }
        })
        deleteAction.backgroundColor = UIColor.red
        
        let restrictAction = UIContextualAction(style: .normal, title: "Block", handler: { [weak self ] _, _, _ in
            
            /// TODO
            
        })
        restrictAction.backgroundColor = UIColor.gray
        
        return UISwipeActionsConfiguration(actions: [deleteAction, restrictAction])
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
        }
    }
    
}


// MARK: - Networking Manager Delegate

extension MainViewController: NetworkingManagerDelegate {
    
    func networkManager(_ manager: NetworkingManager, didChangeNetworkState state: NetworkState) {
        var alert: UIAlertController
        
        switch state {
        case .connected:
            alert = UIAlertController(title: Config.networkAlertEstablishedTitle, message: Config.networkAlertEstablishedMessage, preferredStyle: .alert)
            alert.view.backgroundColor = Config.networkAlertEstablishedColor
            alert.view.tintColor = Config.networkAlertTintColor
            alert.view.layer.cornerRadius = Config.alertCornerRadius
            
            let action = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            alert.addAction(action)
            
        case .disconnected:
            alert = UIAlertController(title: Config.networkAlertDisconnectedTitle, message: Config.networkAlertDisconnectedMessage, preferredStyle: .alert)
            alert.view.backgroundColor = Config.networkAlertDisconnectedColor
            alert.view.tintColor = Config.networkAlertTintColor
            alert.view.layer.cornerRadius = Config.alertCornerRadius
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            alert.addAction(okAction)
            alert.addAction(settingsAction)
        }
        
        if let _ = presentedViewController {
            dismiss(animated: true)
        }
        present(alert, animated: true)
    }

    
    func networkManager(_ manager: NetworkingManager, didConnectTo client: WebSocket, with headers: [String : String]?) {
        
        if let sourceAddress = client.request.url {
            let item = ConcreteLogItem(date: Date(), description: "Connected to \(sourceAddress)", status: .active)
            
            logManager.logQueue.async { [weak self] in
                guard let self = self else { return }
                
                if self.logManager.updateData(with: item, at: 0) {
                    self.logStorage.insert(item, at: 0)
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                    }
                }
                
            }
        }
        
    }
    
    
    func networkManager(_ manager: NetworkingManager, didDisconnectFrom client: WebSocket) {
        
        if let sourceAddress = client.request.url,
            let storage = self.logStorage as? [ConcreteLogItem] {
            guard
                let item = storage.first(where: {$0.description.contains("\(sourceAddress)") }),
                let row = storage.firstIndex(of: item) else {
                return
            }
            
            self.logStorage[row].status = .terminated
            item.status = .terminated
            
            logManager.logQueue.async { [weak self] in
                guard let self = self else { return }
                
                if self.logManager.updateData(with: item, at: row) {
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
                    }
                }
                
            }
        }
    }
    
}
