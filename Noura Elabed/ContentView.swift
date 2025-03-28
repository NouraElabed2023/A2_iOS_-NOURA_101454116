import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var searchText = ""
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return Array(products)
        } else {
            return products.filter { product in
                product.name?.localizedCaseInsensitiveContains(searchText) == true ||
                product.productDescription?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Products", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                List {
                    ForEach(filteredProducts, id: \..self) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.name ?? "Unknown")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text(product.productDescription ?? "No description")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addProduct) {
                            Label("Add Product", systemImage: "plus")
                        }
                    }
                }
            }
            .background(Color(.systemGray5))
        }
    }
    
    private func addProduct() {
        let newProduct = Product(context: viewContext)
        newProduct.id = UUID()
        newProduct.name = "New Product"
        newProduct.productDescription = "Product Description"
        newProduct.price = 10.0
        newProduct.provider = "Provider"
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving product: \(error)")
        }
    }
}

struct ProductDetailView: View {
    var product: Product
    
    var body: some View {
        VStack(spacing: 20) {
            Text(product.name ?? "Unknown")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(product.productDescription ?? "No description")
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Text("Price: $\(product.price, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Provider: \(product.provider ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Product")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
