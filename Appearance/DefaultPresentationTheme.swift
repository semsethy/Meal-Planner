//
//  DefaultPresentationTheme.swift
//  Meal Preparing
//
//  Created by JoshipTy on 23/8/24.
//

import Foundation
import UIKit

private func makeDefaultPresentationTheme(accentColor: UIColor, serviceBackgroundColor: UIColor, day: Bool) -> PresentationTheme {
    let destructiveColor: UIColor = UIColor(rgb: 0xff3b30)
    let constructiveColor: UIColor = UIColor(rgb: 0x00c900)
    let secretColor: UIColor = UIColor(rgb: 0x00B12C)

    /*
     let rootTabBar = PresentationThemeRootTabBar(
     backgroundColor: UIColor(rgb: 0xf7f7f7),
     separatorColor: UIColor(rgb: 0xa3a3a3),
     iconColor: UIColor(rgb: 0xA1A1A1),
     selectedIconColor: accentColor,
     textColor: UIColor(rgb: 0xA1A1A1),
     selectedTextColor: accentColor,
     badgeBackgroundColor: UIColor(rgb: 0xff3b30),
     badgeStrokeColor: UIColor(rgb: 0xff3b30),
     badgeTextColor: .white
     )
     */

    let navigationBar = PresentationThemeRootNavigationBar(
        buttonColor: UIColor(rgb: 0x0000ff),
        disabledButtonColor: UIColor(rgb: 0xd0d0d0),
        primaryTextColor: .black,
        secondaryTextColor: UIColor(rgb: 0x787878),
        barTintColor: .white,
        tintColor: UIColor(rgb: 0x0000ff),
        backgroundColor: UIColor.white,
        separatorColor: UIColor(red: 0.6953125, green: 0.6953125, blue: 0.6953125, alpha: 1.0),
        badgeBackgroundColor: UIColor(rgb: 0xff3b30),
        badgeStrokeColor: UIColor(rgb: 0xff3b30),
        badgeTextColor: .white
    )

    let viewController = PresentationThemeViewController(backgroundColor: .white)

    let tableView = PresentationThemeTableView(
        backgroundColor: .white,
        selectedBackgroundColor: .gray,
        groupBackgroundColor: .groupTableViewBackground,
        cellBackgroundColor: .white,
        cellAccessoryColor: .gray,
        separatorColor: .gray,
        skeletonGradientColor: .gray
    )

    let button = PresentationThemeButton(primaryColor: UIColor(rgb: 0x0000ff), secondaryColor: .gray, tintColor: UIColor(rgb: 0x0000ff), backgroundColor: UIColor(rgb: 0xf7f7f7), hightlightColor: UIColor(rgb: 0xffffff))
    let downloadButton = PresentationDownloadButton(initialColor: .white, rippleColor: .white, downloadColor: .white, deviceColor: .white, buttonBackgroundColor: .clear, backgroundColor: UIColor(rgb: 0x0000ff))
    let label = PresentationThemeLabel(primaryColor: .black, secondaryColor: .gray, mentionColor: UIColor(rgb: 0x3590EB), linkColor: UIColor(rgb: 0x3590EB), timeMessageColor: UIColor(rgb: 0x4a68b1))

    let popUpView = PresentationThemePopUp(primaryColor: UIColor(rgb: 0x007aff), secondaryColor: .gray, tintColor: UIColor(rgb: 0x007aff), backgroundColor: .white, hightlightColor: UIColor(white: 0.9, alpha: 1.0))

    let searchBar = PresentationThemeSearchBar(
        backgroundColor: UIColor(rgb: 0xf2f2f3),
        accentColor: accentColor,
        inputFillColor: UIColor(rgb: 0xe9e9e9),
        inputTextColor: .black,
        inputPlaceholderTextColor: UIColor(rgb: 0x8e8e93),
        inputIconColor: UIColor(rgb: 0x8e8e93),
        inputClearButtonColor: UIColor(rgb: 0x7b7b81),
        tintColor: UIColor(rgb: 0x007aff)
    )

    let switchColors = PresentationThemeSwitch(
        frameColor: UIColor(rgb: 0xe0e0e0),
        handleColor: UIColor(rgb: 0xffffff),
        contentColor: UIColor(rgb: 0x42d451),
        positiveColor: UIColor(rgb: 0x00B12C),
        negativeColor: destructiveColor
    )

    let list = PresentationThemeList(
        blocksBackgroundColor: UIColor(rgb: 0xefeff4),
        plainBackgroundColor: .white,
        itemPrimaryTextColor: .black,
        itemSecondaryTextColor: UIColor(rgb: 0x8e8e93),
        itemDisabledTextColor: UIColor(rgb: 0x8e8e93),
        itemAccentColor: accentColor,
        itemHighlightedColor: secretColor,
        itemDestructiveColor: destructiveColor,
        itemPlaceholderTextColor: UIColor(rgb: 0xc8c8ce),
        itemBlocksBackgroundColor: .white,
        itemHighlightedBackgroundColor: UIColor(rgb: 0xd9d9d9),
        itemBlocksSeparatorColor: UIColor(rgb: 0xc8c7cc),
        itemPlainSeparatorColor: UIColor(rgb: 0xc8c7cc),
        disclosureArrowColor: UIColor(rgb: 0xbab9be),
        sectionHeaderTextColor: UIColor(rgb: 0x6d6d72),
        freeTextColor: UIColor(rgb: 0x6d6d72),
        freeTextErrorColor: UIColor(rgb: 0xcf3030),
        freeTextSuccessColor: UIColor(rgb: 0x26972c),
        freeMonoIcon: UIColor(rgb: 0x7e7e87),
        itemSwitchColors: switchColors,
        itemDisclosureActions: PresentationThemeItemDisclosureActions(
            neutral1: PresentationThemeItemDisclosureAction(fillColor: UIColor(rgb: 0x4892f2), foregroundColor: .white),
            neutral2: PresentationThemeItemDisclosureAction(fillColor: UIColor(rgb: 0xf09a37), foregroundColor: .white),
            destructive: PresentationThemeItemDisclosureAction(fillColor: UIColor(rgb: 0xff3824), foregroundColor: .white),
            constructive: PresentationThemeItemDisclosureAction(fillColor: constructiveColor, foregroundColor: .white),
            accent: PresentationThemeItemDisclosureAction(fillColor: accentColor, foregroundColor: .white),
            warning: PresentationThemeItemDisclosureAction(fillColor: UIColor(rgb: 0xff9500), foregroundColor: .white),
            inactive: PresentationThemeItemDisclosureAction(fillColor: UIColor(rgb: 0xbcbcc3), foregroundColor: .white)
        ),
        itemCheckColors: PresentationThemeCheck(
            strokeColor: UIColor(rgb: 0xC7C7CC),
            fillColor: accentColor,
            foregroundColor: .white
        ),
        controlSecondaryColor: UIColor(rgb: 0xdedede),
        freeInputField: PresentationInputFieldTheme(
            backgroundColor: UIColor(rgb: 0xd6d6dc),
            placeholderColor: UIColor(rgb: 0x96979d),
            primaryColor: .black,
            controlColor: UIColor(rgb: 0x96979d)
        ),
        mediaPlaceholderColor: UIColor(rgb: 0xe4e4e4),
        scrollIndicatorColor: UIColor(white: 0.0, alpha: 0.3),
        pageIndicatorInactiveColor: UIColor(rgb: 0xe3e3e7)
    )

    let chatList = PresentationThemeChatList(
        backgroundColor: .white,
        itemSeparatorColor: UIColor(rgb: 0xc8c7cc),
        itemBackgroundColor: .white,
        pinnedItemBackgroundColor: UIColor(rgb: 0xf7f7f7),
        itemHighlightedBackgroundColor: UIColor(rgb: 0xd9d9d9),
        itemSelectedBackgroundColor: UIColor(rgb: 0xe9f0fa),
        titleColor: .black,
        secretTitleColor: secretColor,
        dateTextColor: UIColor(rgb: 0x8e8e93),
        authorNameColor: .black,
        messageTextColor: UIColor(rgb: 0x8e8e93),
        messageDraftTextColor: UIColor(rgb: 0xdd4b39),
        checkmarkColor: UIColor(rgb: 0x21c004),
        pendingIndicatorColor: UIColor(rgb: 0x8e8e93),
        muteIconColor: UIColor(rgb: 0xa7a7ad),
        unreadBadgeActiveBackgroundColor: accentColor,
        unreadBadgeActiveTextColor: .white,
        unreadBadgeInactiveBackgroundColor: UIColor(rgb: 0xb6b6bb),
        unreadBadgeInactiveTextColor: .white,
        pinnedBadgeColor: UIColor(rgb: 0xb6b6bb),
        pinnedSearchBarColor: UIColor(rgb: 0xe5e5e5),
        regularSearchBarColor: UIColor(rgb: 0xe9e9e9),
        sectionHeaderFillColor: UIColor(rgb: 0xf7f7f7),
        sectionHeaderTextColor: UIColor(rgb: 0x8e8e93),
        searchBarKeyboardColor: .light,
        verifiedIconFillColor: accentColor,
        verifiedIconForegroundColor: .white,
        secretIconColor: secretColor,
        pinnedArchiveAvatarColor: PresentationThemeArchiveAvatarColors(backgroundColors: (UIColor(rgb: 0x72d5fd), UIColor(rgb: 0x2a9ef1)), foregroundColor: .white),
        unpinnedArchiveAvatarColor: PresentationThemeArchiveAvatarColors(backgroundColors: (UIColor(rgb: 0xDEDEE5), UIColor(rgb: 0xC5C6CC)), foregroundColor: .white),
        onlineDotColor: UIColor(rgb: 0x4cc91f)
    )

    let bubble = PresentationThemeChatBubble(
        incoming: PresentationThemeBubbleColor(
            withWallpaper: PresentationThemeBubbleColorComponents(
                bubleColor: .white,
                textColor: .black,
                tintColor: UIColor(rgb: 0x0000ff),
                timeMessageColor: UIColor(rgb: 0x4a68b1)
            ),
            withoutWallpaper: PresentationThemeBubbleColorComponents(
                bubleColor: .white,
                textColor: .black,
                tintColor: UIColor(rgb: 0x0000ff),
                timeMessageColor: UIColor(rgb: 0x4a68b1)
            ),
            label: label
        ),
        outgoing: PresentationThemeBubbleColor(
            withWallpaper: PresentationThemeBubbleColorComponents(
                bubleColor: UIColor(rgb: 0x191970),
                textColor: .white,
                tintColor: .white,
                timeMessageColor: .white
            ),
            withoutWallpaper: PresentationThemeBubbleColorComponents(
                bubleColor: UIColor(rgb: 0x191970),
                textColor: .white,
                tintColor: .white,
                timeMessageColor: .white
            ),
            label:
                PresentationThemeLabel(
                    primaryColor: .white,
                    secondaryColor: .gray,
                    mentionColor: UIColor(rgb: 0x3590EB),
                    linkColor: UIColor(rgb: 0x3590EB),
                    timeMessageColor: UIColor(rgb: 0x4a68b1)
                )
        ),
        freeform: PresentationThemeBubbleColor(
            withWallpaper: PresentationThemeBubbleColorComponents(
                bubleColor: .white,
                textColor: .black,
                tintColor: UIColor(rgb: 0x0000ff),
                timeMessageColor: UIColor(rgb: 0x4a68b1)
            ),
            withoutWallpaper: PresentationThemeBubbleColorComponents(
                bubleColor: .white,
                textColor: .black,
                tintColor: UIColor(rgb: 0x0000ff),
                timeMessageColor: UIColor(rgb: 0x4a68b1)
            ),
            label: label
        ),
        incomingPrimaryTextColor: UIColor(rgb: 0x000000),
        incomingSecondaryTextColor: UIColor(rgb: 0x525252, alpha: 0.6),
        incomingLinkTextColor: UIColor(rgb: 0x004bad),
        incomingLinkHighlightColor: accentColor.withAlphaComponent(0.3),
        outgoingPrimaryTextColor: UIColor(rgb: 0x000000),
        outgoingSecondaryTextColor: UIColor(rgb: 0x008c09, alpha: 0.8),
        outgoingLinkTextColor: UIColor(rgb: 0x004bad),
        outgoingLinkHighlightColor: accentColor.withAlphaComponent(0.3),
        infoPrimaryTextColor: UIColor(rgb: 0x000000),
        infoLinkTextColor: UIColor(rgb: 0x004bad),
        incomingTextHighlightColor: UIColor(rgb: 0xffe438),
        outgoingTextHighlightColor: UIColor(rgb: 0xffe438),
        incomingAccentTextColor: UIColor(rgb: 0x007ee5),
        outgoingAccentTextColor: UIColor(rgb: 0x00a700),
        incomingAccentControlColor: UIColor(rgb: 0x007ee5),
        outgoingAccentControlColor: UIColor(rgb: 0x3fc33b),
        incomingMediaActiveControlColor: UIColor(rgb: 0x007ee5),
        outgoingMediaActiveControlColor: UIColor(rgb: 0x3fc33b),
        incomingMediaInactiveControlColor: UIColor(rgb: 0xcacaca),
        outgoingMediaInactiveControlColor: UIColor(rgb: 0x93d987),
        outgoingCheckColor: UIColor(rgb: 0x19c700),
        incomingPendingActivityColor: UIColor(rgb: 0x525252, alpha: 0.6),
        outgoingPendingActivityColor: UIColor(rgb: 0x42b649),
        mediaDateAndStatusFillColor: UIColor(white: 0.0, alpha: 0.5),
        mediaDateAndStatusTextColor: .white,
        incomingFileTitleColor: UIColor(rgb: 0x0b8bed),
        outgoingFileTitleColor: UIColor(rgb: 0x3faa3c),
        incomingFileDescriptionColor: UIColor(rgb: 0x999999),
        outgoingFileDescriptionColor: UIColor(rgb: 0x6fb26a),
        incomingFileDurationColor: UIColor(rgb: 0x525252, alpha: 0.6),
        outgoingFileDurationColor: UIColor(rgb: 0x008c09, alpha: 0.8),
        shareButtonFillColor: PresentationThemeVariableColor(withWallpaper: serviceBackgroundColor, withoutWallpaper: UIColor(rgb: 0x748391, alpha: 0.45)),
        shareButtonStrokeColor: PresentationThemeVariableColor(withWallpaper: .clear, withoutWallpaper: .clear),
        shareButtonForegroundColor: PresentationThemeVariableColor(withWallpaper: .white, withoutWallpaper: .white),
        mediaOverlayControlBackgroundColor: UIColor(white: 0.0, alpha: 0.6),
        mediaOverlayControlForegroundColor: UIColor(white: 1.0, alpha: 1.0),
        actionButtonsIncomingFillColor: PresentationThemeVariableColor(withWallpaper: serviceBackgroundColor, withoutWallpaper: UIColor(rgb: 0x596e89, alpha: 0.35)),
        actionButtonsIncomingStrokeColor: PresentationThemeVariableColor(color: .clear),
        actionButtonsIncomingTextColor: PresentationThemeVariableColor(color: .white),
        actionButtonsOutgoingFillColor: PresentationThemeVariableColor(withWallpaper: serviceBackgroundColor, withoutWallpaper: UIColor(rgb: 0x596e89, alpha: 0.35)),
        actionButtonsOutgoingStrokeColor: PresentationThemeVariableColor(color: .clear),
        actionButtonsOutgoingTextColor: PresentationThemeVariableColor(color: .white),
        selectionControlBorderColor: UIColor(rgb: 0xc7c7cc),
        selectionControlFillColor: accentColor,
        selectionControlForegroundColor: .white,
        mediaHighlightOverlayColor: UIColor(white: 1.0, alpha: 0.6),
        deliveryFailedFillColor: destructiveColor,
        deliveryFailedForegroundColor: .white,
        incomingMediaPlaceholderColor: UIColor(rgb: 0xe8ecf0),
        outgoingMediaPlaceholderColor: UIColor(rgb: 0xd2f2b6),
        incomingPolls: PresentationThemeChatBubblePolls(
            radioButton: UIColor(rgb: 0xc8c7cc),
            radioProgress: UIColor(rgb: 0x007ee5),
            highlight: UIColor(rgb: 0x007ee5).withAlphaComponent(0.08),
            separator: UIColor(rgb: 0xc8c7cc),
            bar: UIColor(rgb: 0x007ee5)
        ),
        outgoingPolls: PresentationThemeChatBubblePolls(
            radioButton: UIColor(rgb: 0x93d987),
            radioProgress: UIColor(rgb: 0x3fc33b),
            highlight: UIColor(rgb: 0x3fc33b).withAlphaComponent(0.08),
            separator: UIColor(rgb: 0x93d987), bar: UIColor(rgb: 0x3fc33b)
        ),
        replyBackGroundColor: UIColor(rgb: 0xCCCCCC).withAlphaComponent(0.30)
    )

    let serviceMessage = PresentationThemeServiceMessage(
        components: PresentationThemeServiceMessageColor(withDefaultWallpaper: PresentationThemeServiceMessageColorComponents(
            fill: UIColor(rgb: 0x748391, alpha: 0.45),
            primaryText: .white,
            linkHighlight: UIColor(rgb: 0x748391, alpha: 0.25),
            dateFillStatic: UIColor(rgb: 0x748391, alpha: 0.45),
            dateFillFloating: UIColor(rgb: 0x939fab, alpha: 0.5)
        ),
        withCustomWallpaper: PresentationThemeServiceMessageColorComponents(
            fill: serviceBackgroundColor,
            primaryText: .white,
            linkHighlight: UIColor(rgb: 0x748391, alpha: 0.25),
            dateFillStatic: serviceBackgroundColor,
            dateFillFloating: serviceBackgroundColor.withAlphaComponent(serviceBackgroundColor.alpha * 0.6667))
        ),
        unreadBarFillColor: UIColor(white: 1.0, alpha: 0.9),
        unreadBarStrokeColor: UIColor(white: 0.0, alpha: 0.2),
        unreadBarTextColor: UIColor(rgb: 0x86868d),
        dateTextColor: PresentationThemeVariableColor(color: .white)
    )

    let inputPanelMediaRecordingControl = PresentationThemeChatInputPanelMediaRecordingControl(
        buttonColor: accentColor,
        micLevelColor: accentColor.withAlphaComponent(0.2),
        activeIconColor: .white,
        panelControlFillColor: UIColor(rgb: 0xf7f7f7),
        panelControlStrokeColor: UIColor(rgb: 0xb2b2b2),
        panelControlContentPrimaryColor: UIColor(rgb: 0x9597a0),
        panelControlContentAccentColor: accentColor
    )

    let inputPanel = PresentationThemeChatInputPanel(
        panelBackgroundColor: UIColor(rgb: 0xf7f7f7),
        panelStrokeColor: UIColor(rgb: 0xb2b2b2),
        panelControlAccentColor: accentColor,
        panelControlColor: UIColor(rgb: 0x858e99),
        panelControlDisabledColor: UIColor(rgb: 0x727b87, alpha: 0.5),
        panelControlDestructiveColor: UIColor(rgb: 0xff3b30),
        inputBackgroundColor: UIColor(rgb: 0xffffff),
        inputStrokeColor: UIColor(rgb: 0xd9dcdf),
        inputPlaceholderColor: UIColor(rgb: 0xbebec0),
        inputTextColor: .black,
        inputControlColor: UIColor(rgb: 0xa0a7b0),
        actionControlFillColor: accentColor,
        actionControlForegroundColor: .white,
        primaryTextColor: .black,
        secondaryTextColor: UIColor(rgb: 0x8e8e93),
        mediaRecordingDotColor: UIColor(rgb: 0xed2521),
        keyboardColor: .light,
        mediaRecordingControl: inputPanelMediaRecordingControl
    )

    let inputMediaPanel = PresentationThemeInputMediaPanel(
        panelSeparatorColor: UIColor(rgb: 0xBEC2C6),
        panelIconColor: UIColor(rgb: 0x858e99),
        panelHighlightedIconBackgroundColor: UIColor(rgb: 0x858e99, alpha: 0.2),
        stickersBackgroundColor: UIColor(rgb: 0xe8ebf0),
        stickersSectionTextColor: UIColor(rgb: 0x9099A2),
        stickersSearchBackgroundColor: UIColor(rgb: 0xd9dbe1),
        stickersSearchPlaceholderColor: UIColor(rgb: 0x8e8e93),
        stickersSearchPrimaryColor: .black,
        stickersSearchControlColor: UIColor(rgb: 0x8e8e93),
        gifsBackgroundColor: .white
    )

    let inputButtonPanel = PresentationThemeInputButtonPanel(
        panelSeparatorColor: UIColor(rgb: 0xBEC2C6),
        panelBackgroundColor: UIColor(rgb: 0xdee2e6),
        buttonFillColor: .white,
        buttonStrokeColor: UIColor(rgb: 0xc3c7c9),
        buttonHighlightedFillColor: UIColor(rgb: 0xa8b3c0),
        buttonHighlightedStrokeColor: UIColor(rgb: 0xc3c7c9),
        buttonTextColor: .black
    )

    let historyNavigation = PresentationThemeChatHistoryNavigation(
        fillColor: .white,
        strokeColor: UIColor(rgb: 0x000000, alpha: 0.15),
        foregroundColor: UIColor(rgb: 0x88888D),
        badgeBackgroundColor: accentColor,
        badgeStrokeColor: accentColor,
        badgeTextColor: .white
    )

    let chat = PresentationThemeChat(
        bubble: bubble,
        serviceMessage: serviceMessage,
        inputPanel: inputPanel,
        inputMediaPanel: inputMediaPanel,
        inputButtonPanel: inputButtonPanel,
        historyNavigation: historyNavigation
    )

    let actionSheet = PresentationThemeActionSheet(
        dimColor: UIColor(white: 0.0, alpha: 0.4),
        backgroundType: .light,
        opaqueItemBackgroundColor: .white,
        itemBackgroundColor: UIColor(white: 1.0, alpha: 0.8),
        opaqueItemHighlightedBackgroundColor: UIColor(white: 0.9, alpha: 1.0),
        itemHighlightedBackgroundColor: UIColor(white: 0.9, alpha: 0.7),
        standardActionTextColor: accentColor,
        opaqueItemSeparatorColor: UIColor(white: 0.9, alpha: 1.0),
        destructiveActionTextColor: destructiveColor,
        disabledActionTextColor: UIColor(rgb: 0x4d4d4d),
        primaryTextColor: .black,
        secondaryTextColor: UIColor(rgb: 0x5e5e5e),
        controlAccentColor: accentColor,
        inputBackgroundColor: UIColor(rgb: 0xe9e9e9),
        inputPlaceholderColor: UIColor(rgb: 0x818086),
        inputTextColor: .black,
        inputClearButtonColor: UIColor(rgb: 0x7b7b81),
        checkContentColor: .white
    )

    let stickerView = PresentationThemeStickerView(
        headerBackgroundColor: UIColor(rgb: 0xf7f7f7),
        selectedHeaderColor: UIColor(rgb: 0xdedfe1),
        backgroundColor: UIColor(rgb: 0xe9eaef),
        footerColor: UIColor(rgb: 0xdedffe1))
    /*
     let inAppNotification = PresentationThemeInAppNotification(
     fillColor: .white,
     primaryTextColor: .black,
     expandedNotification: PresentationThemeExpandedNotification(
     backgroundType: .light,
     navigationBar: PresentationThemeExpandedNotificationNavigationBar(
     backgroundColor: .white,
     primaryTextColor: .black,
     controlColor: UIColor(rgb: 0x7e8791),
     separatorColor: UIColor(red: 0.6953125, green: 0.6953125, blue: 0.6953125, alpha: 1.0)
     )
     )
     )
     */

    return PresentationTheme(
        name: .builtin(day ? .day : .dayClassic),
        statusBarStyle: UIStatusBarStyle.default,
        allowsCustomWallpapers: true,
        list: list,
        chatList: chatList,
        chat: chat,
        actionSheet: actionSheet, viewController: viewController,
        navigationBar: navigationBar,
        tableView: tableView,
        button: button,
        label: label,
        popUpView: popUpView,
        searchBar: searchBar,
        stickerView: stickerView,
        downloadButton: downloadButton
    )
}

public let defaultPresentationTheme = makeDefaultPresentationTheme(accentColor: UIColor(rgb: 0x007ee5), serviceBackgroundColor: defaultServiceBackgroundColor, day: false)

let defaultDayAccentColor: Int32 = 0x007ee5
let defaultServiceBackgroundColor: UIColor = UIColor(rgb: 0x000000, alpha: 0.3)

func makeDefaultPresentationTheme(serviceBackgroundColor: UIColor?) -> PresentationTheme {
    return makeDefaultPresentationTheme(accentColor: UIColor(rgb: 0x007ee5), serviceBackgroundColor: serviceBackgroundColor ?? .black, day: false)
}

func makeDefaultDayPresentationTheme(accentColor: Int32?, serviceBackgroundColor: UIColor) -> PresentationTheme {
    let color: UIColor
    if let accentColor = accentColor {
        color = UIColor(rgb: UInt32(bitPattern: accentColor))
    } else {
        color = UIColor(rgb: UInt32(bitPattern: defaultDayAccentColor))
    }
    return makeDefaultPresentationTheme(accentColor: color, serviceBackgroundColor: serviceBackgroundColor, day: true)
}
