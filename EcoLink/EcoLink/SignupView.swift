//
//  SignupView.swift
//  EcoLink
//
//  Created by Shashwath Dinesh on 7/12/25.
//

import SwiftUI

struct SignupView: View {
    @State private var companyName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var bio: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var isLoading: Bool = false
    @State private var wasteOutput: [String] = []
    @State private var errorMessage: String?
    @State private var navigateToHome: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.9), Color.teal]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        Spacer()
                        Text("🍃 EcoLink")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)

                        Text("Waste isn't waste — it's a resource in the wrong place!")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        VStack(spacing: 16) {
                            Group {
                                TextField("Company Name", text: $companyName)
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                SecureField("Password", text: $password)
                                TextEditor(text: $bio)
                                    .frame(height: 100)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2)))
                            }
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)

                            VStack {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                } else {
                                    Button(action: {
                                        isImagePickerPresented.toggle()
                                    }) {
                                        Label("Upload Logo", systemImage: "photo")
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(12)
                                    }
                                }
                            }

                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }

                            NavigationLink(destination: HomeView(userWaste: wasteOutput), isActive: $navigateToHome) {
                                EmptyView()
                            }.hidden()

                            Button(action: {
                                Task {
                                    await submit()
                                }
                            }) {
                                Text("Submit")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.8))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }

                            if let error = errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            if !wasteOutput.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Predicted Waste:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    ForEach(wasteOutput, id: \.self) { item in
                                        Text("• \(item)")
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 15)
                        .padding()
                    }
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $profileImage)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    func submit() async {
        guard !companyName.isEmpty, !email.isEmpty, !password.isEmpty, !bio.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        errorMessage = nil
        wasteOutput = []

        do {
            let result = try await callGeminiAPI(with: bio)
            wasteOutput = result
            navigateToHome = true
        } catch {
            errorMessage = "Failed to get Gemini response."
        }

        isLoading = false
    }
    func callGeminiAPI(with bio: String) async throws -> [String] {
        let apiKey = "API-KEY"
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)")!

        let prompt = """
        Analyze this company bio and return ONLY a list of types of waste the company might generate. Do not respond with any extra text. Do not go overboard with the list, only pick out the items that the company will ABSOLUTELY have a MASSIVE surplus or waste of. The sweet spot is around eight items, but go above or below that if you feel it is ABSOLUTELY necessary. Your response should be formatted like this: waste_item, waste_item, etc. Only use items from the list below, using the same exact wording:

        Obsolete computers, Old monitors, Broken printers, Circuit boards, Cables and wires, Batteries (rechargeable/disposable), Smartphones, Tablets, Network equipment, Server hardware, Electronic components, Power supplies, UPS units, Keyboards and mice, External hard drives, Scrap metal, Defective parts, Excess raw materials, Outdated inventory, Rejected product batches, Used solvents, Machine lubricants, Leftover adhesives, Packaging scraps, Spare mechanical parts, Worn conveyor belts, Sawdust and wood scraps, Paint or coating residue, Surplus paper, Ink and toner cartridges, Expired promotional materials, Broken furniture, Cardboard packaging, Plastic wrap, Cleaning chemicals, Lighting equipment, Used filters, Damaged safety gear, Aluminum cans, Plastic bottles, Glass containers, Corrugated cardboard, Soft plastics, Hard plastics, Paper waste, Wooden pallets, Shredded documents, Leftover drywall, Insulation scraps, Metal pipes, PVC piping, Wiring bundles, Flooring tile remnants, Paint cans

        Bio: \(bio)
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard
            let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = responseJSON["candidates"] as? [[String: Any]],
            let content = candidates.first?["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw URLError(.badServerResponse)
        }

        let items = text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return items
    }
}
