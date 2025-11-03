struct AutodocNewsEntity: Decodable {
    let news: [News]

    struct News: Decodable {
        let id: Int?
        let title: String?
        let fullUrl: String?
        let titleImageUrl: String?
    }
}
