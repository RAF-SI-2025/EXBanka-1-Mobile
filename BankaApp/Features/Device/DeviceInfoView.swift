import SwiftUI

struct DeviceInfoView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DeviceInfoViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.padding) {
                    // Device info card
                    if viewModel.isLoading && viewModel.device == nil {
                        ProgressView()
                            .padding(AppTheme.largePadding)
                    } else if let device = viewModel.device {
                        deviceInfoCard(device)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.appDestructive)
                            .padding(.horizontal)
                    }

                    if let message = viewModel.actionMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal)
                    }

                    // Transfer section
                    transferSection

                    // Deactivate button
                    Button(action: { viewModel.showDeactivateConfirm = true }) {
                        Text("Deactivate Device")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .background(Color.appDestructive)
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal, AppTheme.padding)
                    .alert("Deactivate Device?", isPresented: $viewModel.showDeactivateConfirm) {
                        Button("Cancel", role: .cancel) {}
                        Button("Deactivate", role: .destructive) {
                            Task { await viewModel.deactivateDevice() }
                        }
                    } message: {
                        Text("You will need to re-activate to use the app again.")
                    }
                }
                .padding(.top, AppTheme.padding)
            }
        }
        .navigationTitle("Device")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadDevice() }
    }

    private func deviceInfoCard(_ device: DeviceInfo) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
            LabeledRow(label: "Device Name", value: device.deviceName)
            LabeledRow(label: "Status", value: device.status.capitalized)
            LabeledRow(label: "Activated", value: formatDate(device.activatedAt))
            LabeledRow(label: "Last Seen", value: formatDate(device.lastSeenAt))
        }
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal, AppTheme.padding)
    }

    private var transferSection: some View {
        VStack(spacing: AppTheme.padding) {
            Text("Transfer to New Device")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appForeground)
                .frame(maxWidth: .infinity, alignment: .leading)

            BankaTextField(title: "Email for new device", text: $viewModel.transferEmail)

            Button(action: {
                viewModel.showTransferConfirm = true
            }) {
                Text("Send Transfer Code")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appPrimaryForeground)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .background(Color.appPrimary)
            .cornerRadius(AppTheme.cornerRadius)
            .alert("Transfer Device?", isPresented: $viewModel.showTransferConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Transfer") {
                    Task { await viewModel.transferDevice() }
                }
            } message: {
                Text("This will deactivate your current device when the new device activates.")
            }
        }
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal, AppTheme.padding)
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }
}
