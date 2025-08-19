import SwiftUI

// MARK: - Main App Entry Point
@main
struct BaseballScoutingApp: App {
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authService.checkAuthenticationStatus()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
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
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @State private var showingLogin = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "sportscourt")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("⚾ Baseball Scouting")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Team-based scouting and player evaluation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
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
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                Button("Login") {
                    Task {
                        await authService.login(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
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
            
            VStack(spacing: 4) {
                Text("Demo Account:")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("admin@demo.com / admin123")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(8)
            
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
    @Binding var showingLogin: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var teamCode = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Register New Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Team Registration Code", text: $teamCode)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Register") {
                        Task {
                            await authService.register(
                                firstName: firstName,
                                lastName: lastName,
                                email: email,
                                password: password,
                                groupId: 1, // Simplified for demo
                                registrationCode: teamCode
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(
                        firstName.isEmpty || lastName.isEmpty || 
                        email.isEmpty || password.count < 6 || 
                        teamCode.isEmpty || authService.isLoading
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
}

// MARK: - Scouting Form View
struct ScoutingFormView: View {
    let reportId: Int?
    @StateObject private var formService = ScoutingFormService()
    @EnvironmentObject private var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var showingSaveConfirmation = false
    
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
                        FormRow(title: "Scout/Coach", text: $formService.scoutName)
                        FormDateRow(title: "Date", date: $formService.scoutDate)
                        FormRow(title: "Event", text: $formService.event)
                        FormRow(title: "League/Organization", text: $formService.leagueOrganization)
                    }
                    
                    // Player Information Section
                    FormSectionView(title: "Player Information") {
                        FormRow(title: "Name *", text: $formService.playerName)
                        FormRow(title: "Primary Position", text: $formService.primaryPosition)
                        FormRow(title: "Jersey #", text: $formService.jerseyNumber)
                        FormDateRow(title: "Date of Birth", date: $formService.dateOfBirth)
                        FormRow(title: "Age", text: $formService.age)
                        FormRow(title: "Height", text: $formService.height)
                        FormRow(title: "Weight", text: $formService.weight)
                        FormPickerRow(title: "Bats", selection: $formService.bats, options: ["L", "R", "S"])
                        FormPickerRow(title: "Throws", selection: $formService.throwsHand, options: ["L", "R"])
                        FormRow(title: "Team", text: $formService.team)
                        FormRow(title: "Parent/Guardian", text: $formService.parentGuardian)
                        FormRow(title: "Contact", text: $formService.contact)
                    }
                    
                    // Physical Development Section
                    FormSectionView(title: "Physical Development") {
                        FormPickerRow(title: "Build", selection: $formService.build, options: ["Small for Age", "Average", "Large for Age"])
                        FormPickerRow(title: "Coordination", selection: $formService.coordination, options: ["Developing", "Good", "Advanced"])
                        FormPickerRow(title: "Athleticism", selection: $formService.athleticism, options: ["Below Average", "Average", "Above Average", "Exceptional"])
                    }
                    
                    // Hitting Fundamentals Section
                    FormSectionView(title: "Hitting Fundamentals") {
                        FormPickerRow(title: "Stance & Setup", selection: $formService.stanceSetup, options: ["Needs Work", "Developing", "Good", "Advanced"])
                        FormPickerRow(title: "Swing Mechanics", selection: $formService.swingMechanics, options: ["Needs Work", "Developing", "Solid", "Very Good"])
                        FormPickerRow(title: "Contact Ability", selection: $formService.contactAbility, options: ["Struggles", "Inconsistent", "Consistent", "Excellent"])
                        FormPickerRow(title: "Power Potential", selection: $formService.powerPotential, options: ["Limited", "Some", "Good", "Strong for Age"])
                    }
                    
                    // Running & Base Running Section
                    FormSectionView(title: "Running & Base Running") {
                        FormPickerRow(title: "Speed", selection: $formService.speed, options: ["Slow", "Average", "Fast", "Very Fast for Age"])
                        FormPickerRow(title: "Base Running IQ", selection: $formService.baseRunningIq, options: ["Needs Teaching", "Learning", "Good", "Advanced"])
                        FormPickerRow(title: "Stealing Ability", selection: $formService.stealingAbility, options: ["No Threat", "Occasional", "Threat", "Consistent"])
                    }
                    
                    // Fielding Skills Section
                    FormSectionView(title: "Fielding Skills") {
                        FormPickerRow(title: "Readiness", selection: $formService.fieldingReadiness, options: ["Not Ready", "Learning", "Ready", "Advanced"])
                        FormPickerRow(title: "Glove Work", selection: $formService.gloveWork, options: ["Struggles", "Developing", "Reliable", "Soft Hands"])
                        FormPickerRow(title: "Arm Strength", selection: $formService.armStrength, options: ["Weak", "Average", "Strong", "Very Strong for Age"])
                        FormPickerRow(title: "Arm Accuracy", selection: $formService.armAccuracy, options: ["Wild", "Inconsistent", "Accurate", "Precise"])
                    }
                    
                    // Notes Section
                    FormSectionView(title: "Notes & Development") {
                        FormTextAreaRow(title: "Biggest Strengths", text: $formService.biggestStrengths)
                        FormTextAreaRow(title: "Areas for Improvement", text: $formService.improvementAreas)
                        FormTextAreaRow(title: "Notes & Observations", text: $formService.notes)
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
                    .disabled(formService.playerName.isEmpty)
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
            if let reportId = reportId {
                loadReport(id: reportId)
            } else {
                formService.initializeNewReport(scoutName: authService.currentUser?.firstName ?? "")
            }
        }
    }
    
    private func saveReport() {
        // Simulate save operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingSaveConfirmation = true
        }
    }
    
    private func deleteReport() {
        // Simulate delete operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func loadReport(id: Int) {
        // Simulate load operation
        // Implementation would load from your API
    }
}

// MARK: - Reports List View
struct ReportsListView: View {
    @StateObject private var reportsService = ReportsService()
    @State private var searchText = ""
    @State private var showingNewReport = false
    
    var filteredReports: [ReportListItem] {
        if searchText.isEmpty {
            return reportsService.reports
        } else {
            return reportsService.reports.filter { report in
                report.playerName.localizedCaseInsensitiveContains(searchText) ||
                report.team.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if reportsService.isLoading && reportsService.reports.isEmpty {
                    LoadingView()
                } else if reportsService.reports.isEmpty {
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
                
                if let error = reportsService.errorMessage {
                    ErrorBanner(message: error) {
                        reportsService.clearError()
                    }
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
        .onAppear {
            reportsService.loadReports()
        }
    }
    
    private func deleteReports(offsets: IndexSet) {
        for index in offsets {
            let report = filteredReports[index]
            reportsService.deleteReport(id: report.id)
        }
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
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
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
                .controlSize(.large)
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
                .textFieldStyle(.roundedBorder)
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
                .datePickerStyle(.compact)
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
                .frame(minHeight: 80)
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

// MARK: - Data Models
struct User: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let groupName: String?
}

struct Group: Codable, Identifiable {
    let id: Int
    let name: String
}

struct ReportListItem: Identifiable {
    let id: Int
    let playerName: String
    let primaryPosition: String
    let team: String
    let scoutName: String
    let date: String
}

// MARK: - Services
@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func checkAuthenticationStatus() {
        // Simulate checking stored auth token
        isAuthenticated = false
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if email == "admin@demo.com" && password == "admin123" {
            currentUser = User(id: 1, firstName: "Admin", lastName: "User", email: email, groupName: "Demo Team")
            isAuthenticated = true
        } else {
            errorMessage = "Invalid credentials"
        }
        
        isLoading = false
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, groupId: Int, registrationCode: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Simulate successful registration
        currentUser = User(id: 2, firstName: firstName, lastName: lastName, email: email, groupName: "Demo Team")
        isAuthenticated = true
        isLoading = false
    }
    
    func logout() async {
        currentUser = nil
        isAuthenticated = false
    }
}

@MainActor 
class ScoutingFormService: ObservableObject {
    @Published var playerName = ""
    @Published var primaryPosition = ""
    @Published var jerseyNumber = ""
    @Published var dateOfBirth = Date()
    @Published var age = ""
    @Published var height = ""
    @Published var weight = ""
    @Published var bats = ""
    @Published var throwsHand = ""
    @Published var team = ""
    @Published var parentGuardian = ""
    @Published var contact = ""
    @Published var scoutName = ""
    @Published var scoutDate = Date()
    @Published var event = ""
    @Published var leagueOrganization = ""
    @Published var build = ""
    @Published var coordination = ""
    @Published var athleticism = ""
    @Published var stanceSetup = ""
    @Published var swingMechanics = ""
    @Published var contactAbility = ""
    @Published var powerPotential = ""
    @Published var speed = ""
    @Published var baseRunningIq = ""
    @Published var stealingAbility = ""
    @Published var fieldingReadiness = ""
    @Published var gloveWork = ""
    @Published var armStrength = ""
    @Published var armAccuracy = ""
    @Published var biggestStrengths = ""
    @Published var improvementAreas = ""
    @Published var notes = ""
    
    func initializeNewReport(scoutName: String) {
        self.scoutName = scoutName
        self.scoutDate = Date()
    }
}

@MainActor
class ReportsService: ObservableObject {
    @Published var reports: [ReportListItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadReports() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call with demo data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reports = [
                ReportListItem(id: 1, playerName: "John Smith", primaryPosition: "SS", team: "Eagles", scoutName: "Coach Johnson", date: "Mar 15, 2024"),
                ReportListItem(id: 2, playerName: "Sarah Davis", primaryPosition: "CF", team: "Hawks", scoutName: "Coach Wilson", date: "Mar 14, 2024"),
                ReportListItem(id: 3, playerName: "Mike Brown", primaryPosition: "C", team: "Lions", scoutName: "Coach Taylor", date: "Mar 13, 2024")
            ]
            self.isLoading = false
        }
    }
    
    func deleteReport(id: Int) {
        reports.removeAll { $0.id == id }
    }
    
    func clearError() {
        errorMessage = nil
    }
}