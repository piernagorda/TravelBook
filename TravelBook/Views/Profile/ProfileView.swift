//
//  TestViewProfile.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 9/29/24.
//

import SwiftUI

struct ProfileView: View {
    var userName: String
    weak var hostingController: ProfileViewHostingController?

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // Header takes up 1/3 of the screen height
                header(height: proxy.size.height / 3)
                bodyList()
            }.background(Color(red: 240/255, green: 240/255, blue: 246/255))
        }
    }
    
    @ViewBuilder
    func header(height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .cornerRadius(20)
            VStack {
                Image("JAVIER")
                    .resizable() // Allows the image to be resized
                    .scaledToFill() // Keeps the aspect ratio while fitting within the frame
                    .frame(width: height * 0.4, height: height * 0.4) // Smaller size based on header height
                    .clipShape(Circle()) // Makes the image circular
                    .shadow(radius: 5) // Optional: adds a shadow for better visual effect
                
                // Optional: Add a user name below the image
                Text("Javier Piernagorda")
                    .font(.headline)
                    .padding(.top, 8)
            }
        }
        .onTapGesture {
            self.hostingController?.didTapOnAchievements()
        }
        .frame(height: height) // Set the height to the passed value
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    func bodyList() -> some View {
        List {
            HStack {
                Text("Visited Countries")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hostingController?.didTapOnCountriesVisited()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userName: "Javier Piernagorda")
    }
}
