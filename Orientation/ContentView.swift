//
//  ContentView.swift
//  Orientation
//
//  Created by Heliodoro Tejedor Navarro on 12/30/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: OrientationDocument
    @State var showCamera = false
    
    var body: some View {
        Form {
            Section {
                Text(document.text)
            } header: {
                Text("Example")
            }
        }
        .toolbar {
            Button {
                showCamera = true
            } label: {
                Label("Camera", systemImage: "camera")
            }
        }
        .sheet(isPresented: $showCamera, restrictInterfaceOrientationTo: .portrait, modalTransitionStyle: .crossDissolve, animated: false) {
            print("bye bye")
        } content: {
            VStack(spacing: 20) {
                Spacer()
                Text("Show Camera Preview here")
                Button {
                    showCamera = false
                } label: {
                    Text("Close")
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView(document: .constant(OrientationDocument()))
        }
    }
}
