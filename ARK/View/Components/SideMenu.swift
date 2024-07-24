//
//  SideMenu.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-04-20.
//

import SwiftUI
import RiveRuntime
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SideMenu: View {
    @State private var myProfile: User?
    @AppStorage ("log_status") var logStatus: Bool = false
    
    @AppStorage ("first_name") var firstNameStored: String = ""
    @AppStorage ("last_name") var lastNameStored: String = ""
    @AppStorage ("user_role") var roleStored: String = ""
    
    @AppStorage ("selectedMenu") var selectedMenu: SelectedMenu = .home
    @Binding var menuIsOpen: Bool
    var isOpen = false
    
    var button = RiveViewModel(fileName: "menu_button", stateMachineName: "State Machine", autoPlay: false)
    
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                
                HStack {
                    Image(systemName: "person")
                        .padding(12)
                        .background(.white.opacity(0.2))
                        .mask(Circle())
                    
                    
                    if (firstNameStored != "" && lastNameStored != ""){
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(firstNameStored) \(lastNameStored)")
                            
                            Text("\(roleStored)")
                                .font(.subheadline)
                                .opacity(0.7)
                        }
                        Spacer()
                    }
                    else{
                        VStack(alignment: .leading, spacing: 2) {
                            Text("User Name")
                            
                            Text("User Role")
                                .font(.subheadline)
                                .opacity(0.7)
                        }
                        Spacer()
                    }
                }
                .padding()
                
                Text("BROWSE")
                    .font(.subheadline).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .opacity(0.7)
                
                browse
                
                if (roleStored == "Developer" || roleStored == "Priest"){
                    Text("EXCLUSIVE")
                        .font(.subheadline).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        .opacity(0.7)
                    
                    options
                }
                Spacer()
            }
            
            .foregroundColor(.white)
            .frame(maxWidth: 288, maxHeight: .infinity)
            .background(Color("InverseAccentColor"))
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color(hex: "17203A").opacity(0.3), radius: 40, x: 0, y: 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            button.view()
                .frame(width: 44, height: 44)
                .mask(Circle())
                .shadow(color: Color("Shadow").opacity(0.2), radius: 5, x: 0, y: 5)
                .frame(maxWidth: 120, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top)
            
                .onTapGesture {
                    
                    button.setInput("isOpen", value: false)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        menuIsOpen.toggle()
                    }
                }
            
            
        }
        .onChange(of: selectedMenu) { newSelectedMenu in
            if menuIsOpen {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    menuIsOpen = false
                }
            }
        }
        
    }
    
    var browse: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(menuItems) { item in
                Rectangle()
                    .frame(height: 1)
                    .opacity(0.1)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 14) {
                    if (item.img != nil) {
                        Image(systemName: "\(item.img!)")
                            .opacity(0.6)
                            .padding(5)
                    } else{
                        item.icon.view()
                            .frame(width: 32, height: 32)
                            .opacity(0.6)
                    }
                    Text(item.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.blue)
                        .frame(maxWidth: selectedMenu == item.menu ? .infinity : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .background(Color("InverseAccentColor"))
                .onTapGesture {
                    withAnimation(.timingCurve(0.2, 0.8, 0.2, 1)) {
                        selectedMenu = item.menu
                    }
                    item.icon.setInput("active", value: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        item.icon.setInput("active", value: false)
                    }
                }
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
    }
    
    var options: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(menuItems2) { item in
                Rectangle()
                    .frame(height: 1)
                    .opacity(0.1)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 14) {
                    if (item.img != nil) {
                        Image(systemName: "\(item.img!)")
                            .opacity(0.6)
                            .padding(2)
                    } else{
                        item.icon.view()
                            .frame(width: 32, height: 32)
                            .opacity(0.6)
                    }
                    Text(item.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.blue)
                        .frame(maxWidth: selectedMenu == item.menu ? .infinity : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .background(Color("InverseAccentColor"))
                .onTapGesture {
                    withAnimation(.timingCurve(0.2, 0.8, 0.2, 1)) {
                        selectedMenu = item.menu
                    }
                    item.icon.setInput("active", value: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        item.icon.setInput("active", value: false)
                    }
                }
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
    }
    
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(menuIsOpen: .constant(false))
    }
}

struct MenuItem: Identifiable {
    var id = UUID()
    var text: String
    var icon: RiveViewModel
    var menu: SelectedMenu
    var img: String?
}

var menuItems = [
    MenuItem(text: "Home", icon: RiveViewModel(fileName: "icons", stateMachineName: "HOME_interactivity", artboardName: "HOME"), menu: .home),
    MenuItem(text: "Give", icon: RiveViewModel(fileName: "icons", stateMachineName: "TIMER_Interactivity", artboardName: "TIMER"), menu: .notifications, img: "heart")
]

var menuItems2 = [
    MenuItem(text: "Main Directory", icon: RiveViewModel(fileName: "icons", stateMachineName: "STAR_Interactivity", artboardName: "LIKE/STAR"), menu: .favorites),
    MenuItem(text: "Developer Tools", icon: RiveViewModel(fileName: "icons", stateMachineName: "TIMER_Interactivity", artboardName: "TIMER"), menu: .history, img: "sunglasses.fill")
]

enum SelectedMenu: String {
    case home
    case search
    case favorites
    case help
    case history
    case notifications
}
