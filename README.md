# Orientation

I am creating an iOS document app that shows a camera preview as a main view. My plan is to show 
the camera only in portrait, allowing the rest of the interface to rotate as convenience.

## Using an AppDelegate

My first thought was using the `supportedInterfaceOrientationsFor` at the AppDelegate. This is 
implemented in the files `AppDelegate.swift` and settings the delegate adaptor in the `App` struct
(check the `OrientationApp.swift` file). 

On each view, you can set the supported interfaces using the modifier `orientationLockModifier(mask:)`:

````swift

    struct ContentView: View {
        @State var showSheet = false
        
        var body: some View {
            Button {
                showSheet = true
            } label: {
                Text("Click me")
            }
            .orientationLockModifier(mask: .landscape)
            .sheet(isPresented: $showSheet) {
                Form {
                    Button {
                        showSheet = false
                    } label: {
                        Text("Close")
                    }
                    Text("This is the view")
                }
                .orientationLockModifier(mask: .portrait)
            }
        }
    }
````

It works pretty decent, but it does weird animations every time a new view is shown.

## Using UIKit

The second approach is using UIKit to show the sheet. It only works when the interface shows
view controllers that must be in restricted orientation.

Simple example:

````swift

    struct ContentView: View {
        @State var showCamera = false
        
        var body: some View {
            Form {
                Section {
                    Text("Hello")
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
            .orientationLockModifier(mask: .portrait)
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
````

In this case, the `sheet` modifier is added allowing the user to set the modal transition (check UIKit help),
as well as if the animation is needed.

This second approach reduces the animations and it solves most of my interface issues.

I hope this would help you, good luck!
