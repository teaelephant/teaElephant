//
//  CollectionsUIView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 11/08/2023.
//

import SwiftUI
import TeaElephantSchema

// Enhanced collection card with tea-inspired design
struct SimpleCollectionCard: View {
    let name: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.3),
                                Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 0.55, green: 0.71, blue: 0.55))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.55, green: 0.43, blue: 0.31))
                    Text(count == 1 ? "tea" : "teas")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
    }
}

@available(iOS 18.0, *)
struct CollectionsUIView: View {
    @ObservedObject var manager: CollectionsManager
    @State private var name = ""
    @State private var collectionToDelete: String? = nil
    @State private var showingDeleteAlert = false
    var body: some View {
        VStack{
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
            NavigationView {
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
                            ForEach($manager.collections, id: \.id) { $collection in
                                Group {
                                    if #available(iOS 17.0, *) {
                                        NavigationLink(destination: CollectionUIView(manager: manager, collection: $collection)) {
                                            SimpleCollectionCard(
                                                name: collection.name,
                                                count: collection.records.count
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .contextMenu {
                                            Button(action: {
                                                collectionToDelete = collection.id
                                                showingDeleteAlert = true
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    } else {
                                        SimpleCollectionCard(
                                            name: collection.name,
                                            count: collection.records.count
                                        )
                                        .onTapGesture {
                                            // iOS 14-16 fallback - just show the card without navigation
                                        }
                                        .onLongPressGesture {
                                            collectionToDelete = collection.id
                                            showingDeleteAlert = true
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
        if #available(iOS 14.0, *) {
            CollectionsUIView(manager: CollectionsManager())
        } else {
            Text("Unsupported")
        }
    }
}
