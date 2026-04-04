import SwiftUI
import AVFoundation

struct VerificationView: View {
    @StateObject private var viewModel = VerificationViewModel()
    @State private var selectedChallenge: PendingVerificationItem?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading && viewModel.pendingItems.isEmpty {
                VStack(spacing: AppTheme.padding) {
                    ProgressView()
                    Text("Checking for pending verifications...")
                        .font(.subheadline)
                        .foregroundColor(.appMutedForeground)
                }
            } else if viewModel.pendingItems.isEmpty {
                EmptyVerificationView()
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.padding) {
                        ForEach(viewModel.pendingItems) { item in
                            VerificationChallengeCard(item: item) {
                                selectedChallenge = item
                            }
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.startMonitoring() }
        .onDisappear { viewModel.stopMonitoring() }
        .sheet(item: $selectedChallenge) { challenge in
            ChallengeDetailSheet(challenge: challenge, viewModel: viewModel) {
                selectedChallenge = nil
            }
        }
        .alert("Verification Successful", isPresented: $viewModel.submitSuccess) {
            Button("OK") {}
        }
    }
}

// MARK: - Empty State

struct EmptyVerificationView: View {
    var body: some View {
        VStack(spacing: AppTheme.largePadding) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.appPrimary)
            Text("No Pending Verifications")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appForeground)
            Text("Verification requests from your browser will appear here.")
                .font(.subheadline)
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.largePadding)
        }
    }
}

// MARK: - Challenge Card

struct VerificationChallengeCard: View {
    let item: PendingVerificationItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.padding) {
                Image(systemName: item.method.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.appPrimary)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.method.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appForeground)

                    if let date = item.expirationDate {
                        Text("Expires \(date, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.appMutedForeground)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.appMutedForeground)
            }
            .padding(AppTheme.padding)
            .background(Color.appCard)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.appForeground.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Challenge Detail Sheet

struct ChallengeDetailSheet: View {
    let challenge: PendingVerificationItem
    @ObservedObject var viewModel: VerificationViewModel
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.largePadding) {
                        switch challenge.method {
                        case .codePull:
                            CodePullChallengeView(
                                challenge: challenge,
                                viewModel: viewModel,
                                onDismiss: onDismiss
                            )
                        case .email:
                            EmailChallengeView(challenge: challenge)
                        case .qrScan:
                            QRScanChallengeView(
                                challenge: challenge,
                                viewModel: viewModel,
                                onDismiss: onDismiss
                            )
                        case .numberMatch:
                            NumberMatchChallengeView(
                                challenge: challenge,
                                viewModel: viewModel,
                                onDismiss: onDismiss
                            )
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.appDestructive)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(AppTheme.largePadding)
                }
            }
            .navigationTitle(challenge.method.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { onDismiss() }
                }
            }
        }
    }
}

// MARK: - code_pull

struct CodePullChallengeView: View {
    let challenge: PendingVerificationItem
    @ObservedObject var viewModel: VerificationViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.largePadding) {
            Image(systemName: "number.square")
                .font(.system(size: 48))
                .foregroundColor(.appPrimary)

            Text("Enter this code in your browser")
                .font(.subheadline)
                .foregroundColor(.appMutedForeground)

            if let displayData = challenge.parsedDisplayData, let code = displayData.code {
                Text(code)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.appPrimary)
                    .padding(AppTheme.padding)
                    .background(Color.appMuted)
                    .cornerRadius(AppTheme.cornerRadius)

                if let date = challenge.expirationDate {
                    Text("Expires \(date, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.appMutedForeground)
                }

                Button(action: {
                    Task {
                        await viewModel.submitCodePull(
                            challengeId: challenge.challengeId,
                            code: code
                        )
                        if viewModel.submitSuccess { onDismiss() }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .appPrimaryForeground))
                            .frame(maxWidth: .infinity, minHeight: 48)
                    } else {
                        Text("Approve")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appPrimaryForeground)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                }
                .background(Color.appPrimary)
                .cornerRadius(AppTheme.cornerRadius)
                .disabled(viewModel.isLoading)
            }
        }
    }
}

// MARK: - email (informational only on mobile)

struct EmailChallengeView: View {
    let challenge: PendingVerificationItem

    var body: some View {
        VStack(spacing: AppTheme.largePadding) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 48))
                .foregroundColor(.appPrimary)

            Text("Email Verification")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appForeground)

            Text("A verification code has been sent to your email. Enter it in your browser to complete the transaction.")
                .font(.subheadline)
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)

            if let date = challenge.expirationDate {
                Text("Expires \(date, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }
        }
    }
}

// MARK: - qr_scan

struct QRScanChallengeView: View {
    let challenge: PendingVerificationItem
    @ObservedObject var viewModel: VerificationViewModel
    let onDismiss: () -> Void
    @State private var showScanner = false

    var body: some View {
        VStack(spacing: AppTheme.largePadding) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 48))
                .foregroundColor(.appPrimary)

            Text("Scan the QR code displayed in your browser")
                .font(.subheadline)
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)

            if let date = challenge.expirationDate {
                Text("Expires \(date, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }

            Button(action: { showScanner = true }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Open Scanner")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appPrimaryForeground)
                .frame(maxWidth: .infinity, minHeight: 48)
            }
            .background(Color.appPrimary)
            .cornerRadius(AppTheme.cornerRadius)
            .sheet(isPresented: $showScanner) {
                QRScannerView { result in
                    showScanner = false
                    if let token = extractTokenFromQR(result) {
                        Task {
                            await viewModel.submitQrToken(
                                challengeId: challenge.challengeId,
                                token: token
                            )
                            if viewModel.submitSuccess { onDismiss() }
                        }
                    }
                }
            }
        }
    }

    private func extractTokenFromQR(_ urlString: String) -> String? {
        guard let components = URLComponents(string: urlString),
              let token = components.queryItems?.first(where: { $0.name == "token" })?.value else {
            return nil
        }
        return token
    }
}

// MARK: - QR Scanner (AVFoundation)

struct QRScannerView: UIViewControllerRepresentable {
    let onScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onScanned = onScanned
        return vc
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScanned: ((String) -> Void)?
    private let captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        captureSession.addInput(input)

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue else { return }
        captureSession.stopRunning()
        onScanned?(value)
    }
}

// MARK: - number_match

struct NumberMatchChallengeView: View {
    let challenge: PendingVerificationItem
    @ObservedObject var viewModel: VerificationViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.largePadding) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 48))
                .foregroundColor(.appPrimary)

            Text("Select the number shown in your browser")
                .font(.subheadline)
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)

            if let date = challenge.expirationDate {
                Text("Expires \(date, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }

            if let displayData = challenge.parsedDisplayData, let options = displayData.options {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.padding) {
                    ForEach(options, id: \.self) { number in
                        Button(action: {
                            Task {
                                await viewModel.submitNumberMatch(
                                    challengeId: challenge.challengeId,
                                    selectedNumber: number
                                )
                                if viewModel.submitSuccess { onDismiss() }
                            }
                        }) {
                            Text("\(number)")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(.appPrimary)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.appMuted)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
    }
}

// MARK: - Make PendingVerificationItem work with .sheet(item:)

extension PendingVerificationItem: Hashable {
    static func == (lhs: PendingVerificationItem, rhs: PendingVerificationItem) -> Bool {
        lhs.id == rhs.id && lhs.challengeId == rhs.challengeId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(challengeId)
    }
}
