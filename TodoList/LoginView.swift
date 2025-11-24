//
//  LoginView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/23/25.
//

import SwiftUI
import CoreData

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var email = ""
    @State private var password = ""
    @State private var loggedInUser: User? = nil
    @State private var errorMessage = ""
    
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var users: FetchedResults<User>
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    TextField("email", text: $email)
                    TextField("password", text: $password)
                }
                Section{
                    Button("Log in"){
                        if let user = users.first(where: {$0.email == email && $0.password == password}){
                            loggedInUser = user
                        } else {
                            errorMessage = "Invalid Login"
                        }
                    }
                    if loggedInUser != nil{
                        Text("Welcom \(loggedInUser!.name!)")
                    }
                    if !errorMessage.isEmpty{
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
                Section{
                    Button("Sign Up"){
                        
                    }
                }
            }.navigationTitle(Text("Login"))
        }
    }
}

#Preview {
    LoginView()
}
