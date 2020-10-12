//
//  Settings.swift
//  Open Class
//
//  Created by Sam Prausnitz-Weinbaum on 9/1/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct Settings: View {
    @Binding var update: Bool
    @Binding var classTimes: [Date]
    
    let hideSheet: () -> ()
    
    private func setupClassTimes(_ times: [String]) {
        self.classTimes = []
        for t in times {
            let time = t.components(separatedBy: ":")
            self.classTimes.append(Calendar.current.date(bySettingHour: Int(time[0]) ?? 0, minute: Int(time[1]) ?? 0, second: 0, of: Date())!)
        }
    }
    
    private func addClass() {
        var links = UserDefaults.standard.array(forKey: "zoomLinks") ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5)
        links.append("")
        UserDefaults.standard.set(links, forKey: "zoomLinks")
        
        var names = UserDefaults.standard.array(forKey: "classNames") ?? Array(repeating: "Class name not set", count: 5)
        names.append("")
        UserDefaults.standard.set(names, forKey: "classNames")
        
        var times = (UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"])
        times.append("0:0")
        UserDefaults.standard.set(times, forKey: "classTimes")
        self.setupClassTimes(times as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35", "0:0"])
        
        self.update.toggle()
    }
    
    private func deleteClass(_ i: Int) {
        var links = UserDefaults.standard.array(forKey: "zoomLinks") ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5)
        links.remove(at: i)
        UserDefaults.standard.set(links, forKey: "zoomLinks")
        
        var names = UserDefaults.standard.array(forKey: "classNames") ?? Array(repeating: "Class name not set", count: 5)
        names.remove(at: i)
        UserDefaults.standard.set(names, forKey: "classNames")
        
        var times = (UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"])
        times.remove(at: i)
        UserDefaults.standard.set(times, forKey: "classTimes")
        self.setupClassTimes(times as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35"])
        
        self.update.toggle()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.hideSheet()
                }) {
                    Text("Done")
                }
                Spacer()
            }
            Spacer()
            VStack {
                HStack {
                    VStack{
                        Text("Class Time (24 hr)")
                        ForEach(0..<classTimes.count, id: \.self) {i in
                            HStack {
                                TextField("Hour", text: BindingHour(i, self.$update, self.$classTimes).hour)
                                    .frame(width: 35)
                                Text(":")
                                TextField("Minute", text: BindingMinute(i, self.$update, self.$classTimes).minute)
                                    .frame(width: 35)
                            }
                        }
                        .padding()
                    }
                    VStack {
                        Text("Class name")
                        ForEach(0..<classTimes.count, id: \.self) {i in
                            HStack {
                                TextField("Enter period \(i + 1) class name here", text: BindingName(i, self.$update).name)
                                    .frame(width: 200)
                            }
                            .frame(width: 250)
                        }
                        .padding()
                    }
                    VStack {
                        Text("Link to class zoom")
                        ForEach(0..<classTimes.count, id: \.self) {i in
                            TextField("Enter period \(i + 1) zoom link here", text: BindingLink(i, self.$update).link)
                                .frame(minWidth: 500)
                        }
                        .padding()
                    }
                    VStack {
                        Text(" ")
                        ForEach(0..<classTimes.count, id: \.self) {i in
                            Button(action: {
                                self.deleteClass(i)
                            }) {
                                Text("X")
                                    .bold()
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                    }
                }
                Button(action: {
                    self.addClass()
                }) {
                    Text("Add Class")
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

class BindingHour: ObservableObject {
    private var __hour__: String
    var hour: Binding<String>
    
    @Binding var update: Bool
    @Binding var classTimes: [Date]
    public init(_ i: Int, _ bindingUpdate: Binding<Bool>, _ bindingClassTimes: Binding<[Date]>) {
        self.__hour__ = String(Int((((UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]) as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35"])[i]).components(separatedBy: ":")[0]) ?? 0)
        
        hour = Binding<String> (
            get: {
                return ""
            },
            set: { toSet in
            }
        )
        
        self._update = bindingUpdate
        self._classTimes = bindingClassTimes
        
        hour = Binding<String> (
            get: {
                return self.__hour__
            },
            set: { toSet in
                let toSetInt = Int(toSet) ?? 24
                if (toSetInt >= 0 && toSetInt < 24) || toSet == "" {
                    self.__hour__ = toSet
                    self.update.toggle()
                    DispatchQueue.global(qos: .userInitiated).async {
                        var current = (UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]) as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]
                        let thisMinute = current[i].components(separatedBy: ":")[1]
                        self.classTimes[i] = Calendar.current.date(bySettingHour: Int(toSet) ?? 0, minute: Int(thisMinute) ?? 0, second: 0, of: Date())!
                        current[i] = "\(toSet):\(thisMinute)"
                        UserDefaults.standard.set(current, forKey: "classTimes")
                    }
                }
            }
        )
    }
}

class BindingMinute: ObservableObject {
    private var __minute__: String
    var minute: Binding<String>
    
    @Binding var update: Bool
    @Binding var classTimes: [Date]
    public init(_ i: Int, _ bindingUpdate: Binding<Bool>, _ bindingClassTimes: Binding<[Date]>) {
        self.__minute__ = String(Int((((UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]) as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35"])[i]).components(separatedBy: ":")[1]) ?? 0)
        
        minute = Binding<String> (
            get: {
                return ""
            },
            set: { toSet in
            }
        )
        
        self._update = bindingUpdate
        self._classTimes = bindingClassTimes
        
        minute = Binding<String> (
            get: {
                return self.__minute__
            },
            set: { toSet in
                let toSetInt = Int(toSet) ?? 60
                if (toSetInt >= 0 && toSetInt < 60) || toSet == "" {
                    self.__minute__ = toSet
                    self.update.toggle()
                    DispatchQueue.global(qos: .userInitiated).async {
                        var current = (UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]) as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]
                        let thisHour = current[i].components(separatedBy: ":")[0]
                        self.classTimes[i] = Calendar.current.date(bySettingHour: Int(thisHour) ?? 0, minute: Int(toSet) ?? 0, second: 0, of: Date())!
                        current[i] = "\(thisHour):\(toSet)"
                        UserDefaults.standard.set(current, forKey: "classTimes")
                    }
                }
            }
        )
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(update: .constant(false), classTimes: .constant([
            Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 8, minute: 50, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 12, minute: 10, second: 0, of: Date())!,
            Calendar.current.date(bySettingHour: 13, minute: 35, second: 0, of: Date())!
        ]), hideSheet: {})
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
