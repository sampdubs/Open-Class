//
//  Settings.swift
//  Open Class - iOS
//
//  Created by Sam Prausnitz-Weinbaum on 9/2/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct Settings: View {
    @Binding var update: Bool
    @Environment(\.presentationMode) var presentationMode
    
    func makeLinkBinding(_ i: Int) -> Binding<String>{
        return Binding<String> (
            get: {
                return (UserDefaults.standard.array(forKey: "zoomLinks") as? [String] ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5))[i]
        },
            set: { toSet in
                var current = UserDefaults.standard.array(forKey: "zoomLinks") as? [String] ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5)
                current[i] = toSet
                UserDefaults.standard.set(current, forKey: "zoomLinks")
                self.update.toggle()
        }
        )
    }
    
    func makeNameBinding(_ i: Int) -> Binding<String>{
        return Binding<String> (
            get: {
                return (UserDefaults.standard.array(forKey: "classNames") as? [String] ?? Array(repeating: "Class name not set", count: 5))[i]
        },
            set: { toSet in
                var current = UserDefaults.standard.array(forKey: "classNames") as? [String] ?? Array(repeating: "Class name not set", count: 5)
                current[i] = toSet
                UserDefaults.standard.set(current, forKey: "classNames")
                self.update.toggle()
        }
        )
    }
    
    var body: some View {
         
        ScrollView {
            Text("Class name and Zoom link")
            ForEach(0..<5, id: \.self) {i in
                HStack {
                    Text(["8:30", "8:50", "10:15", "12:10", "1:35"][i])
                    Spacer()
                    VStack {
                        TextField("Enter period \(i + 1) class name here", text: self.makeNameBinding(i))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Enter period \(i + 1) zoom link here", text: self.makeLinkBinding(i))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()
            Text(update ? " " : "  ")
                .hidden()
            Spacer()
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(update: .constant(false))
            .onAppear {
                UserDefaults.standard.set([
                    "https://atlantapublicschools-us.zoom.us/j/9810763587?pwd=OXBmMkU0eTYyK2JockxJZG13d3pyQT09",
                    "https://atlantapublicschools-us.zoom.us/j/83151288446?pwd=OERkRWMxdGM3UmRzQUUyRHFXKzNkZz09",
                    "https://atlantapublicschools-us.zoom.us/j/84717885279?pwd=L0ZtaDAzWXMxN2hqVmZ3QmY5YVlPQT09",
                    "https://atlantapublicschools-us.zoom.us/j/83020266109?pwd=bUh3eit3eG5BYTV5WFFON0xHK0NqZz09",
                    "https://atlantapublicschools-us.zoom.us/j/85152004164?pwd=bElXSVY4b0c1L21zS2xaTWYrNU15dz09"
                ], forKey: "zoomLinks")
        }
    }
}
