//
//  AppDelegate.swift
//  Orientation
//
//  Created by Heliodoro Tejedor Navarro on 12/30/22.
//

import Foundation
import SwiftUI

@MainActor
public class AppDelegate: NSObject, ObservableObject, UIApplicationDelegate {
    private var orientationLocks: [UIWindow: [UIInterfaceOrientationMask]] = [:]

    private func orientationLock(for window: UIWindow?) -> UIInterfaceOrientationMask {
        if let window, let peek = orientationLocks[window]?.last {
            return peek
        } else {
            return .all
        }
    }
    
    fileprivate func pushOrientationLock(to: UIInterfaceOrientationMask, for window: UIWindow?) {
        guard let window else { return }
        var values = orientationLocks[window] ?? []
        values.append(to)
        orientationLocks[window] = values
        UIView.performWithoutAnimation {
            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    fileprivate func popOrientationLock(for window: UIWindow?) {
        guard let window else { return }
        if var locks = orientationLocks[window] {
            locks.removeLast()
            if locks.isEmpty {
                orientationLocks.removeValue(forKey: window)
            } else {
                orientationLocks[window] = locks
            }
        }
        UIView.performWithoutAnimation {
            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        orientationLock(for: window)
    }
    
    public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

public class SceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate {
    public var window: UIWindow?
    @Published public var orientation: UIDeviceOrientation
    
    public override init() {
        orientation = .unknown
        super.init()
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: UIDevice.current, queue: .main) { [weak self] notification in
            let orientation = UIDevice.current.orientation
            if orientation != .unknown {
                UIView.performWithoutAnimation {                    
                    self?.orientation = orientation
                }
            }
        }
    }
    
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = windowScene.keyWindow
    }
}

public struct OrientationLockModifier: ViewModifier {
    @EnvironmentObject private var appDelegate: AppDelegate
    @EnvironmentObject private var sceneDelegate: SceneDelegate

    private let mask: UIInterfaceOrientationMask
    
    public init(mask: UIInterfaceOrientationMask) {
        self.mask = mask
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                appDelegate.pushOrientationLock(to: mask, for: sceneDelegate.window)
            }
            .onDisappear {
                appDelegate.popOrientationLock(for: sceneDelegate.window)
            }
    }
}

extension View {
    public func orientationLockModifier(mask: UIInterfaceOrientationMask) -> some View {
        modifier(OrientationLockModifier(mask: mask))
    }
}
