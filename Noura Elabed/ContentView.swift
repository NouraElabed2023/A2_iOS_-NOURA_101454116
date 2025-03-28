import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var searchText = ""
    @State private var showAddProductView = false  // Track when to show AddProductView
    
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
                // Search Bar
                TextField("Search Products", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)

                // Product List
                List {
                    ForEach(filteredProducts, id: \.self) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            ProductRow(product: product)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color(.systemGray5))
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAddProductView = true
                        }) {
                            Label("Add Product", systemImage: "plus")
                        }
                    }
                }
            }
            .background(Color(.systemGray5))
            .sheet(isPresented: $showAddProductView) {
                AddProductView(isPresented: $showAddProductView)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

// MARK: - Product Row UI Component
struct ProductRow: View {
    var product: Product
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(product.productDescription ?? "No description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(product.price, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Add Product View
struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var productDescription = ""
    @State private var price = ""
    @State private var provider = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $name)
                    TextField("Description", text: $productDescription)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Provider", text: $provider)
                }
                
                Section {
                    Button(action: addProduct) {
                        Text("Add Product")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("New Product")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addProduct() {
        guard let priceValue = Double(price) else { return }
        
        let newProduct = Product(context: viewContext)
        newProduct.id = UUID()
        newProduct.name = name
        newProduct.productDescription = productDescription
        newProduct.price = priceValue
        newProduct.provider = provider
        
        do {
            try viewContext.save()
            isPresented = false
        } catch {
            print("Error saving product: \(error)")
        }
    }
}

// MARK: - Product Detail View
struct ProductDetailView: View {
    var product: Product
    
    var body: some View {
        VStack(spacing: 16) {
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

// MARK: - Core Data Setup
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

// MARK: - Preview
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
