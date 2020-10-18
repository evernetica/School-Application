import Alamofire
import Foundation

class CategoryJSON: Codable {
    let status: String
    let count: Int
    let categories: [Category]

    init(status: String, count: Int, categories: [Category]) {
        self.status = status
        self.count = count
        self.categories = categories
    }
}

class Category: Codable {
    let id: Int
    let slug, title, categoryDescription: String
    let parent, postCount: Int

    enum CodingKeys: String, CodingKey {
        case id, slug, title
        case categoryDescription = "description"
        case parent
        case postCount = "post_count"
    }

    init(id: Int, slug: String, title: String, categoryDescription: String, parent: Int, postCount: Int) {
        self.id = id
        self.slug = slug
        self.title = title
        self.categoryDescription = categoryDescription
        self.parent = parent
        self.postCount = postCount
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, _, data, error in
            guard error == nil else { return .failure(error!) }

            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }

            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }

    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }

    @discardableResult
    func responseCategoryJSON(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<CategoryJSON>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
