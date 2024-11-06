//
//  PostDetailView.swift
//  mealFinder
//
//  Created by Shujie on 11/6/24.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(post.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

  
                HStack {
                    Text("Likes: \(post.likes)")
                    Text("Dislikes: \(post.dislikes)")
                }
                .font(.subheadline)
                .foregroundColor(.gray)


                HStack {
                    Text("Created At: \(formatDate(post.createdAt))")
                    Text("Updated At: \(formatDate(post.updatedAt))")
                }
                .font(.footnote)
                .foregroundColor(.gray)

                Divider()


                Text(post.content)
                    .font(.body)
                    .padding(.top, 10)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
    }


    func formatDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
}

