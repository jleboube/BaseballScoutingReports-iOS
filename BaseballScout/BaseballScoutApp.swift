import SwiftUI
import Foundation
import AuthenticationServices
import LocalAuthentication
import Security

// MARK: - Data Models
struct User: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let groupName: String?
    let isAdmin: Bool
    let appleIdentifier: String?
}

struct Team: Codable, Identifiable {
    let id: Int
    let name: String
}

struct RegistrationCode: Codable, Identifiable {
    let id: UUID
    let code: String
    let teamName: String
    let isActive: Bool
    let createdAt: Date
    let maxUses: Int
    let currentUses: Int
    
    init(code: String, teamName: String, maxUses: Int = 50) {
        self.id = UUID()
        self.code = code
        self.teamName = teamName
        self.isActive = true
        self.createdAt = Date()
        self.maxUses = maxUses
        self.currentUses = 0
    }
}

struct AppUser: Codable, Identifiable {
    let id: Int
    var firstName: String
    var lastName: String
    var email: String
    var groupName: String?
    var isAdmin: Bool
    let createdAt: Date
    var appleIdentifier: String?
    
    init(id: Int, firstName: String, lastName: String, email: String, groupName: String?, isAdmin: Bool = false, appleIdentifier: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.groupName = groupName
        self.isAdmin = isAdmin
        self.createdAt = Date()
        self.appleIdentifier = appleIdentifier
    }
}

struct ScoutingReport: Codable, Identifiable {
    let id: Int
    var playerName: String
    var primaryPosition: String
    var jerseyNumber: String
    var dateOfBirth: Date
    var age: String
    var height: String
    var weight: String
    var bats: String
    var throwsHand: String
    var team: String
    var parentGuardian: String
    var contact: String
    var scoutName: String
    var scoutDate: Date
    var event: String
    var leagueOrganization: String
    var build: String
    var coordination: String
    var athleticism: String
    var stanceSetup: String
    var swingMechanics: String
    var contactAbility: String
    var powerPotential: String
    var speed: String
    var baseRunningIq: String
    var stealingAbility: String
    var fieldingReadiness: String
    var gloveWork: String
    var armStrength: String
    var armAccuracy: String
    var biggestStrengths: String
    var improvementAreas: String
    var notes: String
    var createdAt: Date
    
    init() {
        self.id = Int.random(in: 1000...9999)
        self.playerName = ""
        self.primaryPosition = ""
        self.jerseyNumber = ""
        self.dateOfBirth = Date()
        self.age = ""
        self.height = ""
        self.weight = ""
        self.bats = ""
        self.throwsHand = ""
        self.team = ""
        self.parentGuardian = ""
        self.contact = ""
        self.scoutName = ""
        self.scoutDate = Date()
        self.event = ""
        self.leagueOrganization = ""
        self.build = ""
        self.coordination = ""
        self.athleticism = ""
        self.stanceSetup = ""
        self.swingMechanics = ""
        self.contactAbility = ""
        self.powerPotential = ""
        self.speed = ""
        self.baseRunningIq = ""
        self.stealingAbility = ""
        self.fieldingReadiness = ""
        self.gloveWork = ""
        self.armStrength = ""
        self.armAccuracy = ""
        self.biggestStrengths = ""
        self.improvementAreas = ""
        self.notes = ""
        self.createdAt = Date()
    }
}

struct ReportListItem: Identifiable {
    let id: Int
    let playerName: String
    let primaryPosition: String
    let team: String
    let scoutName: String
    let date: String
}

// MARK: - Data Manager
class DataManager: ObservableObject {
    static let shared = DataManager()
    private let userDefaultsKey = "ScoutingReports"
    private let registrationCodesKey = "RegistrationCodes"
    private let usersKey = "AppUsers"
    
    @Published var reports: [ScoutingReport] = []
    @Published var registrationCodes: [RegistrationCode] = []
    @Published var users: [AppUser] = []
    
    init() {
        loadReports()
        loadRegistrationCodes()
        loadUsers()
    }
    
    func saveReport(_ report: ScoutingReport) {
        if let index = reports.firstIndex(where: { $0.id == report.id }) {
            reports[index] = report
        } else {
            reports.append(report)
        }
        saveToUserDefaults()
    }
    
    func deleteReport(id: Int) {
        reports.removeAll { $0.id == id }
        saveToUserDefaults()
    }
    
    func getReport(id: Int) -> ScoutingReport? {
        return reports.first { $0.id == id }
    }
    
    // MARK: - Registration Code Management
    func addRegistrationCode(code: String, teamName: String, maxUses: Int = 50) {
        let newCode = RegistrationCode(code: code, teamName: teamName, maxUses: maxUses)
        registrationCodes.append(newCode)
        saveRegistrationCodes()
    }
    
    func validateRegistrationCode(_ code: String) -> (isValid: Bool, teamName: String?) {
        guard let regCode = registrationCodes.first(where: {
            $0.code.lowercased() == code.lowercased() &&
            $0.isActive &&
            $0.currentUses < $0.maxUses
        }) else {
            return (false, nil)
        }
        return (true, regCode.teamName)
    }
    
    func useRegistrationCode(_ code: String) {
        if let index = registrationCodes.firstIndex(where: { $0.code.lowercased() == code.lowercased() }) {
            var updatedCode = registrationCodes[index]
            updatedCode = RegistrationCode(
                code: updatedCode.code,
                teamName: updatedCode.teamName,
                maxUses: updatedCode.maxUses
            )
            saveRegistrationCodes()
        }
    }
    
    func deleteRegistrationCode(id: UUID) {
        registrationCodes.removeAll { $0.id == id }
        saveRegistrationCodes()
    }
    
    // MARK: - User Management
    func addUser(_ user: AppUser) {
        if let index = users.firstIndex(where: {
            $0.email == user.email ||
            ($0.appleIdentifier != nil && $0.appleIdentifier == user.appleIdentifier)
        }) {
            users[index] = user
        } else {
            users.append(user)
        }
        saveUsers()
    }
    
    func updateUserAdminStatus(userId: Int, isAdmin: Bool) {
        if let index = users.firstIndex(where: { $0.id == userId }) {
            var updatedUser = users[index]
            updatedUser.isAdmin = isAdmin
            users[index] = updatedUser
            saveUsers()
        }
    }
    
    func getUser(email: String) -> AppUser? {
        return users.first { $0.email == email }
    }
    
    func getUser(id: Int) -> AppUser? {
        return users.first { $0.id == id }
    }
    
    func getUser(appleIdentifier: String) -> AppUser? {
        return users.first { $0.appleIdentifier == appleIdentifier }
    }
    
    func deleteUser(id: Int) {
        users.removeAll { $0.id == id }
        saveUsers()
    }
    
    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(reports) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadReports() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedReports = try? JSONDecoder().decode([ScoutingReport].self, from: data) {
            reports = decodedReports
        } else {
            addDemoData()
        }
    }
    
    private func saveRegistrationCodes() {
        if let data = try? JSONEncoder().encode(registrationCodes) {
            UserDefaults.standard.set(data, forKey: registrationCodesKey)
        }
    }
    
    private func loadRegistrationCodes() {
        if let data = UserDefaults.standard.data(forKey: registrationCodesKey),
           let decodedCodes = try? JSONDecoder().decode([RegistrationCode].self, from: data) {
            registrationCodes = decodedCodes
        } else {
            addDemoRegistrationCodes()
        }
    }
    
    private func saveUsers() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decodedUsers = try? JSONDecoder().decode([AppUser].self, from: data) {
            users = decodedUsers
        } else {
            addDemoUsers()
        }
    }
    
    private func addDemoData() {
        var report1 = ScoutingReport()
        report1.playerName = "John Smith"
        report1.primaryPosition = "SS"
        report1.team = "Eagles"
        report1.scoutName = "Coach Johnson"
        
        var report2 = ScoutingReport()
        report2.playerName = "Sarah Davis"
        report2.primaryPosition = "CF"
        report2.team = "Hawks"
        report2.scoutName = "Coach Wilson"
        
        reports = [report1, report2]
        saveToUserDefaults()
    }
    
    private func addDemoRegistrationCodes() {
        registrationCodes = [
            RegistrationCode(code: "EAGLES2024", teamName: "Eagles Baseball", maxUses: 50),
            RegistrationCode(code: "HAWKS2024", teamName: "Hawks Baseball", maxUses: 30),
            RegistrationCode(code: "DEMO123", teamName: "Demo Team", maxUses: 100)
        ]
        saveRegistrationCodes()
    }
    
    private func addDemoUsers() {
        users = [
            AppUser(id: 1, firstName: "Admin", lastName: "User", email: "admin@demo.com", groupName: "Demo Team", isAdmin: true)
        ]
        saveUsers()
    }
}

// MARK: - Main App Entry Point
@main
struct BaseballScoutingApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(dataManager)
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        if authService.isAuthenticated {
            MainTabView()
        } else {
            AuthenticationView()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ReportsListView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Reports")
                }
                .tag(0)
            
            ScoutingFormView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("New Report")
                }
                .tag(1)
            
            if authService.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Admin")
                    }
                    .tag(2)
            }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(authService.currentUser?.isAdmin == true ? 3 : 2)
        }
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @State private var showingLogin = true
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    // Baseball imagery instead of sportscourt
                    HStack(spacing: 12) {
                        Image(systemName: "figure.baseball")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    
                    Text("⚾ Baseball Scouting")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Team-based scouting and player evaluation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    if authService.canUseBiometrics {
                        BiometricLoginButton()
                    }
                    
                    if let biometricError = authService.biometricError {
                        Text(biometricError)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    }
                    
                    AppleSignInButtonView(isRegistration: !showingLogin)
                }
                
                DividerLabel(text: showingLogin ? "or log in with email" : "or register with email")
                    .padding(.horizontal)
                
                if showingLogin {
                    LoginView(showingLogin: $showingLogin)
                } else {
                    RegisterView(showingLogin: $showingLogin)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            authService.refreshBiometricAvailability()
        }
    }
}

struct AppleSignInButtonView: View {
    @EnvironmentObject var authService: AuthService
    var isRegistration: Bool
    
    var body: some View {
        SignInWithAppleButton(isRegistration ? .signUp : .signIn) { request in
            authService.configureAppleRequest(request)
        } onCompletion: { result in
            authService.handleAppleSignIn(result: result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct BiometricLoginButton: View {
    @EnvironmentObject var authService: AuthService
    
    private var iconName: String {
        switch authService.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.fill"
        }
    }
    
    private var buttonTitle: String {
        switch authService.biometryType {
        case .faceID:
            return "Log in with Face ID"
        case .touchID:
            return "Log in with Touch ID"
        default:
            return "Use Biometric Login"
        }
    }
    
    var body: some View {
        Button {
            authService.attemptBiometricLogin()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                Text(buttonTitle)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }
}

struct DividerLabel: View {
    let text: String
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4))
            
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4))
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var showingLogin: Bool
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login to Your Team")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Login") {
                    Task {
                        await authService.login(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                
                if authService.isLoading {
                    ProgressView()
                }
                
                if let error = authService.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button("Register here") {
                    showingLogin = false
                }
                .foregroundColor(.blue)
            }
            .font(.subheadline)
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var dataManager: DataManager
    @Binding var showingLogin: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var teamCode = ""
    @State private var validationMessage = ""
    @State private var isCodeValid = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Register New Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Team Registration Code", text: $teamCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: teamCode) { _, newValue in
                                validateCode(newValue)
                            }
                        
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.caption)
                                .foregroundColor(isCodeValid ? .green : .red)
                        }
                        
                        Text("Available demo codes: EAGLES2024, HAWKS2024, DEMO123")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    
                    Button("Register") {
                        Task {
                            await authService.register(
                                firstName: firstName,
                                lastName: lastName,
                                email: email,
                                password: password,
                                groupId: 1,
                                registrationCode: teamCode
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        firstName.isEmpty || lastName.isEmpty ||
                        email.isEmpty || password.count < 6 ||
                        !isCodeValid || authService.isLoading
                    )
                    
                    if authService.isLoading {
                        ProgressView()
                    }
                    
                    if let error = authService.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    
                    Button("Login here") {
                        showingLogin = true
                    }
                    .foregroundColor(.blue)
                }
                .font(.subheadline)
            }
        }
    }
    
    private func validateCode(_ code: String) {
        let validation = dataManager.validateRegistrationCode(code)
        isCodeValid = validation.isValid
        
        if code.isEmpty {
            validationMessage = ""
        } else if validation.isValid {
            validationMessage = "✓ Valid code for \(validation.teamName ?? "team")"
        } else {
            validationMessage = "✗ Invalid or expired registration code"
        }
    }
}

// MARK: - Scouting Form View
struct ScoutingFormView: View {
    let reportId: Int?
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var showingSaveConfirmation = false
    @State private var report = ScoutingReport()
    
    init(reportId: Int? = nil) {
        self.reportId = reportId
    }
    
    var isEditing: Bool {
        reportId != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Scout Information Section
                    FormSectionView(title: "Scout Information") {
                        FormRow(title: "Scout/Coach", text: $report.scoutName)
                        FormDateRow(title: "Date", date: $report.scoutDate)
                        FormRow(title: "Event", text: $report.event)
                        FormRow(title: "League/Organization", text: $report.leagueOrganization)
                    }
                    
                    // Player Information Section
                    FormSectionView(title: "Player Information") {
                        FormRow(title: "Name *", text: $report.playerName)
                        FormRow(title: "Primary Position", text: $report.primaryPosition)
                        FormRow(title: "Jersey #", text: $report.jerseyNumber)
                        FormDateRow(title: "Date of Birth", date: $report.dateOfBirth)
                        FormRow(title: "Age", text: $report.age)
                        FormRow(title: "Height", text: $report.height)
                        FormRow(title: "Weight", text: $report.weight)
                        FormPickerRow(title: "Bats", selection: $report.bats, options: ["L", "R", "S"])
                        FormPickerRow(title: "Throws", selection: $report.throwsHand, options: ["L", "R"])
                        FormRow(title: "Team", text: $report.team)
                        FormRow(title: "Parent/Guardian", text: $report.parentGuardian)
                        FormRow(title: "Contact", text: $report.contact)
                    }
                    
                    // Physical Development Section
                    FormSectionView(title: "Physical Development") {
                        FormPickerRow(title: "Build", selection: $report.build, options: ["Small for Age", "Average", "Large for Age"])
                        FormPickerRow(title: "Coordination", selection: $report.coordination, options: ["Developing", "Good", "Advanced"])
                        FormPickerRow(title: "Athleticism", selection: $report.athleticism, options: ["Below Average", "Average", "Above Average", "Exceptional"])
                    }
                    
                    // Hitting Fundamentals Section
                    FormSectionView(title: "Hitting Fundamentals") {
                        FormPickerRow(title: "Stance & Setup", selection: $report.stanceSetup, options: ["Needs Work", "Developing", "Good", "Advanced"])
                        FormPickerRow(title: "Swing Mechanics", selection: $report.swingMechanics, options: ["Needs Work", "Developing", "Solid", "Very Good"])
                        FormPickerRow(title: "Contact Ability", selection: $report.contactAbility, options: ["Struggles", "Inconsistent", "Consistent", "Excellent"])
                        FormPickerRow(title: "Power Potential", selection: $report.powerPotential, options: ["Limited", "Some", "Good", "Strong for Age"])
                    }
                    
                    // Running & Base Running Section
                    FormSectionView(title: "Running & Base Running") {
                        FormPickerRow(title: "Speed", selection: $report.speed, options: ["Slow", "Average", "Fast", "Very Fast for Age"])
                        FormPickerRow(title: "Base Running IQ", selection: $report.baseRunningIq, options: ["Needs Teaching", "Learning", "Good", "Advanced"])
                        FormPickerRow(title: "Stealing Ability", selection: $report.stealingAbility, options: ["No Threat", "Occasional", "Threat", "Consistent"])
                    }
                    
                    // Fielding Skills Section
                    FormSectionView(title: "Fielding Skills") {
                        FormPickerRow(title: "Readiness", selection: $report.fieldingReadiness, options: ["Not Ready", "Learning", "Ready", "Advanced"])
                        FormPickerRow(title: "Glove Work", selection: $report.gloveWork, options: ["Struggles", "Developing", "Reliable", "Soft Hands"])
                        FormPickerRow(title: "Arm Strength", selection: $report.armStrength, options: ["Weak", "Average", "Strong", "Very Strong for Age"])
                        FormPickerRow(title: "Arm Accuracy", selection: $report.armAccuracy, options: ["Wild", "Inconsistent", "Accurate", "Precise"])
                    }
                    
                    // Notes Section
                    FormSectionView(title: "Notes & Development") {
                        FormTextAreaRow(title: "Biggest Strengths", text: $report.biggestStrengths)
                        FormTextAreaRow(title: "Areas for Improvement", text: $report.improvementAreas)
                        FormTextAreaRow(title: "Notes & Observations", text: $report.notes)
                    }
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Report" : "New Report")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: HStack {
                    if isEditing {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                    
                    Button("Save") {
                        saveReport()
                    }
                    .disabled(report.playerName.isEmpty)
                }
            )
        }
        .alert("Delete Report", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteReport()
            }
        } message: {
            Text("Are you sure you want to delete this report?")
        }
        .alert("Report Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("The scouting report has been saved successfully.")
        }
        .onAppear {
            if let reportId = reportId, let existingReport = dataManager.getReport(id: reportId) {
                report = existingReport
            } else {
                // Initialize new report with scout name
                report.scoutName = authService.currentUser?.firstName ?? ""
                report.scoutDate = Date()
            }
        }
    }
    
    private func saveReport() {
        // Actually save the report using DataManager
        dataManager.saveReport(report)
        showingSaveConfirmation = true
        print("Report saved successfully for player: \(report.playerName)")
    }
    
    private func deleteReport() {
        if let reportId = reportId {
            dataManager.deleteReport(id: reportId)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Reports List View
struct ReportsListView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var searchText = ""
    @State private var showingNewReport = false
    
    var filteredReports: [ReportListItem] {
        let reportItems = dataManager.reports.map { report in
            ReportListItem(
                id: report.id,
                playerName: report.playerName.isEmpty ? "Unnamed Player" : report.playerName,
                primaryPosition: report.primaryPosition.isEmpty ? "N/A" : report.primaryPosition,
                team: report.team.isEmpty ? "No Team" : report.team,
                scoutName: report.scoutName.isEmpty ? "Unknown Scout" : report.scoutName,
                date: DateFormatter.shortDate.string(from: report.scoutDate)
            )
        }
        
        if searchText.isEmpty {
            return reportItems
        } else {
            return reportItems.filter { report in
                report.playerName.localizedCaseInsensitiveContains(searchText) ||
                report.team.localizedCaseInsensitiveContains(searchText) ||
                report.primaryPosition.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.reports.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredReports) { report in
                            NavigationLink(destination: ScoutingFormView(reportId: report.id)) {
                                ReportCardView(report: report)
                            }
                        }
                        .onDelete(perform: deleteReports)
                    }
                    .searchable(text: $searchText, prompt: "Search players...")
                }
            }
            .navigationTitle("Scouting Reports")
            .navigationBarItems(
                trailing: Button {
                    showingNewReport = true
                } label: {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingNewReport) {
                ScoutingFormView()
            }
        }
    }
    
    private func deleteReports(offsets: IndexSet) {
        for index in offsets {
            let report = filteredReports[index]
            dataManager.deleteReport(id: report.id)
        }
    }
}

// MARK: - Admin View
struct AdminView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingAddCode = false
    @State private var newCode = ""
    @State private var newTeamName = ""
    @State private var newMaxUses = "50"
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab picker for different admin sections
                Picker("Admin Section", selection: $selectedTab) {
                    Text("Registration Codes").tag(0)
                    Text("User Management").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    // Registration Codes Section
                    if dataManager.registrationCodes.isEmpty {
                        EmptyCodesView()
                    } else {
                        List {
                            ForEach(dataManager.registrationCodes) { code in
                                RegistrationCodeRow(code: code)
                            }
                            .onDelete(perform: deleteCode)
                        }
                    }
                } else {
                    // User Management Section
                    if dataManager.users.isEmpty {
                        EmptyUsersView()
                    } else {
                        List {
                            ForEach(dataManager.users) { user in
                                UserManagementRow(user: user)
                            }
                            .onDelete(perform: deleteUser)
                        }
                    }
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarItems(
                trailing: Button {
                    if selectedTab == 0 {
                        showingAddCode = true
                    }
                } label: {
                    if selectedTab == 0 {
                        Image(systemName: "plus")
                    } else {
                        EmptyView()
                    }
                }
            )
            .sheet(isPresented: $showingAddCode) {
                AddCodeSheet(
                    newCode: $newCode,
                    newTeamName: $newTeamName,
                    newMaxUses: $newMaxUses,
                    onSave: {
                        if !newCode.isEmpty && !newTeamName.isEmpty {
                            let maxUses = Int(newMaxUses) ?? 50
                            dataManager.addRegistrationCode(
                                code: newCode,
                                teamName: newTeamName,
                                maxUses: maxUses
                            )
                            newCode = ""
                            newTeamName = ""
                            newMaxUses = "50"
                            showingAddCode = false
                        }
                    },
                    onCancel: {
                        showingAddCode = false
                    }
                )
            }
        }
    }
    
    private func deleteCode(offsets: IndexSet) {
        for index in offsets {
            let code = dataManager.registrationCodes[index]
            dataManager.deleteRegistrationCode(id: code.id)
        }
    }
    
    private func deleteUser(offsets: IndexSet) {
        for index in offsets {
            let user = dataManager.users[index]
            // Don't allow deleting the last admin
            let adminCount = dataManager.users.filter { $0.isAdmin }.count
            if user.isAdmin && adminCount <= 1 {
                return // Prevent deleting the last admin
            }
            dataManager.deleteUser(id: user.id)
        }
    }
}

struct UserManagementRow: View {
    let user: AppUser
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingPromoteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if user.isAdmin {
                    Text("ADMIN")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                } else {
                    Button("Promote to Admin") {
                        showingPromoteAlert = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            HStack {
                if let groupName = user.groupName {
                    Text("Team: \(groupName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Joined: \(DateFormatter.shortDate.string(from: user.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .alert("Promote to Admin", isPresented: $showingPromoteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Promote") {
                dataManager.updateUserAdminStatus(userId: user.id, isAdmin: true)
            }
        } message: {
            Text("Are you sure you want to promote \(user.firstName) \(user.lastName) to administrator?")
        }
    }
}

struct EmptyUsersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Users")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Users will appear here as they register")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RegistrationCodeRow: View {
    let code: RegistrationCode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(code.code)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if code.isActive {
                    Text("ACTIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                } else {
                    Text("INACTIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
            
            Text(code.teamName)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            HStack {
                Text("Uses: \(code.currentUses)/\(code.maxUses)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Created: \(DateFormatter.shortDate.string(from: code.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddCodeSheet: View {
    @Binding var newCode: String
    @Binding var newTeamName: String
    @Binding var newMaxUses: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Registration Code Details")) {
                    TextField("Code (e.g., EAGLES2024)", text: $newCode)
                        .autocapitalization(.allCharacters)
                    
                    TextField("Team Name", text: $newTeamName)
                    
                    TextField("Max Uses", text: $newMaxUses)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Generate Random Code") {
                        newCode = generateRandomCode()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add Registration Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                },
                trailing: Button("Save") {
                    onSave()
                }
                .disabled(newCode.isEmpty || newTeamName.isEmpty)
            )
        }
    }
    
    private func generateRandomCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map{ _ in letters.randomElement()! })
    }
}

struct EmptyCodesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Registration Codes")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to create registration codes for teams")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authService.currentUser {
                    VStack(spacing: 8) {
                        Image(systemName: user.isAdmin ? "person.badge.key.fill" : "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(user.isAdmin ? .orange : .blue)
                        
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if user.isAdmin {
                            Text("Administrator")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                        
                        if let groupName = user.groupName {
                            Text(groupName)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                Button("Sign Out") {
                    Task {
                        await authService.logout()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Form Components
struct FormSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct FormRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct FormDateRow: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            DatePicker(title, selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
        }
    }
}

struct FormPickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? "Select..." : selection)
                        .foregroundColor(selection.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
        }
    }
}

struct FormTextAreaRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $text)
                .frame(minHeight: 80, maxHeight: 120)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
    }
}

// MARK: - Supporting Views
struct ReportCardView: View {
    let report: ReportListItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(report.playerName)
                    .font(.headline)
                
                Spacer()
                
                Text(report.primaryPosition)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.team)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Scout: \(report.scoutName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(report.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Scouting Reports")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to create your first report")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.subheadline)
            
            Spacer()
            
            Button("Dismiss", action: onDismiss)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

// MARK: - Services
@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var canUseBiometrics = false
    @Published var biometryType: LABiometryType = .none
    @Published var biometricError: String?
    
    private let dataManager = DataManager.shared
    private let biometricAuthenticator = BiometricAuthenticator.shared
    
    init() {
        refreshBiometricAvailability()
    }
    
    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unable to process Apple ID credentials."
                return
            }
            Task {
                await completeAppleSignIn(with: credential)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func completeAppleSignIn(with credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let appleUserId = credential.user
        
        if let existingAppleUser = dataManager.getUser(appleIdentifier: appleUserId) {
            setCurrentUser(from: existingAppleUser)
            print("Apple Sign In success for existing user: \(existingAppleUser.firstName) \(existingAppleUser.lastName)")
            return
        }
        
        let providedEmail = credential.email
        let resolvedEmail = providedEmail ?? "\(appleUserId)@appleid.apple"
        
        if let email = providedEmail, var matchedByEmail = dataManager.getUser(email: email) {
            matchedByEmail.appleIdentifier = appleUserId
            dataManager.addUser(matchedByEmail)
            setCurrentUser(from: matchedByEmail)
            print("Linked existing email user to Apple ID: \(email)")
            return
        }
        
        if var matchedByPlaceholder = dataManager.getUser(email: resolvedEmail) {
            matchedByPlaceholder.appleIdentifier = appleUserId
            dataManager.addUser(matchedByPlaceholder)
            setCurrentUser(from: matchedByPlaceholder)
            print("Linked existing placeholder email user to Apple ID: \(resolvedEmail)")
            return
        }
        
        let firstName = credential.fullName?.givenName ?? "Scout"
        let lastName = credential.fullName?.familyName ?? "User"
        
        let newUser = AppUser(
            id: Int.random(in: 100...999),
            firstName: firstName,
            lastName: lastName,
            email: resolvedEmail,
            groupName: nil,
            isAdmin: false,
            appleIdentifier: appleUserId
        )
        
        dataManager.addUser(newUser)
        setCurrentUser(from: newUser)
        print("Created new user via Apple Sign In: \(firstName) \(lastName)")
    }
    
    private func setCurrentUser(from appUser: AppUser) {
        currentUser = User(
            id: appUser.id,
            firstName: appUser.firstName,
            lastName: appUser.lastName,
            email: appUser.email,
            groupName: appUser.groupName,
            isAdmin: appUser.isAdmin,
            appleIdentifier: appUser.appleIdentifier
        )
        isAuthenticated = true
        biometricError = nil
        storeBiometricCredentials(for: appUser)
    }
    
    func attemptBiometricLogin() {
        biometricError = nil
        Task {
            do {
                let credentials = try await biometricAuthenticator.authenticate(reason: "Log in to Baseball Scout")
                handleBiometricSuccess(credentials)
            } catch let error as BiometricAuthError {
                if case .authenticationFailed = error {
                    biometricError = nil
                } else {
                    biometricError = error.localizedDescription
                }
            } catch {
                biometricError = error.localizedDescription
            }
        }
    }
    
    func refreshBiometricAvailability() {
        let evaluation = biometricAuthenticator.canEvaluateBiometrics()
        biometryType = evaluation.type
        canUseBiometrics = evaluation.available && biometricAuthenticator.hasStoredCredentials()
    }
    
    private func handleBiometricSuccess(_ credentials: BiometricCredentials) {
        if let user = dataManager.getUser(id: credentials.userId) ??
            (credentials.appleIdentifier.flatMap { dataManager.getUser(appleIdentifier: $0) }) ??
            dataManager.getUser(email: credentials.email) {
            setCurrentUser(from: user)
        } else {
            biometricError = "Unable to locate your saved account. Please log in with email once to reset biometrics."
            biometricAuthenticator.clearCredentials()
            refreshBiometricAvailability()
        }
    }
    
    private func storeBiometricCredentials(for appUser: AppUser) {
        let evaluation = biometricAuthenticator.canEvaluateBiometrics()
        guard evaluation.available else { return }
        let credentials = BiometricCredentials(
            userId: appUser.id,
            email: appUser.email,
            appleIdentifier: appUser.appleIdentifier
        )
        do {
            try biometricAuthenticator.store(credentials: credentials)
            refreshBiometricAvailability()
        } catch {
            biometricError = error.localizedDescription
            refreshBiometricAvailability()
        }
    }
    
    func checkAuthenticationStatus() {
        isAuthenticated = false
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Check if user exists in our stored users
        if let storedUser = dataManager.getUser(email: email) {
            // For demo purposes, accept any password for stored users
            if password.count >= 6 {
                setCurrentUser(from: storedUser)
                print("\(storedUser.isAdmin ? "Admin" : "User") logged in: \(storedUser.firstName) \(storedUser.lastName)")
            } else {
                errorMessage = "Password must be at least 6 characters"
            }
        } else if email == "admin@demo.com" && password == "admin123" {
            // Fallback admin account if not in stored users
            currentUser = User(id: 1, firstName: "Admin", lastName: "User", email: email, groupName: "Demo Team", isAdmin: true, appleIdentifier: nil)
            isAuthenticated = true
            print("Fallback admin user logged in successfully")
        } else {
            errorMessage = "Account not found. Please register first or check your credentials."
        }
        
        isLoading = false
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, groupId: Int, registrationCode: String) async {
        isLoading = true
        errorMessage = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Check if user already exists
        if dataManager.getUser(email: email) != nil {
            errorMessage = "An account with this email already exists"
            isLoading = false
            return
        }
        
        // Validate registration code with DataManager
        let validation = dataManager.validateRegistrationCode(registrationCode)
        
        if validation.isValid {
            dataManager.useRegistrationCode(registrationCode)
            
            // Create new user
            let newUser = AppUser(
                id: Int.random(in: 100...999),
                firstName: firstName,
                lastName: lastName,
                email: email,
                groupName: validation.teamName,
                isAdmin: false
            )
            
            // Add to stored users
            dataManager.addUser(newUser)
            
            // Log them in
            setCurrentUser(from: newUser)
            print("User registered and logged in successfully for team: \(validation.teamName ?? "Unknown")")
        } else {
            errorMessage = "Invalid or expired registration code"
        }
        
        isLoading = false
    }
    
    func logout() async {
        currentUser = nil
        isAuthenticated = false
        refreshBiometricAvailability()
    }
}

// MARK: - Biometric Support
struct BiometricCredentials: Codable {
    let userId: Int
    let email: String
    let appleIdentifier: String?
}

enum BiometricAuthError: LocalizedError {
    case biometryUnavailable
    case authenticationFailed
    case credentialsNotFound
    case storage(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .biometryUnavailable:
            return "Biometric authentication is not available on this device."
        case .authenticationFailed:
            return "Face ID / Touch ID was canceled or did not succeed."
        case .credentialsNotFound:
            return "Biometric login data is missing. Please sign in once with email to re-enable it."
        case .storage(let status):
            return "Unable to save biometric credentials (code: \(status))."
        }
    }
}

final class BiometricAuthenticator {
    static let shared = BiometricAuthenticator()
    
    private let service = "com.baseballscout.credentials"
    private let account = "biometricUser"
    private init() {}
    
    func canEvaluateBiometrics() -> (available: Bool, type: LABiometryType) {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return (available, context.biometryType)
    }
    
    func hasStoredCredentials() -> Bool {
        let context = LAContext()
        context.interactionNotAllowed = true
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecUseAuthenticationContext as String: context
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }
    
    func store(credentials: BiometricCredentials) throws {
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryCurrentSet,
            nil
        ) else {
            throw BiometricAuthError.biometryUnavailable
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(credentials)
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(baseQuery as CFDictionary)
        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessControl as String] = access
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw BiometricAuthError.storage(status)
        }
    }
    
    func authenticate(reason: String) async throws -> BiometricCredentials {
        try await withCheckedThrowingContinuation { continuation in
            let service = self.service
            let account = self.account
            Task.detached(priority: .userInitiated) {
                let context = LAContext()
                context.localizedFallbackTitle = "Use Passcode"
                context.localizedReason = reason
                
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: service,
                    kSecAttrAccount as String: account,
                    kSecReturnData as String: true,
                    kSecMatchLimit as String: kSecMatchLimitOne,
                    kSecUseAuthenticationContext as String: context
                ]
                
                var item: CFTypeRef?
                let status = SecItemCopyMatching(query as CFDictionary, &item)
                
                switch status {
                case errSecSuccess:
                    if let data = item as? Data {
                        do {
                            let decoder = JSONDecoder()
                            let credentials = try decoder.decode(BiometricCredentials.self, from: data)
                            continuation.resume(returning: credentials)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    } else {
                        continuation.resume(throwing: BiometricAuthError.credentialsNotFound)
                    }
                case errSecItemNotFound:
                    continuation.resume(throwing: BiometricAuthError.credentialsNotFound)
                case errSecUserCanceled, errSecAuthFailed:
                    continuation.resume(throwing: BiometricAuthError.authenticationFailed)
                default:
                    continuation.resume(throwing: BiometricAuthError.authenticationFailed)
                }
            }
        }
    }
    
    func clearCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
