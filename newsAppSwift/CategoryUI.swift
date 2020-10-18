import Foundation

class CategoryUI {
    init() {
        id = nil
        slug = nil
        categoryDescription = nil
        title = nil
        postCount = nil
        child = []
    }

    var id: Int?
    var slug, title, categoryDescription: String?
    var postCount: Int?
    var child: [Category]?
    var isSelected = false
}
