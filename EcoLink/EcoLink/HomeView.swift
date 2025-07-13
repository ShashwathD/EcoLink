//
//  HomeView.swift
//  EcoLink
//
//  Created by Shashwath Dinesh on 7/13/25.
//

import SwiftUI

struct Company: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let matchingWaste: [String]
}

struct HomeView: View {
    @State private var selectedCategory: WasteCategory? = nil
    @State private var searchText = ""

    var userWaste: [String]

    let companies: [Company] = [
        Company(name: "GreenCycle Inc", description: "Specialists in electronics recycling.", matchingWaste: ["Obsolete computers", "Broken printers", "Batteries (rechargeable/disposable)"]),
        Company(name: "EcoMetal Solutions", description: "We handle scrap metal and defective parts.", matchingWaste: ["Scrap metal", "Defective parts"]),
        Company(name: "PaperPlus Recyclers", description: "Collecting office paper and surplus materials.", matchingWaste: ["Surplus paper", "Ink and toner cartridges"]),
        Company(name: "BuildRecycle", description: "Construction site cleanup and material recovery.", matchingWaste: ["Leftover drywall", "PVC piping", "Paint cans"]),
        Company(name: "BottleBank", description: "Plastic and aluminum bottle redemption service.", matchingWaste: ["Plastic bottles", "Aluminum cans"])
    ]

    var bestMatches: [Company] {
        companies.filter { company in
            !company.matchingWaste.filter { userWaste.contains($0) }.isEmpty
        }
    }

    var remainingCompanies: [Company] {
        companies.filter { !bestMatches.contains($0) }
    }

    var filteredCompanies: [Company] {
        let all = bestMatches + remainingCompanies

        return all.filter { company in
            let matchesCategory = selectedCategory == nil || !company.matchingWaste.filter { selectedCategory!.materials.contains($0) }.isEmpty
            let matchesSearch = searchText.isEmpty || company.name.localizedCaseInsensitiveContains(searchText) ||
                company.matchingWaste.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.9), Color.teal]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search companies or waste types", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(WasteCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }) {
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.white.opacity(0.8) : Color.white.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    ScrollView {
                        VStack(spacing: 12) {
                            if !bestMatches.isEmpty && selectedCategory == nil && searchText.isEmpty {
                                Text("🌟 Best Matches")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top)

                                ForEach(bestMatches) { company in
                                    CompanyCard(company: company, userWaste: userWaste, isBestMatch: true)
                                }
                            }

                            Text("🏢 All Companies")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, bestMatches.isEmpty ? 20 : 0)

                            ForEach(filteredCompanies) { company in
                                CompanyCard(company: company, userWaste: userWaste, isBestMatch: false)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("♻️ Matches")
        }
    }
}

struct CompanyCard: View {
    let company: Company
    let userWaste: [String]
    var isBestMatch: Bool

    var body: some View {
        NavigationLink(destination: CompanyDetailView(company: company, userWaste: userWaste)) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(company.name)
                        .font(.headline)
                        .foregroundColor(.black)

                    if isBestMatch {
                        Spacer()
                        Text("Best Match")
                            .font(.caption)
                            .padding(6)
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }

                Text(company.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    ForEach(company.matchingWaste.prefix(3), id: \.self) { item in
                        Text(item)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.black)
                            .cornerRadius(6)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .shadow(radius: 4)
        }
    }
}

struct CompanyDetailView: View {
    let company: Company
    let userWaste: [String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(company.name)
                    .font(.largeTitle)
                    .bold()

                Text(company.description)
                    .font(.body)

                Text("Accepted Waste:")
                    .font(.headline)
                    .padding(.top)

                ForEach(company.matchingWaste, id: \.self) { waste in
                    Text("• \(waste)")
                        .font(.subheadline)
                }

                NavigationLink(destination: ConnectView(company: company, userWaste: userWaste)) {
                    Text("🤝 Connect with \(company.name)")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.top, 20)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Company Info")
    }
}


enum WasteCategory: String, CaseIterable {
    case ewaste = "🖥️ E-Waste"
    case manufacturing = "🧱 Manufacturing Surplus"
    case office = "📦 Office Supplies"
    case recyclables = "♻️ Recyclables"
    case construction = "🛠️ Construction Waste"

    var materials: [String] {
        switch self {
        case .ewaste:
            return ["Obsolete computers", "Old monitors", "Broken printers", "Circuit boards", "Cables and wires", "Batteries (rechargeable/disposable)", "Smartphones", "Tablets", "Network equipment", "Server hardware", "Electronic components", "Power supplies", "UPS units", "Keyboards and mice", "External hard drives"]
        case .manufacturing:
            return ["Scrap metal", "Defective parts", "Excess raw materials", "Outdated inventory", "Rejected product batches", "Used solvents", "Machine lubricants", "Leftover adhesives", "Packaging scraps", "Spare mechanical parts", "Worn conveyor belts", "Sawdust and wood scraps", "Paint or coating residue"]
        case .office:
            return ["Surplus paper", "Ink and toner cartridges", "Expired promotional materials", "Broken furniture", "Cardboard packaging", "Plastic wrap", "Cleaning chemicals", "Lighting equipment", "Used filters", "Damaged safety gear"]
        case .recyclables:
            return ["Aluminum cans", "Plastic bottles", "Glass containers", "Corrugated cardboard", "Soft plastics", "Hard plastics", "Paper waste", "Wooden pallets", "Shredded documents"]
        case .construction:
            return ["Leftover drywall", "Insulation scraps", "Metal pipes", "PVC piping", "Wiring bundles", "Flooring tile remnants", "Paint cans"]
        }
    }
}

struct CompanyRow: View {
    let company: Company

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(company.name)
                .font(.headline)
            Text(company.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}



