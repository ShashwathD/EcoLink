//
//  ConnectView.swift
//  EcoLink
//
//  Created by Shashwath Dinesh on 7/13/25.
//

import SwiftUI

struct ConnectView: View {
    let company: Company
    let userWaste: [String]

    @State private var message: String = ""
    @State private var review: String = ""
    @State private var submitted = false

    var sharedWaste: [String] {
        company.matchingWaste.filter { userWaste.contains($0) }
    }

    var logoName: String {
        return "building.2.crop.circle.fill"
    }

    var location: String {
        return "🌍 Unknown Location"
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.3), Color.green.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: logoName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(company.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Text(location)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("🤖 Why We Matched You")
                            .font(.headline)

                        if sharedWaste.isEmpty {
                            Text("There are no clear matches found.")
                                .foregroundColor(.gray)
                        } else {
                            Text("You and **\(company.name)** both handle:")
                            ForEach(sharedWaste, id: \.self) { waste in
                                Text("• \(waste)")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 3)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("📬 Send a Message")
                            .font(.headline)

                        TextEditor(text: $message)
                            .frame(height: 120)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2))
                            )

                        NavigationLink(destination: MessagingView(company: company, initialMessage: message)) {
                            Text("Send Message")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("⭐ Leave a Review")
                            .font(.headline)

                        TextEditor(text: $review)
                            .frame(height: 80)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2))
                            )

                        Button(action: {
                            withAnimation {
                                submitted = true
                            }
                        }) {
                            Text("Submit Review")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.7))
                                .cornerRadius(12)
                        }
                    }

                    if submitted {
                        Text("✅ Thank you! Your message and/or review has been submitted.")
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("🤝 Connect")
    }
}
