//
//  CreateAccountView.swift
//  TodoList
//
//  Created by Andrew Mankin on 11/23/25.
//

import SwiftUI
import CoreData

struct CreateAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    TextField("Name",text: $name)
                    TextField("email", text: $email)
                    TextField("password", text: $password)
                }
                Section{
                    Button("Create Account"){
                        if !name.isEmpty && !email.isEmpty && !password.isEmpty {
                            let newUser = User(context: viewContext)
                            newUser.id = UUID()
                            newUser.name = name
                            newUser.email = email
                            newUser.password = password
                            do {
                                try viewContext.save()
                            } catch{
                                errorMessage = "Failed to save user: \(error)"
                            }
                        }else{
                            errorMessage = "Please fill in all fields"
                        }
                    }
                    if !errorMessage.isEmpty{
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
            }.navigationTitle(Text("Create Account"))
        }
    }
}

#Preview {
    CreateAccountView()
}
