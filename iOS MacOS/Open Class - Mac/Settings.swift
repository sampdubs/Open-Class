//
//  Settings.swift
//  Open Class
//
//  Created by Sam Prausnitz-Weinbaum on 9/1/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct Settings: View {
    @State var update = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.showSheet = false
                }) {
                    Text("Done")
                }
                Spacer()
            }
            Spacer()
            HStack {
                VStack {
                    Text("Class name")
                    ForEach(0..<5, id: \.self) {i in
                        HStack {
                            Text(["8:30", "8:50", "10:15", "12:10", "1:35"][i])
                            Spacer()
                            TextField("Enter period \(i + 1) class name here", text: BindingName(i, self.$update).name)
                                .frame(width: 200)
                        }
                        .frame(width: 250)
                    }
                    .padding()
                }
                VStack {
                    Text("Link to class zoom")
                    ForEach(0..<5, id: \.self) {i in
                        TextField("Enter period \(i + 1) zoom link here", text: BindingLink(i, self.$update).link)
                            .frame(minWidth: 500)
                    }
                    .padding()
                }
            }
            Text(update ? " " : "  ")
                .hidden()
            Spacer()
        }
        .padding()
    }
}

class BindingLink: ObservableObject {
    private var __link__: String
    var link: Binding<String>
    
    @Binding var update: Bool
    public init(_ i: Int, _ bindingUpdate: Binding<Bool>) {
        self.__link__ = (UserDefaults.standard.array(forKey: "zoomLinks") as? [String] ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5))[i]
        
        self.link = Binding<String> (
            get: {
                return ""
            },
            set: { toSet in
            }
        )
        
        self._update = bindingUpdate
        
        self.link = Binding<String> (
            get: {
                return self.__link__
            },
            set: { toSet in
                self.__link__ = toSet
                self.update.toggle()
                DispatchQueue.global(qos: .userInitiated).async {
                    var current = UserDefaults.standard.array(forKey: "zoomLinks") as? [String] ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5)
                    current[i] = toSet
                    UserDefaults.standard.set(current, forKey: "zoomLinks")
                }
            }
        )
    }
}

class BindingName: ObservableObject {
    private var __name__: String
    var name: Binding<String>
    
    @Binding var update: Bool
    public init(_ i: Int, _ bindingUpdate: Binding<Bool>) {
        self.__name__ = (UserDefaults.standard.array(forKey: "classNames") as? [String] ?? Array(repeating: "Class name not set", count: 5))[i]
        
        name = Binding<String> (
            get: {
                return ""
            },
            set: { toSet in
            }
        )
        
        self._update = bindingUpdate
        
        name = Binding<String> (
            get: {
                return self.__name__
            },
            set: { toSet in
                self.__name__ = toSet
                self.update.toggle()
                DispatchQueue.global(qos: .userInitiated).async {
                    var current = UserDefaults.standard.array(forKey: "classNames") as? [String] ?? Array(repeating: "Class name not set", count: 5)
                    current[i] = toSet
                    UserDefaults.standard.set(current, forKey: "classNames")
                }
            }
        )
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(showSheet: .constant(false))
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
