//
//  ClubUpdatePostContentView.swift
//  AmityUIKit4
//
//  David Lloyd — Club Update posts.
//

import SwiftUI
import AmitySDK

struct ClubUpdatePostContentView: View {
    @EnvironmentObject private var host: AmitySwiftUIHostWrapper
    @StateObject private var viewConfig: AmityViewConfigController
    @Environment(\.colorScheme) private var colorScheme

    @State private var showBottomSheet: Bool = false
    @State private var showShareSheet: Bool = false

    private let post: AmityPostModel
    private let style: AmityPostContentComponentStyle
    private let pageId: PageId?
    private let onTapAction: (() -> Void)?

    init(post: AmityPostModel,
         style: AmityPostContentComponentStyle = .feed,
         pageId: PageId? = nil,
         onTapAction: (() -> Void)? = nil) {
        self.post = post
        self.style = style
        self.pageId = pageId
        self.onTapAction = onTapAction
        self._viewConfig = StateObject(
            wrappedValue: AmityViewConfigController(pageId: pageId, componentId: .postContentComponent))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            contentView
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(viewConfig.theme.backgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(viewConfig.theme.primaryColor).opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onTapAction?() }
        .updateTheme(with: viewConfig)        
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .top, spacing: 8) {
            AmityUserProfileImageView(
                displayName: post.postedUser?.displayName ?? AmityLocalizedStringSet.General.anonymous.localizedString,
                avatarURL: URL(string: post.postedUser?.avatarURL ?? ""))
            .frame(size: CGSize(width: 32.0, height: 32.0))
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(post.displayName)
                        .applyTextStyle(.bodyBold(Color(viewConfig.theme.baseColor)))
                        .lineLimit(1)

                    if post.isFromBrand {
                        Image(AmityIcon.brandBadge.imageResource)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                }

                Text("\(post.timestamp)\(post.isEdited ? " \(AmityLocalizedStringSet.Comment.editedText.localizedString)" : "")")
                    .applyTextStyle(.caption(Color(viewConfig.theme.baseColorShade1)))
            }

            Spacer(minLength: 8)

            ClubUpdateBadge()
                .environmentObject(viewConfig)

            // The mock shows no overflow menu on the card, but the author still has to be
            // able to edit or delete what they posted — so it lives on the detail page.
            if style == .detail {
                menuButton
            }
        }
    }

    @ViewBuilder
    private var menuButton: some View {
        Button(action: { showBottomSheet.toggle() }) {
            let menuIcon = AmityIcon.getImageResource(
                named: viewConfig.getConfig(elementId: .menuButton, key: "icon", of: String.self) ?? "")
            Image(menuIcon)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(viewConfig.theme.baseColor))
                .frame(width: 24, height: 24)
        }
        .buttonStyle(PlainButtonStyle())
        .bottomSheet(isShowing: $showBottomSheet,
                     height: .contentSize,
                     backgroundColor: Color(viewConfig.theme.backgroundColor)) {
            PostBottomSheetView(isShown: $showBottomSheet, post: post, toastBottomPadding: 0) { action in
                switch action {
                case .editPost:
                    showBottomSheet.toggle()
                    host.controller?.dismiss(animated: false)
                    showPostEditScreen()
                case .sharePost:
                    showShareSheet = true
                case .closePoll, .deletePost, .reportPost:
                    break
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareActivitySheetView(
                link: AmityUIKitManagerInternal.shared.generateShareableLink(for: .post, id: post.postId))
        }
    }

    private func showPostEditScreen() {
        let page = AmityPostComposerPage(options: .editOptions(mode: .edit, post: post))
        let controller = AmitySwiftUIHostingController(rootView: page)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        host.controller?.present(navigationController, animated: true)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !post.title.isEmpty {
                Text(post.title)
                    .applyTextStyle(.titleBold(Color(viewConfig.theme.baseColor)))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !post.text.isEmpty {
                ExpandableText(post.text,
                               defaultAction: style == .feed ? { onTapAction?() } : nil,
                               metadata: post.metadata,
                               mentionees: post.mentionees,
                               links: post.links,
                               fadeTruncatedText: false)
                .lineLimit(style == .detail ? 1000 : 8)
                .moreButtonText(AmityLocalizedStringSet.Social.expandableTextSeeMore.localizedString)
                .font(AmityTextStyle.body(.clear).getFont())
                .foregroundColor(Color(viewConfig.theme.baseColor))
                .attributedColor(UIColor.defaultAttributeColor(viewConfig: viewConfig, colorScheme: colorScheme))
                .moreButtonColor(Color(UIColor.defaultMoreButtonColor(viewConfig: viewConfig, colorScheme: colorScheme)))
                .expandAnimation(.easeOut(duration: 0.25))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !post.medias.isEmpty {
                PostContentMediaView(post: post, viewConfig: viewConfig, pageId: pageId)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                PreviewLinkView(post: post)
            }
        }
    }
}

struct ClubUpdateBadge: View {
    @EnvironmentObject private var viewConfig: AmityViewConfigController

    var body: some View {
        HStack(spacing: 4) {
            Image(AmityIcon.infoIcon.imageResource)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 14, height: 14)

            Text(AmityLocalizedStringSet.Social.clubUpdateBadge.localizedString)
                .applyTextStyle(.captionBold(Color(viewConfig.theme.primaryColor)))
        }
        .foregroundColor(Color(viewConfig.theme.primaryColor))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(viewConfig.theme.primaryColor).opacity(0.12))
        .clipShape(Capsule())
    }
}
