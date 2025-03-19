//
//  ContentView.swift
//  CoreDataDemo
//
//  Created by Alina Nicorescu on 11.03.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var name: String = ""
    @State var quantity: String = ""
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @FetchRequest(entity: Product().entity, sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
    
    private var products: FetchedResults<Product>
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Product Name", text: $name)
                TextField("Quantity", text: $quantity)
                
                HStack {
                    Spacer()
                    Button("Add") {
                        addProduct()
                    }
                    Spacer()
                    
                    NavigationLink("Find", destination: ResultsView(name: name, viewContext: managedObjectContext))
                                   
                    Button("Clear") {
                        name = ""
                        quantity = ""
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                
                List {
                    ForEach(products) { product in
                        HStack {
                            Text(product.name ?? "NOT FOUND")
                            Text(product.quantity ?? "NOT FOUND")
                        }
                    }
                    .onDelete(perform: deleteProducts)
                }
                .navigationTitle("Product Database")
            }
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private func addProduct() {
        withAnimation {
            let product = Product(context: managedObjectContext)
            product.name = name
            product.quantity = quantity
            
            saveContext()
        }
    }
    
    private func deleteProducts(offsets: IndexSet) {
        withAnimation {
            offsets.map { products[$0] }.forEach (managedObjectContext.delete)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            let error = error as NSError
            fatalError("An error occurred: \(error)")
        }
    }
}

struct ResultsView: View {
    
    var name: String
    var viewContext: NSManagedObjectContext
    @State var matches: [Product]?
    
    var body: some View {
        
        return VStack {
            List {
                ForEach(matches ?? []) { match in
                    HStack {
                        Text(match.name ?? "Not found")
                        Spacer()
                        Text(match.quantity ?? "Not found")
                    }
                }
            }
            .navigationTitle("Results")
        }
        .task {
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            
            fetchRequest.entity = Product.entity()
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
            do {
                matches = try viewContext.fetch(fetchRequest)
            } catch {
                print("Failed to fetch products: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
