//
//  AmityClubUpdatePost.swift
//  AmityUIKit4
//
//  David Lloyd — Club Update posts.
//

import SwiftUI

public struct AmityClubUpdatePost {
    public let postId: String
    public let authorName: String
    public let authorAvatarURL: URL?
    public let isFromBrand: Bool
    public let timestamp: String
    public let isEdited: Bool
    public let title: String
    public let text: String
    public let imageURLs: [URL]

    init(post: AmityPostModel) {
        self.postId = post.postId
        self.authorName = post.displayName
        self.authorAvatarURL = URL(string: post.postedUser?.avatarURL ?? "")
        self.isFromBrand = post.isFromBrand
        self.timestamp = post.timestamp
        self.isEdited = post.isEdited
        self.title = post.title
        self.text = post.text
        self.imageURLs = post.medias.compactMap { media in
            guard let url = media.image?.fileURL else { return nil }
            return URL(string: url)
        }
    }
}

public typealias AmityClubUpdatePostRenderer = (
    _ post: AmityClubUpdatePost,
    _ style: AmityPostContentComponentStyle,
    _ onTap: @escaping () -> Void
) -> AnyView

struct ClubUpdatePostHost: View {
    let post: AmityPostModel
    var style: AmityPostContentComponentStyle = .feed
    var pageId: PageId?
    let onTap: () -> Void

    var body: some View {
        if let renderer = AmityUIKitManagerInternal.shared.behavior.clubUpdatePostRenderer {
            renderer(AmityClubUpdatePost(post: post), style, onTap)
        } else {
            ClubUpdatePostContentView(post: post, style: style, pageId: pageId, onTapAction: onTap)
        }
    }
}
