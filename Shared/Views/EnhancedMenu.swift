//
//  EnhancedMenu.swift
//  TeaElephant
//
//  Enhanced menu with tea-inspired design system
//

import SwiftUI

struct EnhancedMenu: View {
    @ObservedObject var appState = AppState.shared
    @State private var selectedCard: MenuCard? = nil
    @State private var showingProfile = false
    
    var pushNavigationBinding: Binding<Bool> {
        .init { () -> Bool in
            appState.pageToNavigationTo != nil
        } set: { (newValue) in
            if !newValue { appState.pageToNavigationTo = nil }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 0.89),
                        Color(red: 0.96, green: 0.94, blue: 0.89).opacity(0.8),
                        Color(red: 0.55, green: 0.71, blue: 0.55).opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                            .padding(.top, 20)
                        
                        // Menu Cards
                        VStack(spacing: 16) {
                            menuCard(
                                icon: "doc.text.magnifyingglass",
                                title: "Read Tea Info",
                                subtitle: "Scan NFC or QR tags",
                                color: Color(red: 0.55, green: 0.71, blue: 0.55),
                                destination: AnyView(EnhancedCardViewer())
                            )
                            
                            menuCard(
                                icon: "arkit",
                                title: "AR Explorer",
                                subtitle: "View collection in AR",
                                color: Color(red: 0.35, green: 0.51, blue: 0.35),
                                destination: AnyView(DetectorView().environmentObject(DetailManager()))
                            )
                            
                            menuCard(
                                icon: "plus.circle.fill",
                                title: "Add New Tea",
                                subtitle: "Write info to NFC/QR",
                                color: Color(red: 0.55, green: 0.43, blue: 0.31),
                                destination: AnyView(EnhancedNewCard())
                            )
                            
                            if #available(iOS 17.0, *) {
                                menuCard(
                                    icon: "leaf.circle",
                                    title: "My Collections",
                                    subtitle: "Manage your tea library",
                                    color: Color(red: 0.55, green: 0.71, blue: 0.55),
                                    destination: AnyView(UserAreaUIView(authManager: AuthManager.shared))
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Statistics Section
                        statisticsSection
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            }
            .overlay(
                NavigationLink(
                    destination: DestinatoinUIView(
                        id: appState.id ?? "",
                        message: appState.notificationMessage ?? ""
                    ),
                    isActive: pushNavigationBinding
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TeaElephant")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.35, green: 0.51, blue: 0.35))
                    
                    Text("Your Digital Tea Collection")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Profile Button
                if #available(iOS 17.0, *) {
                    NavigationLink(destination: UserAreaUIView(authManager: AuthManager.shared)) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.55, green: 0.71, blue: 0.55),
                                            Color(red: 0.35, green: 0.51, blue: 0.35)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 22))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Menu Card
    private func menuCard(icon: String, title: String, subtitle: String, color: Color, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                // Icon Container
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
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(MenuCardButtonStyle())
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.35, green: 0.51, blue: 0.35))
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                statCard(number: "0", label: "Teas", icon: "leaf.fill", color: Color(red: 0.55, green: 0.71, blue: 0.55))
                statCard(number: "0", label: "Collections", icon: "folder.fill", color: Color(red: 0.55, green: 0.43, blue: 0.31))
                statCard(number: "0", label: "Tags", icon: "tag.fill", color: Color(red: 0.35, green: 0.51, blue: 0.35))
            }
        }
    }
    
    private func statCard(number: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(number)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
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

// MARK: - Menu Card Model
struct MenuCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

struct EnhancedMenu_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedMenu()
    }
}