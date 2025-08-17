//
//  CollectionsUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import SwiftUI
import TeaElephantSchema

// Enhanced collection card with glassmorphism design
struct SimpleCollectionCard: View {
    let name: String
    let count: Int
    @State private var isAnimating = false
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with glass effect
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.vibrantBlue.opacity(0.3),
                                Color.teaPrimaryAlt.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                    .background(.ultraThinMaterial, in: Circle())
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.teaPrimaryAlt)
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .shadow(color: Color.teaPrimaryAlt.opacity(0.3), radius: 2, x: 0, y: 0)
            }
            
            // Content with glass text styling
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .if(isHovered) { view in
                        view.glassTextStyle()
                    }
                
                HStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.vibrantOrange)
                        .vibrantTextStyle(color: Color.vibrantOrange)
                    Text(count == 1 ? "tea" : "teas")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron with glass effect
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.glassBorder,
                                    Color.teaPrimaryAlt.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.glassShadow, radius: 8, x: 0, y: 3)
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                isAnimating = true
            }
        }
        // Remove onTapGesture as it interferes with NavigationLink
    }
}

// Custom button style for proper tap feedback
struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Helper extension for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

@available(iOS 18.0, *)
struct CollectionsUIView: View {
    @ObservedObject var manager: CollectionsManager
    @State private var name = ""
    @State private var collectionToDelete: String? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack {
            if let error = manager.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Network error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            NavigationStack {
                if manager.collectionsLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your tea collections...")
                            .foregroundColor(.secondary)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear{
                        Task{
                            await manager.getCollections()
                        }
                    }
                    .navigationBarTitle("Collections")
                } else if manager.collections.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        Image(systemName: "leaf.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("No Tea Collections Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Start by creating your first collection to organize your tea inventory")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack {
                            TextField("Collection name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 250)
                            Button(action: {
                                Task{
                                    await manager.addCollection(name: name)
                                    name = ""
                                }
                            }) {
                                Label("Create", systemImage: "plus.circle.fill")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .disabled(name.isEmpty)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .navigationBarTitle("Collections")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Add new collection card
                            HStack {
                                TextField("New collection name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: {
                                    Task {
                                        await manager.addCollection(name: name)
                                        name = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                                .disabled(name.isEmpty)
                                .foregroundColor(name.isEmpty ? .gray : Color(red: 0.55, green: 0.71, blue: 0.55))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            
                            // Collections list with better visual hierarchy
                            ForEach($manager.collections.indices, id: \.self) { index in
                                Group {
                                    NavigationLink(destination: CollectionUIView(manager: manager, collection: $manager.collections[index])) {
                                        SimpleCollectionCard(
                                            name: manager.collections[index].name,
                                            count: manager.collections[index].records.count
                                        )
                                    }
                                    .buttonStyle(ScaledButtonStyle())
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.05),
                                        value: manager.collections.count
                                    )
                                    .contextMenu {
                                        Button(action: {
                                            collectionToDelete = manager.collections[index].id
                                            showingDeleteAlert = true
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.3))
                    .navigationBarTitle("My Tea Collections")
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Collection"),
                            message: Text("Are you sure you want to delete this collection? This action cannot be undone."),
                            primaryButton: .cancel(Text("Cancel")) {
                                collectionToDelete = nil
                            },
                            secondaryButton: .destructive(Text("Delete")) {
                                if let id = collectionToDelete {
                                    Task {
                                        await manager.deleteCollection(id: id)
                                        collectionToDelete = nil
                                    }
                                }
                            }
                        )
                    }
                }
            }
            
        }
    }
}

struct CollectionsUIView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsUIView(manager: CollectionsManager())
    }
}
