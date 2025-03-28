import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
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
        VStack {
            Text(product.name ?? "Unknown")
                .font(.largeTitle)
                .padding()
            Text(product.productDescription ?? "No description")
                .font(.body)
                .padding()
            Text("Price: $\(product.price, specifier: "%.2f")")
                .font(.headline)
            Text("Provider: \(product.provider ?? "Unknown")")
                .font(.subheadline)
        }
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
}
