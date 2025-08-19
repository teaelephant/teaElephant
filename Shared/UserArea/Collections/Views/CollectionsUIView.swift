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
    var onDelete: (() -> Void)? = nil
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
            
            // Delete button if onDelete is provided
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.red.opacity(0.7))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
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
    @State private var hasLoadedInitially = false
    @State private var showingSignOutAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let error = manager.error {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.vibrantOrange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unable to load collections")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.teaTextPrimaryAlt)
                            
                            Text(error.localizedDescription)
                                .font(.system(size: 14))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        Task {
                            manager.error = nil
                            await manager.getCollections(forceReload: true)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text("Retry")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.vibrantOrange)
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.vibrantOrange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.vibrantOrange.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
            }
            NavigationStack {
                let _ = print("CollectionsUIView - collectionsLoading: \(manager.collectionsLoading), collections.count: \(manager.collections.count), error: \(String(describing: manager.error))")
                // Show loading if actively loading OR if this is initial load with no collections
                if manager.collectionsLoading || (!hasLoadedInitially && manager.collections.isEmpty) {
                    ZStack {
                        // Liquid glass background
                        LiquidBackground(
                            primaryColor: Color.teaPrimaryAlt,
                            secondaryColor: Color.vibrantBlue
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 24) {
                            // Animated loading indicator
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.teaPrimaryAlt.opacity(0.2),
                                                Color.vibrantGreen.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .blur(radius: 20)
                                
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.teaPrimaryAlt)
                                    .symbolEffect(.pulse.byLayer, options: .repeating, value: true)
                            }
                            
                            VStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.teaPrimaryAlt))
                                    .scaleEffect(1.2)
                                
                                Text("Loading your tea collections...")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.teaTextSecondaryAlt)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.glassBorder, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .navigationBarTitle("Collections")
                } else if manager.collections.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Engaging animated empty state
                        ZStack {
                            // Background glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.teaPrimaryAlt.opacity(0.2),
                                            Color.vibrantGreen.opacity(0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 120
                                    )
                                )
                                .frame(width: 240, height: 240)
                                .blur(radius: 20)
                            
                            // Main icon with glass effect
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.glassBorder, Color.teaPrimaryAlt.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: Color.glassShadow, radius: 15, y: 5)
                                
                                // Tea cup and leaf composition
                                VStack(spacing: -10) {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color.vibrantGreen)
                                        .rotationEffect(.degrees(-15))
                                    
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color.teaPrimaryAlt)
                                }
                            }
                            
                            // Floating tea leaves animation
                            ForEach(0..<3) { index in
                                Image(systemName: "leaf")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.vibrantGreen.opacity(0.4))
                                    .offset(
                                        x: index == 0 ? -60 : (index == 1 ? 60 : 0),
                                        y: index == 2 ? -70 : (index == 0 ? -30 : 30)
                                    )
                                    .rotationEffect(.degrees(Double(index * 120)))
                                    .animation(
                                        Animation.easeInOut(duration: 3)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.5),
                                        value: UUID()
                                    )
                            }
                        }
                        
                        VStack(spacing: 12) {
                            Text("Start Your Tea Journey")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.teaPrimaryAlt, Color.vibrantGreen],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Create collections to organize your favorite teas\nand track your tea-drinking journey")
                                .font(.system(size: 16))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.teaTextSecondaryAlt)
                                .lineSpacing(4)
                                .padding(.horizontal)
                            
                            // Benefits with icons
                            HStack(spacing: 20) {
                                benefitPill(icon: "tag.fill", text: "Organize")
                                benefitPill(icon: "chart.bar.fill", text: "Track")
                                benefitPill(icon: "sparkles", text: "Discover")
                            }
                            .padding(.top, 8)
                        }
                        
                        // Enhanced add collection input for empty state
                        VStack(spacing: 12) {
                            Text("Create Your First Collection")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.teaTextSecondaryAlt)
                            
                            HStack(spacing: 12) {
                                TextField("Collection name", text: $name)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.glassBorder, lineWidth: 1)
                                            )
                                    )
                                    .frame(maxWidth: 250)
                                
                                Button(action: {
                                    Task{
                                        await manager.addCollection(name: name)
                                        name = ""
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Create")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.teaPrimaryAlt,
                                                        Color.vibrantGreen
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .opacity(name.isEmpty ? 0.5 : 1)
                                    )
                                    .shadow(color: Color.teaPrimaryAlt.opacity(name.isEmpty ? 0 : 0.3), radius: 6, y: 3)
                                }
                                .disabled(name.isEmpty)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: name.isEmpty)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        Spacer()
                    }
                    .navigationBarTitle("Collections")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Enhanced Add new collection card with glass design
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color.vibrantGreen)
                                    
                                    Text("Add New Collection")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.teaTextPrimaryAlt)
                                }
                                
                                HStack(spacing: 12) {
                                    // Text field with glass style
                                    TextField("Collection name", text: $name)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.glassBorder, lineWidth: 1)
                                                )
                                        )
                                    
                                    // Create button with glass effect
                                    Button(action: {
                                        Task {
                                            await manager.addCollection(name: name)
                                            name = ""
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18))
                                            Text("Create")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.vibrantGreen,
                                                            Color.teaPrimaryAlt
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .opacity(name.isEmpty ? 0.5 : 1)
                                        )
                                        .shadow(color: Color.vibrantGreen.opacity(name.isEmpty ? 0 : 0.3), radius: 6, y: 3)
                                    }
                                    .disabled(name.isEmpty)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: name.isEmpty)
                                }
                            }
                            .padding(20)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.vibrantGreen.opacity(0.05),
                                                Color.teaPrimaryAlt.opacity(0.03)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.glassBorder,
                                                        Color.vibrantGreen.opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            }
                            .shadow(color: Color.glassShadow, radius: 10, y: 4)
                            
                            // Collections list with better visual hierarchy
                            ForEach($manager.collections.indices, id: \.self) { index in
                                Group {
                                    NavigationLink(destination: CollectionUIView(manager: manager, collection: $manager.collections[index])) {
                                        SimpleCollectionCard(
                                            name: manager.collections[index].name,
                                            count: manager.collections[index].records.count,
                                            onDelete: {
                                                collectionToDelete = manager.collections[index].id
                                                showingDeleteAlert = true
                                            }
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
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingSignOutAlert = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.red.opacity(0.8))
                            }
                        }
                    }
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
                    .alert("Sign Out", isPresented: $showingSignOutAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Sign Out", role: .destructive) {
                            // Clear collections first
                            manager.collections = []
                            AuthManager.shared.signOut()
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to sign out? You'll need to sign in again to access your collections.")
                    }
                }
            }
            
        }
        .onAppear {
            print("CollectionsUIView onAppear - hasLoadedInitially: \(hasLoadedInitially), collectionsLoading: \(manager.collectionsLoading)")
            // Load collections when view appears if not already loading
            if !hasLoadedInitially && !manager.collectionsLoading {
                print("CollectionsUIView - Calling getCollections")
                Task {
                    // Small delay to ensure auth is ready after sign-in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                    hasLoadedInitially = true
                    await manager.getCollections()
                    print("CollectionsUIView - getCollections completed")
                }
            }
        }
    }
    
    // Helper view for benefit pills in empty state
    private func benefitPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(Color.teaPrimaryAlt)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.teaPrimaryAlt.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color.teaPrimaryAlt.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CollectionsUIView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsUIView(manager: CollectionsManager())
    }
}
