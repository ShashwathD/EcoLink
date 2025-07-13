//
//  MessagingView.swift
//  EcoLink
//
//  Created by Shashwath Dinesh on 7/13/25.
//

import SwiftUI

struct MessagingView: View {
    let company: Company
    let initialMessage: String

    @State private var newMessage: String = ""
    @State private var messages: [(String, Bool)] = []

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.4)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages.indices, id: \.self) { index in
                            let message = messages[index]
                            HStack {
                                if message.1 {
                                    Spacer()
                                    Text(message.0)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else {
                                    Text(message.0)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(16)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Type your message...", text: $newMessage)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)

                    Button(action: {
                        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }

                        messages.append((trimmed, true))
                        newMessage = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .navigationTitle("Chat with \(company.name)")
        .onAppear {
            messages.append((initialMessage, true))
            messages.append(("Yes of course! Let's coordinate over call. Here's my number: 123-456-7890.", false))
        }
    }
}
