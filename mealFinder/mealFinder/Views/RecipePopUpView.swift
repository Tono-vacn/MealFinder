//
//  RecipePopUpView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct RecipePopUpView: View {
    let recipe: Recipe
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack {
            // 标题和关闭按钮
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .padding()
            }

            // 菜谱标题
            Text(recipe.title)
                .font(.title)
                .padding()

            // 菜谱图片
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 150)
            .padding()

            // 翻页按钮
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                Spacer()
                Button(action: onNext) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
            }
            .padding()

            Spacer()
        }
        .frame(width: 370, height: 700)  // 中央窗口大小
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
    }
}
