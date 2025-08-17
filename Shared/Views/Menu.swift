//
//  Menu.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 19.07.2020.
//

import SwiftUI

// Import the design system extensions from TeaElephantDesign.swift
// Note: Since these are in the same module, they should be available

struct Menu: View {
    @ObservedObject var appState = AppState.shared
    @StateObject private var collectionsManager = CollectionsManager()
    @State private var showingProfile = false
    @State private var showingDestination = false
    @State private var hasLoadedCollections = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid glass background
                LiquidBackground(
                    primaryColor: Color.teaPrimaryAlt,
                    secondaryColor: Color.vibrantBlue
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                            .padding(.top, 20)
                        
                        // Tea of the Day Widget
                        TeaOfTheDayWidget(manager: collectionsManager)
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                        
                        // Menu Cards
                        VStack(spacing: 16) {
                            menuCard(
                                icon: "doc.text.magnifyingglass",
                                title: "Read Tea Info",
                                subtitle: "Scan NFC or QR tags",
                                color: Color(red: 0.55, green: 0.71, blue: 0.55),
                                destination: AnyView(EnhancedCardViewer()),
                                accessibilityLabel: "Read Tea Information",
                                accessibilityHint: "Scan NFC or QR tags to view tea details"
                            )
                            
                            menuCard(
                                icon: "arkit",
                                title: "AR Explorer",
                                subtitle: "View collection in AR",
                                color: Color(red: 0.35, green: 0.51, blue: 0.35),
                                destination: AnyView(DetectorView().environmentObject(DetailManager())),
                                accessibilityLabel: "Augmented Reality Explorer",
                                accessibilityHint: "View your tea collection in augmented reality"
                            )
                            
                            menuCard(
                                icon: "plus.circle.fill",
                                title: "Add New Tea",
                                subtitle: "Write info to NFC/QR",
                                color: Color(red: 0.55, green: 0.43, blue: 0.31),
                                destination: AnyView(MultiStepNewCard()),
                                accessibilityLabel: "Add New Tea",
                                accessibilityHint: "Write tea information to NFC tags or QR codes"
                            )
                            
                            menuCard(
                                icon: "leaf.circle",
                                title: "My Collections",
                                subtitle: "Manage your tea library",
                                color: Color(red: 0.55, green: 0.71, blue: 0.55),
                                destination: AnyView(UserAreaUIView(authManager: AuthManager.shared)),
                                accessibilityLabel: "My Tea Collections",
                                accessibilityHint: "Manage and organize your tea library"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                
                // Load collections for Tea of the Day widget
                if !hasLoadedCollections {
                    Task {
                        await collectionsManager.getCollections()
                        hasLoadedCollections = true
                    }
                }
            }
            .onChange(of: appState.pageToNavigationTo) { _, newValue in
                showingDestination = (newValue != nil)
            }
            .navigationDestination(isPresented: $showingDestination) {
                DestinatoinUIView(
                    id: appState.id ?? "",
                    message: appState.notificationMessage ?? ""
                )
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TeaElephant")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .if(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil) { view in
                            view.glassTextStyle(color: Color.teaAccentAlt)
                        }
                        .foregroundColor(Color.teaAccentAlt)
                        .dynamicTypeSize(.medium ... .accessibility2)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Tea Elephant")
                    
                    Text("Your Digital Tea Collection")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .if(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil) { view in
                            view.glassTextStyle(color: .secondary)
                        }
                        .dynamicTypeSize(.small ... .accessibility3)
                        .accessibilityLabel("Your Digital Tea Collection")
                }
                
                Spacer()
                
                // Profile Button with glass effect
                NavigationLink(destination: UserAreaUIView(authManager: AuthManager.shared)) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.glassBorder,
                                                Color.teaPrimaryAlt.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.teaPrimaryAlt.opacity(0.2), radius: 6, x: 0, y: 3)
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(Color.teaPrimaryAlt)
                            .font(.system(size: 22))
                            .if(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil) { view in
                                view.vibrantTextStyle(color: Color.teaPrimaryAlt)
                            }
                    }
                }
                .accessibilityLabel("Profile")
                .accessibilityHint("Tap to view your profile and collections")
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Menu Card with Glass Effect
    private func menuCard(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        destination: AnyView,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                // Icon Container with glass effect
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.glassBorder.opacity(0.5), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 0)
                }
                
                // Text Content with glass text style
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .if(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil) { view in
                            view.glassTextStyle()
                        }
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow with subtle animation
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.glassBorder,
                                        color.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: color.opacity(0.15), radius: 10, x: 0, y: 4)
            }
        }
        .buttonStyle(MenuCardButtonStyle())
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityHint(accessibilityHint ?? subtitle)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Button Style
struct MenuCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}