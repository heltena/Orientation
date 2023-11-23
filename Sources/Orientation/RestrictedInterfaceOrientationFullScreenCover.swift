//
//  RestrictedInterfaceOrientationFullScreenCover.swift
//  Orientation
//
//  Created by Heliodoro Tejedor Navarro on 1/3/23.
//

import UIKit
import SwiftUI

public enum ModalTransitionStyle: Int, @unchecked Sendable {
    case coverVertical = 0
    case flipHorizontal = 1
    case crossDissolve = 2
    
    fileprivate var uiKitVersion: UIModalTransitionStyle {
        return UIModalTransitionStyle(rawValue: self.rawValue)!
    }
}

public struct RestrictedInterfaceOrientationFullScreenCover<SheetContent: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var restrictInterfaceOrientationTo: UIInterfaceOrientationMask
    var modalTransitionStyle: ModalTransitionStyle
    var animated: Bool
    var content: () -> SheetContent
    
    public init(isPresented: Binding<Bool>, restrictInterfaceOrientationTo: UIInterfaceOrientationMask, modalTransitionStyle: ModalTransitionStyle, animated: Bool, content: @escaping () -> SheetContent) {
        self._isPresented = isPresented
        self.restrictInterfaceOrientationTo = restrictInterfaceOrientationTo
        self.modalTransitionStyle = modalTransitionStyle
        self.animated = animated
        self.content = content
    }
    
    public func makeUIViewController(context: Context) -> InternalViewController {
        InternalViewController()
    }
    
    public func updateUIViewController(_ uiViewController: InternalViewController, context: Context) {
        if !isPresented {
            uiViewController.presentedViewController?.dismiss(animated: animated)
            return
        }
        
        if uiViewController.presentedViewController == nil {
            let sheetViewController = PortraitHostingViewController(restrictInterfaceOrientationTo: restrictInterfaceOrientationTo, rootView: content())
            sheetViewController.modalPresentationStyle = .overFullScreen // don't use .fullscreen, so it will remove the parent from the view hierarchy!
            sheetViewController.modalTransitionStyle = modalTransitionStyle.uiKitVersion
            uiViewController.present(sheetViewController, animated: animated)
            return
        }
        
        if let presentedViewController = uiViewController.presentedViewController as? UIHostingController<SheetContent> {
            presentedViewController.rootView = content()
            return
        }

        fatalError("Invalid parent when dismissing a presented view controller")
    }

    public class InternalViewController: UIViewController {
        public override func loadView() {
            super.loadView()
            view.backgroundColor = .clear
        }
    }
    
    class PortraitHostingViewController<Content: View>: UIHostingController<Content> {
        var restrictInterfaceOrientationTo: UIInterfaceOrientationMask
        
        init(restrictInterfaceOrientationTo: UIInterfaceOrientationMask, rootView: Content) {
            self.restrictInterfaceOrientationTo = restrictInterfaceOrientationTo
            super.init(rootView: rootView)
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            restrictInterfaceOrientationTo
        }
    }
}

struct RestrictedInterfaceOrientationFullScreenCoverViewModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var restrictInterfaceOrientationTo: UIInterfaceOrientationMask
    var modalTransitionStyle: ModalTransitionStyle
    var animated: Bool
    @ViewBuilder var content: () -> SheetContent
    
    func body(content: Content) -> some View {
        content
            .background {
                RestrictedInterfaceOrientationFullScreenCover(
                    isPresented: $isPresented,
                    restrictInterfaceOrientationTo: restrictInterfaceOrientationTo,
                    modalTransitionStyle: modalTransitionStyle,
                    animated: animated,
                    content: self.content)
            }
    }
}

extension View {
    public func fullScreenCover<SheetContent: View>(isPresented: Binding<Bool>, restrictInterfaceOrientationTo: UIInterfaceOrientationMask = .portrait, modalTransitionStyle: ModalTransitionStyle = .crossDissolve, animated: Bool = true, onDismiss: (() -> Void)?, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(
            RestrictedInterfaceOrientationFullScreenCoverViewModifier(
                isPresented: isPresented,
                restrictInterfaceOrientationTo: restrictInterfaceOrientationTo,
                modalTransitionStyle: modalTransitionStyle,
                animated: animated,
                content: content))
    }
}
