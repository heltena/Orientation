//
//  ContentView.swift
//  Orientation
//
//  Created by Heliodoro Tejedor Navarro on 12/30/22.
//

import SwiftUI

struct ConfigView: View {
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            Text("Hello")
                .navigationTitle("Config")
                .toolbar {
                    Button(action: dismiss) {
                        Text("Done")
                    }
                }
        }
    }
}

struct ContentView: View {
    @Binding var document: OrientationDocument
    @State var showConfig = false
    
    var body: some View {
        TextEditor(text: $document.text)
            .toolbar {
                Button {
                    showConfig = true
                } label: {
                    Label("Config", systemImage: "gear")
                }
            }
            .fullScreenCover(isPresented: $showConfig) {
                ConfigView() {
                    showConfig = false
                }
                .orientationLockModifier(mask: .all)
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
