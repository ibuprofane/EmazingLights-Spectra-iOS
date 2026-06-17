import SwiftUI
import UIKit

struct ResourceImage: View {
    var name: String
    var contentMode: ContentMode = .fit

    var body: some View {
        Group {
            if let image = UIImage(named: name) ?? UIImage(named: "ProgrammingImages/\(name)") ?? imageFromBundle {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary)
                    Image(systemName: "sparkles")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var imageFromBundle: UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "ProgrammingImages") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}
