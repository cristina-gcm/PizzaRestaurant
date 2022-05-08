
import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Order.entity(), sortDescriptors: [], predicate: NSPredicate(format: "status != %@", Status.completed.rawValue))

    
    var orders: FetchedResults<Order>
    
    struct GradientBackgroundStyle: ButtonStyle {
     
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color("LightGreen")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(40)
                .padding(.horizontal, 20)
        }
    }
    
    @State var showOrderSheet = false
    
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(orders) { order in
                    GeometryReader {geo in
                        ZStack{
                            
                        Image("bg")
                            .opacity(0.8)
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width:geo.size.width,
                                   height:geo.size.height,
                                   alignment: .center)
                            Image("brown")
                                .resizable()
                                .cornerRadius(16)
                                      
                                
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 1) {
                            
                            Text("\(order.pizzaType) - \(order.numberOfSlices) slices")
                                .font(.headline)
                                .padding(8)
                                .foregroundColor(.white)
                                
                            
                            Text("Table \(order.tableNumber)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {
                            
                            updateOrder(order: order)
                        })
                        
                        {
                            Text(order.orderStatus == .pending ? "Prepare" : "Complete")
                                .foregroundColor(.green)
                                .padding(10)
                                .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder()
                                                .foregroundColor(.green))
                                
                        }
                            }}}
                        .frame(height: 50)
                }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewContext.delete(orders[index])
                        }
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
            }
                .listStyle(PlainListStyle())
                .navigationTitle("**My Orders**")
                .navigationBarItems(trailing: Button(action: {
                    showOrderSheet = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                }))
                .sheet(isPresented: $showOrderSheet) {
                    OrderSheet()
                }
        }
        }
    
    func updateOrder(order: Order) {
        let newStatus = order.orderStatus == .pending ? Status.preparing : .completed
        viewContext.performAndWait {
            order.orderStatus = newStatus
            try? viewContext.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
