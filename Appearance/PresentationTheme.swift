//
//  PresentationTheme.swift
//  Meal Preparing
//
//  Created by JoshipTy on 23/8/24.
//


import Foundation
import UIKit
extension UIColor {
    convenience init(rgb: UInt32) {
        let red = CGFloat((rgb >> 16) & 0xff) / 255.0
        let green = CGFloat((rgb >> 8) & 0xff) / 255.0
        let blue = CGFloat(rgb & 0xff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    convenience init(rgb: UInt32, alpha: CGFloat) {
        let red = CGFloat((rgb >> 16) & 0xff) / 255.0
        let green = CGFloat((rgb >> 8) & 0xff) / 255.0
        let blue = CGFloat(rgb & 0xff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var alpha: CGFloat {
        var alpha: CGFloat = 0.0
        if self.getRed(nil, green: nil, blue: nil, alpha: &alpha) {
            return alpha
        } else if self.getWhite(nil, alpha: &alpha) {
            return alpha
        } else {
            return 0.0
        }
    }
    
    func mixedWith(_ other: UIColor, alpha: CGFloat) -> UIColor {
        let alpha = min(1.0, max(0.0, alpha))
        let oneMinusAlpha = 1.0 - alpha

        var red1: CGFloat = 0.0
        var red2: CGFloat = 0.0
        var green1: CGFloat = 0.0
        var green2: CGFloat = 0.0
        var blue1: CGFloat = 0.0
        var blue2: CGFloat = 0.0
        var alpha1: CGFloat = 0.0
        var alpha2: CGFloat = 0.0
        if self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1) &&
            other.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2) {
            let red = red1 * oneMinusAlpha + red2 * alpha
            let green = green1 * oneMinusAlpha + green2 * alpha
            let blue = blue1 * oneMinusAlpha + blue2 * alpha
            let alpha = alpha1 * oneMinusAlpha + alpha2 * alpha
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        return self
    }
}

public final class PresentationThemeRootTabBar {
    public let backgroundColor: UIColor
    public let separatorColor: UIColor
    public let iconColor: UIColor
    public let selectedIconColor: UIColor
    public let textColor: UIColor
    public let selectedTextColor: UIColor
    public let badgeBackgroundColor: UIColor
    public let badgeStrokeColor: UIColor
    public let badgeTextColor: UIColor

    public init(backgroundColor: UIColor, separatorColor: UIColor, iconColor: UIColor, selectedIconColor: UIColor, textColor: UIColor, selectedTextColor: UIColor, badgeBackgroundColor: UIColor, badgeStrokeColor: UIColor, badgeTextColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.iconColor = iconColor
        self.selectedIconColor = selectedIconColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeStrokeColor = badgeStrokeColor
        self.badgeTextColor = badgeTextColor
    }
}

public final class PresentationThemeViewController {

    public let backgroundColor: UIColor

    init(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
}

public final class PresentationThemeStickerView {
    public let headerBackgroundColor: UIColor
    public let selectedHeaderColor: UIColor
    public let backgroundColor: UIColor
    public let footerColor: UIColor

    init(
        headerBackgroundColor: UIColor,
        selectedHeaderColor: UIColor,
        backgroundColor: UIColor,
        footerColor: UIColor) {
        self.headerBackgroundColor = headerBackgroundColor
        self.selectedHeaderColor = selectedHeaderColor
        self.backgroundColor = backgroundColor
        self.footerColor = footerColor
    }
}

public final class PresentationThemeTableView {

    public let backgroundColor: UIColor
    public let selectedBackgroundColor: UIColor
    public let groupBackgroundColor: UIColor
    public let cellBackgroundColor: UIColor
    public let cellAccessoryColor: UIColor
    public let separatorColor: UIColor
    public let skeletonGradientColor: UIColor

    init(backgroundColor: UIColor, selectedBackgroundColor: UIColor, groupBackgroundColor: UIColor, cellBackgroundColor: UIColor, cellAccessoryColor: UIColor, separatorColor: UIColor, skeletonGradientColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.groupBackgroundColor = groupBackgroundColor
        self.cellBackgroundColor = cellBackgroundColor
        self.cellAccessoryColor = cellAccessoryColor
        self.separatorColor = separatorColor
        self.skeletonGradientColor = skeletonGradientColor
    }
}

public final class PresentationThemeButton {

    public let primaryColor: UIColor
    public let secondaryColor: UIColor
    public let tintColor: UIColor
    public let backgroundColor: UIColor
    public let hightlightColor: UIColor
    init(primaryColor: UIColor, secondaryColor: UIColor, tintColor: UIColor, backgroundColor: UIColor, hightlightColor: UIColor) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.hightlightColor = hightlightColor
    }
}

public struct PresentationDownloadButton {
    let initialColor: UIColor
    let rippleColor: UIColor
    let downloadColor: UIColor
    let deviceColor: UIColor
    let buttonBackgroundColor: UIColor
    let backgroundColor: UIColor
}
public final class PresentationThemePopUp {

    public let primaryColor: UIColor
    public let secondaryColor: UIColor
    public let tintColor: UIColor
    public let backgroundColor: UIColor
    public let hightlightColor: UIColor
    init(primaryColor: UIColor, secondaryColor: UIColor, tintColor: UIColor, backgroundColor: UIColor, hightlightColor: UIColor) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.hightlightColor = hightlightColor
    }
}

public final class PresentationThemeLabel {

    public let primaryColor: UIColor
    public let secondaryColor: UIColor
    public let mentionColor: UIColor
    public let linkColor: UIColor
    public let timeMessageColor: UIColor
    init(
        primaryColor: UIColor,
        secondaryColor: UIColor,
        mentionColor: UIColor,
        linkColor: UIColor,
        timeMessageColor: UIColor
    ) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.mentionColor = mentionColor
        self.linkColor = linkColor
        self.timeMessageColor = timeMessageColor
    }
}

public final class PresentationThemeRootNavigationBar {
    public let buttonColor: UIColor
    public let disabledButtonColor: UIColor
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let barTintColor: UIColor
    public let tintColor: UIColor
    public let backgroundColor: UIColor
    public let separatorColor: UIColor
    public let badgeBackgroundColor: UIColor
    public let badgeStrokeColor: UIColor
    public let badgeTextColor: UIColor

    public init(buttonColor: UIColor, disabledButtonColor: UIColor, primaryTextColor: UIColor, secondaryTextColor: UIColor, barTintColor: UIColor, tintColor: UIColor, backgroundColor: UIColor, separatorColor: UIColor, badgeBackgroundColor: UIColor, badgeStrokeColor: UIColor, badgeTextColor: UIColor) {
        self.buttonColor = buttonColor
        self.disabledButtonColor = disabledButtonColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.barTintColor = barTintColor
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeStrokeColor = badgeStrokeColor
        self.badgeTextColor = badgeTextColor
    }
}

public final class PresentationThemeExpandedNotificationNavigationBar {
    public let backgroundColor: UIColor
    public let primaryTextColor: UIColor
    public let controlColor: UIColor
    public let separatorColor: UIColor

    init(backgroundColor: UIColor, primaryTextColor: UIColor, controlColor: UIColor, separatorColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.primaryTextColor = primaryTextColor
        self.controlColor = controlColor
        self.separatorColor = separatorColor
    }
}

public final class PresentationThemeSearchBar {
    let backgroundColor: UIColor
    let accentColor: UIColor
    let inputFillColor: UIColor
    let inputTextColor: UIColor
    let inputPlaceholderTextColor: UIColor
    let inputIconColor: UIColor
    let inputClearButtonColor: UIColor
    let tintColor: UIColor

    public init(backgroundColor: UIColor, accentColor: UIColor, inputFillColor: UIColor, inputTextColor: UIColor, inputPlaceholderTextColor: UIColor, inputIconColor: UIColor, inputClearButtonColor: UIColor, tintColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.inputFillColor = inputFillColor
        self.inputTextColor = inputTextColor
        self.inputPlaceholderTextColor = inputPlaceholderTextColor
        self.inputIconColor = inputIconColor
        self.inputClearButtonColor = inputClearButtonColor
        self.tintColor = tintColor
    }
}

public enum PresentationThemeExpandedNotificationBackgroundType: Int32 {
    case light
    case dark
}

public final class PresentationThemeExpandedNotification {
    public let backgroundType: PresentationThemeExpandedNotificationBackgroundType
    public let navigationBar: PresentationThemeExpandedNotificationNavigationBar

    public init(backgroundType: PresentationThemeExpandedNotificationBackgroundType, navigationBar: PresentationThemeExpandedNotificationNavigationBar) {
        self.backgroundType = backgroundType
        self.navigationBar = navigationBar
    }
}

public enum PresentationThemeActionSheetBackgroundType: Int32 {
    case light
    case dark
}

public final class PresentationThemeActionSheet {
    public let dimColor: UIColor
    public let backgroundType: PresentationThemeActionSheetBackgroundType
    public let opaqueItemBackgroundColor: UIColor
    public let itemBackgroundColor: UIColor
    public let opaqueItemHighlightedBackgroundColor: UIColor
    public let itemHighlightedBackgroundColor: UIColor
    public let opaqueItemSeparatorColor: UIColor
    public let standardActionTextColor: UIColor
    public let destructiveActionTextColor: UIColor
    public let disabledActionTextColor: UIColor
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let controlAccentColor: UIColor
    public let inputBackgroundColor: UIColor
    public let inputPlaceholderColor: UIColor
    public let inputTextColor: UIColor
    public let inputClearButtonColor: UIColor
    public let checkContentColor: UIColor

    init(dimColor: UIColor, backgroundType: PresentationThemeActionSheetBackgroundType, opaqueItemBackgroundColor: UIColor, itemBackgroundColor: UIColor, opaqueItemHighlightedBackgroundColor: UIColor, itemHighlightedBackgroundColor: UIColor, standardActionTextColor: UIColor, opaqueItemSeparatorColor: UIColor, destructiveActionTextColor: UIColor, disabledActionTextColor: UIColor, primaryTextColor: UIColor, secondaryTextColor: UIColor, controlAccentColor: UIColor, inputBackgroundColor: UIColor, inputPlaceholderColor: UIColor, inputTextColor: UIColor, inputClearButtonColor: UIColor, checkContentColor: UIColor) {
        self.dimColor = dimColor
        self.backgroundType = backgroundType
        self.opaqueItemBackgroundColor = opaqueItemBackgroundColor
        self.itemBackgroundColor = itemBackgroundColor
        self.opaqueItemHighlightedBackgroundColor = opaqueItemHighlightedBackgroundColor
        self.itemHighlightedBackgroundColor = itemHighlightedBackgroundColor
        self.opaqueItemSeparatorColor = opaqueItemSeparatorColor
        self.standardActionTextColor = standardActionTextColor
        self.destructiveActionTextColor = destructiveActionTextColor
        self.disabledActionTextColor = disabledActionTextColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.controlAccentColor = controlAccentColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputPlaceholderColor = inputPlaceholderColor
        self.inputTextColor = inputTextColor
        self.inputClearButtonColor = inputClearButtonColor
        self.checkContentColor = checkContentColor
    }
}

public final class PresentationThemeSwitch {
    public let frameColor: UIColor
    public let handleColor: UIColor
    public let contentColor: UIColor
    public let positiveColor: UIColor
    public let negativeColor: UIColor

    public init(frameColor: UIColor, handleColor: UIColor, contentColor: UIColor, positiveColor: UIColor, negativeColor: UIColor) {
        self.frameColor = frameColor
        self.handleColor = handleColor
        self.contentColor = contentColor
        self.positiveColor = positiveColor
        self.negativeColor = negativeColor
    }
}

public final class PresentationThemeItemDisclosureAction {
    public let fillColor: UIColor
    public let foregroundColor: UIColor

    init(fillColor: UIColor, foregroundColor: UIColor) {
        self.fillColor = fillColor
        self.foregroundColor = foregroundColor
    }
}

public final class PresentationThemeCheck {
    public let strokeColor: UIColor
    public let fillColor: UIColor
    public let foregroundColor: UIColor

    init(strokeColor: UIColor, fillColor: UIColor, foregroundColor: UIColor) {
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.foregroundColor = foregroundColor
    }
}

public final class PresentationThemeItemDisclosureActions {
    public let neutral1: PresentationThemeItemDisclosureAction
    public let neutral2: PresentationThemeItemDisclosureAction
    public let destructive: PresentationThemeItemDisclosureAction
    public let constructive: PresentationThemeItemDisclosureAction
    public let accent: PresentationThemeItemDisclosureAction
    public let warning: PresentationThemeItemDisclosureAction
    public let inactive: PresentationThemeItemDisclosureAction

    public init(neutral1: PresentationThemeItemDisclosureAction, neutral2: PresentationThemeItemDisclosureAction, destructive: PresentationThemeItemDisclosureAction, constructive: PresentationThemeItemDisclosureAction, accent: PresentationThemeItemDisclosureAction, warning: PresentationThemeItemDisclosureAction, inactive: PresentationThemeItemDisclosureAction) {
        self.neutral1 = neutral1
        self.neutral2 = neutral2
        self.destructive = destructive
        self.constructive = constructive
        self.accent = accent
        self.warning = warning
        self.inactive = inactive
    }
}

public final class PresentationInputFieldTheme {
    public let backgroundColor: UIColor
    public let placeholderColor: UIColor
    public let primaryColor: UIColor
    public let controlColor: UIColor

    public init(backgroundColor: UIColor, placeholderColor: UIColor, primaryColor: UIColor, controlColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.placeholderColor = placeholderColor
        self.primaryColor = primaryColor
        self.controlColor = controlColor
    }
}

public final class PresentationThemeList {
    public let blocksBackgroundColor: UIColor
    public let plainBackgroundColor: UIColor
    public let itemPrimaryTextColor: UIColor
    public let itemSecondaryTextColor: UIColor
    public let itemDisabledTextColor: UIColor
    public let itemAccentColor: UIColor
    public let itemHighlightedColor: UIColor
    public let itemDestructiveColor: UIColor
    public let itemPlaceholderTextColor: UIColor
    public let itemBlocksBackgroundColor: UIColor
    public let itemHighlightedBackgroundColor: UIColor
    public let itemBlocksSeparatorColor: UIColor
    public let itemPlainSeparatorColor: UIColor
    public let disclosureArrowColor: UIColor
    public let sectionHeaderTextColor: UIColor
    public let freeTextColor: UIColor
    public let freeTextErrorColor: UIColor
    public let freeTextSuccessColor: UIColor
    public let freeMonoIcon: UIColor
    public let itemSwitchColors: PresentationThemeSwitch
    public let itemDisclosureActions: PresentationThemeItemDisclosureActions
    public let itemCheckColors: PresentationThemeCheck
    public let controlSecondaryColor: UIColor
    public let freeInputField: PresentationInputFieldTheme
    public let mediaPlaceholderColor: UIColor
    public let scrollIndicatorColor: UIColor
    public let pageIndicatorInactiveColor: UIColor

    public init(blocksBackgroundColor: UIColor, plainBackgroundColor: UIColor, itemPrimaryTextColor: UIColor, itemSecondaryTextColor: UIColor, itemDisabledTextColor: UIColor, itemAccentColor: UIColor, itemHighlightedColor: UIColor, itemDestructiveColor: UIColor, itemPlaceholderTextColor: UIColor, itemBlocksBackgroundColor: UIColor, itemHighlightedBackgroundColor: UIColor, itemBlocksSeparatorColor: UIColor, itemPlainSeparatorColor: UIColor, disclosureArrowColor: UIColor, sectionHeaderTextColor: UIColor, freeTextColor: UIColor, freeTextErrorColor: UIColor, freeTextSuccessColor: UIColor, freeMonoIcon: UIColor, itemSwitchColors: PresentationThemeSwitch, itemDisclosureActions: PresentationThemeItemDisclosureActions, itemCheckColors: PresentationThemeCheck, controlSecondaryColor: UIColor, freeInputField: PresentationInputFieldTheme, mediaPlaceholderColor: UIColor, scrollIndicatorColor: UIColor, pageIndicatorInactiveColor: UIColor) {
        self.blocksBackgroundColor = blocksBackgroundColor
        self.plainBackgroundColor = plainBackgroundColor
        self.itemPrimaryTextColor = itemPrimaryTextColor
        self.itemSecondaryTextColor = itemSecondaryTextColor
        self.itemDisabledTextColor = itemDisabledTextColor
        self.itemAccentColor = itemAccentColor
        self.itemHighlightedColor = itemHighlightedColor
        self.itemDestructiveColor = itemDestructiveColor
        self.itemPlaceholderTextColor = itemPlaceholderTextColor
        self.itemBlocksBackgroundColor = itemBlocksBackgroundColor
        self.itemHighlightedBackgroundColor = itemHighlightedBackgroundColor
        self.itemBlocksSeparatorColor = itemBlocksSeparatorColor
        self.itemPlainSeparatorColor = itemPlainSeparatorColor
        self.disclosureArrowColor = disclosureArrowColor
        self.sectionHeaderTextColor = sectionHeaderTextColor
        self.freeTextColor = freeTextColor
        self.freeTextErrorColor = freeTextErrorColor
        self.freeTextSuccessColor = freeTextSuccessColor
        self.freeMonoIcon = freeMonoIcon
        self.itemSwitchColors = itemSwitchColors
        self.itemDisclosureActions = itemDisclosureActions
        self.itemCheckColors = itemCheckColors
        self.controlSecondaryColor = controlSecondaryColor
        self.freeInputField = freeInputField
        self.mediaPlaceholderColor = mediaPlaceholderColor
        self.scrollIndicatorColor = scrollIndicatorColor
        self.pageIndicatorInactiveColor = pageIndicatorInactiveColor
    }
}

public final class PresentationThemeArchiveAvatarColors {
    public let backgroundColors: (UIColor, UIColor)
    public let foregroundColor: UIColor

    public init(backgroundColors: (UIColor, UIColor), foregroundColor: UIColor) {
        self.backgroundColors = backgroundColors
        self.foregroundColor = foregroundColor
    }
}

public final class PresentationThemeChatList {
    public let backgroundColor: UIColor
    public let itemSeparatorColor: UIColor
    public let itemBackgroundColor: UIColor
    public let pinnedItemBackgroundColor: UIColor
    public let itemHighlightedBackgroundColor: UIColor
    public let itemSelectedBackgroundColor: UIColor
    public let titleColor: UIColor
    public let secretTitleColor: UIColor
    public let dateTextColor: UIColor
    public let authorNameColor: UIColor
    public let messageTextColor: UIColor
    public let messageDraftTextColor: UIColor
    public let checkmarkColor: UIColor
    public let pendingIndicatorColor: UIColor
    public let muteIconColor: UIColor
    public let unreadBadgeActiveBackgroundColor: UIColor
    public let unreadBadgeActiveTextColor: UIColor
    public let unreadBadgeInactiveBackgroundColor: UIColor
    public let unreadBadgeInactiveTextColor: UIColor
    public let pinnedBadgeColor: UIColor
    public let pinnedSearchBarColor: UIColor
    public let regularSearchBarColor: UIColor
    public let sectionHeaderFillColor: UIColor
    public let sectionHeaderTextColor: UIColor
    public let searchBarKeyboardColor: PresentationThemeKeyboardColor
    public let verifiedIconFillColor: UIColor
    public let verifiedIconForegroundColor: UIColor
    public let secretIconColor: UIColor
    public let pinnedArchiveAvatarColor: PresentationThemeArchiveAvatarColors
    public let unpinnedArchiveAvatarColor: PresentationThemeArchiveAvatarColors
    public let onlineDotColor: UIColor

    init(backgroundColor: UIColor, itemSeparatorColor: UIColor, itemBackgroundColor: UIColor, pinnedItemBackgroundColor: UIColor, itemHighlightedBackgroundColor: UIColor, itemSelectedBackgroundColor: UIColor, titleColor: UIColor, secretTitleColor: UIColor, dateTextColor: UIColor, authorNameColor: UIColor, messageTextColor: UIColor, messageDraftTextColor: UIColor, checkmarkColor: UIColor, pendingIndicatorColor: UIColor, muteIconColor: UIColor, unreadBadgeActiveBackgroundColor: UIColor, unreadBadgeActiveTextColor: UIColor, unreadBadgeInactiveBackgroundColor: UIColor, unreadBadgeInactiveTextColor: UIColor, pinnedBadgeColor: UIColor, pinnedSearchBarColor: UIColor, regularSearchBarColor: UIColor, sectionHeaderFillColor: UIColor, sectionHeaderTextColor: UIColor, searchBarKeyboardColor: PresentationThemeKeyboardColor, verifiedIconFillColor: UIColor, verifiedIconForegroundColor: UIColor, secretIconColor: UIColor, pinnedArchiveAvatarColor: PresentationThemeArchiveAvatarColors, unpinnedArchiveAvatarColor: PresentationThemeArchiveAvatarColors, onlineDotColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.itemSeparatorColor = itemSeparatorColor
        self.itemBackgroundColor = itemBackgroundColor
        self.pinnedItemBackgroundColor = pinnedItemBackgroundColor
        self.itemHighlightedBackgroundColor = itemHighlightedBackgroundColor
        self.itemSelectedBackgroundColor = itemSelectedBackgroundColor
        self.titleColor = titleColor
        self.secretTitleColor = secretTitleColor
        self.dateTextColor = dateTextColor
        self.authorNameColor = authorNameColor
        self.messageTextColor = messageTextColor
        self.messageDraftTextColor = messageDraftTextColor
        self.checkmarkColor = checkmarkColor
        self.pendingIndicatorColor = pendingIndicatorColor
        self.muteIconColor = muteIconColor
        self.unreadBadgeActiveBackgroundColor = unreadBadgeActiveBackgroundColor
        self.unreadBadgeActiveTextColor = unreadBadgeActiveTextColor
        self.unreadBadgeInactiveBackgroundColor = unreadBadgeInactiveBackgroundColor
        self.unreadBadgeInactiveTextColor = unreadBadgeInactiveTextColor
        self.pinnedBadgeColor = pinnedBadgeColor
        self.pinnedSearchBarColor = pinnedSearchBarColor
        self.regularSearchBarColor = regularSearchBarColor
        self.sectionHeaderFillColor = sectionHeaderFillColor
        self.sectionHeaderTextColor = sectionHeaderTextColor
        self.searchBarKeyboardColor = searchBarKeyboardColor
        self.verifiedIconFillColor = verifiedIconFillColor
        self.verifiedIconForegroundColor = verifiedIconForegroundColor
        self.secretIconColor = secretIconColor
        self.pinnedArchiveAvatarColor = pinnedArchiveAvatarColor
        self.unpinnedArchiveAvatarColor = unpinnedArchiveAvatarColor
        self.onlineDotColor = onlineDotColor
    }
}

public final class PresentationThemeBubbleColorComponents {
    let bubleColor: UIColor
    let tintColor: UIColor
    let textColor: UIColor
    let timeMessageColor: UIColor

    init(bubleColor: UIColor, textColor: UIColor, tintColor: UIColor, timeMessageColor: UIColor) {
        self.bubleColor = bubleColor
        self.textColor = textColor
        self.tintColor = tintColor
        self.timeMessageColor = timeMessageColor
    }
}

public final class PresentationThemeBubbleColor {
    public let withWallpaper: PresentationThemeBubbleColorComponents
    public let withoutWallpaper: PresentationThemeBubbleColorComponents
    public let label: PresentationThemeLabel
    public init(withWallpaper: PresentationThemeBubbleColorComponents, withoutWallpaper: PresentationThemeBubbleColorComponents, label: PresentationThemeLabel) {
        self.withWallpaper = withWallpaper
        self.withoutWallpaper = withoutWallpaper
        self.label = label
    }
}

public final class PresentationThemeVariableColor {
    public let withWallpaper: UIColor
    public let withoutWallpaper: UIColor

    public init(withWallpaper: UIColor, withoutWallpaper: UIColor) {
        self.withWallpaper = withWallpaper
        self.withoutWallpaper = withoutWallpaper
    }

    public init(color: UIColor) {
        self.withWallpaper = color
        self.withoutWallpaper = color
    }
}

public func bubbleColorComponents(theme: PresentationTheme, incoming: Bool, wallpaper: Bool) -> PresentationThemeBubbleColorComponents {
    if incoming {
        if wallpaper {
            return theme.chat.bubble.incoming.withWallpaper
        } else {
            return theme.chat.bubble.incoming.withoutWallpaper
        }
    } else {
        if wallpaper {
            return theme.chat.bubble.outgoing.withWallpaper
        } else {
            return theme.chat.bubble.outgoing.withoutWallpaper
        }
    }
}

public func bubbleVariableColor(variableColor: PresentationThemeVariableColor) -> UIColor {
    return variableColor.withWallpaper
}

public final class PresentationThemeChatBubblePolls {
    let radioButton: UIColor
    let radioProgress: UIColor
    let highlight: UIColor
    let separator: UIColor
    let bar: UIColor

    public init(radioButton: UIColor, radioProgress: UIColor, highlight: UIColor, separator: UIColor, bar: UIColor) {
        self.radioButton = radioButton
        self.radioProgress = radioProgress
        self.highlight = highlight
        self.separator = separator
        self.bar = bar
    }
}

public final class PresentationThemeChatBubble {
    public let incoming: PresentationThemeBubbleColor
    public let outgoing: PresentationThemeBubbleColor

    public let freeform: PresentationThemeBubbleColor

    public let replyBackGroundColor: UIColor
    public let incomingPrimaryTextColor: UIColor
    public let incomingSecondaryTextColor: UIColor
    public let incomingLinkTextColor: UIColor
    public let incomingLinkHighlightColor: UIColor
    public let outgoingPrimaryTextColor: UIColor
    public let outgoingSecondaryTextColor: UIColor
    public let outgoingLinkTextColor: UIColor
    public let outgoingLinkHighlightColor: UIColor
    public let infoPrimaryTextColor: UIColor
    public let infoLinkTextColor: UIColor
    public let incomingTextHighlightColor: UIColor
    public let outgoingTextHighlightColor: UIColor

    public let incomingAccentTextColor: UIColor
    public let outgoingAccentTextColor: UIColor

    public let incomingAccentControlColor: UIColor
    public let outgoingAccentControlColor: UIColor
    public let incomingMediaActiveControlColor: UIColor
    public let outgoingMediaActiveControlColor: UIColor
    public let incomingMediaInactiveControlColor: UIColor
    public let outgoingMediaInactiveControlColor: UIColor

    public let outgoingCheckColor: UIColor
    public let incomingPendingActivityColor: UIColor
    public let outgoingPendingActivityColor: UIColor

    public let mediaDateAndStatusFillColor: UIColor
    public let mediaDateAndStatusTextColor: UIColor

    public let incomingFileTitleColor: UIColor
    public let outgoingFileTitleColor: UIColor
    public let incomingFileDescriptionColor: UIColor
    public let outgoingFileDescriptionColor: UIColor
    public let incomingFileDurationColor: UIColor
    public let outgoingFileDurationColor: UIColor

    public let shareButtonFillColor: PresentationThemeVariableColor
    public let shareButtonStrokeColor: PresentationThemeVariableColor
    public let shareButtonForegroundColor: PresentationThemeVariableColor

    public let mediaOverlayControlBackgroundColor: UIColor
    public let mediaOverlayControlForegroundColor: UIColor

    public let actionButtonsIncomingFillColor: PresentationThemeVariableColor
    public let actionButtonsIncomingStrokeColor: PresentationThemeVariableColor
    public let actionButtonsIncomingTextColor: PresentationThemeVariableColor

    public let actionButtonsOutgoingFillColor: PresentationThemeVariableColor
    public let actionButtonsOutgoingStrokeColor: PresentationThemeVariableColor
    public let actionButtonsOutgoingTextColor: PresentationThemeVariableColor

    public let selectionControlBorderColor: UIColor
    public let selectionControlFillColor: UIColor
    public let selectionControlForegroundColor: UIColor

    public let mediaHighlightOverlayColor: UIColor

    public let deliveryFailedFillColor: UIColor
    public let deliveryFailedForegroundColor: UIColor

    public let incomingMediaPlaceholderColor: UIColor
    public let outgoingMediaPlaceholderColor: UIColor

    public let incomingPolls: PresentationThemeChatBubblePolls
    public let outgoingPolls: PresentationThemeChatBubblePolls

    public init(incoming: PresentationThemeBubbleColor, outgoing: PresentationThemeBubbleColor, freeform: PresentationThemeBubbleColor, incomingPrimaryTextColor: UIColor, incomingSecondaryTextColor: UIColor, incomingLinkTextColor: UIColor, incomingLinkHighlightColor: UIColor, outgoingPrimaryTextColor: UIColor, outgoingSecondaryTextColor: UIColor, outgoingLinkTextColor: UIColor, outgoingLinkHighlightColor: UIColor, infoPrimaryTextColor: UIColor, infoLinkTextColor: UIColor, incomingTextHighlightColor: UIColor, outgoingTextHighlightColor: UIColor, incomingAccentTextColor: UIColor, outgoingAccentTextColor: UIColor, incomingAccentControlColor: UIColor, outgoingAccentControlColor: UIColor, incomingMediaActiveControlColor: UIColor, outgoingMediaActiveControlColor: UIColor, incomingMediaInactiveControlColor: UIColor, outgoingMediaInactiveControlColor: UIColor, outgoingCheckColor: UIColor, incomingPendingActivityColor: UIColor, outgoingPendingActivityColor: UIColor, mediaDateAndStatusFillColor: UIColor, mediaDateAndStatusTextColor: UIColor, incomingFileTitleColor: UIColor, outgoingFileTitleColor: UIColor, incomingFileDescriptionColor: UIColor, outgoingFileDescriptionColor: UIColor, incomingFileDurationColor: UIColor, outgoingFileDurationColor: UIColor, shareButtonFillColor: PresentationThemeVariableColor, shareButtonStrokeColor: PresentationThemeVariableColor, shareButtonForegroundColor: PresentationThemeVariableColor, mediaOverlayControlBackgroundColor: UIColor, mediaOverlayControlForegroundColor: UIColor, actionButtonsIncomingFillColor: PresentationThemeVariableColor, actionButtonsIncomingStrokeColor: PresentationThemeVariableColor, actionButtonsIncomingTextColor: PresentationThemeVariableColor, actionButtonsOutgoingFillColor: PresentationThemeVariableColor, actionButtonsOutgoingStrokeColor: PresentationThemeVariableColor, actionButtonsOutgoingTextColor: PresentationThemeVariableColor, selectionControlBorderColor: UIColor, selectionControlFillColor: UIColor, selectionControlForegroundColor: UIColor, mediaHighlightOverlayColor: UIColor, deliveryFailedFillColor: UIColor, deliveryFailedForegroundColor: UIColor, incomingMediaPlaceholderColor: UIColor, outgoingMediaPlaceholderColor: UIColor, incomingPolls: PresentationThemeChatBubblePolls, outgoingPolls: PresentationThemeChatBubblePolls, replyBackGroundColor: UIColor) {
        self.incoming = incoming
        self.outgoing = outgoing
        self.freeform = freeform

        self.replyBackGroundColor = replyBackGroundColor
        self.incomingPrimaryTextColor = incomingPrimaryTextColor
        self.incomingSecondaryTextColor = incomingSecondaryTextColor
        self.incomingLinkTextColor = incomingLinkTextColor
        self.incomingLinkHighlightColor = incomingLinkHighlightColor
        self.outgoingPrimaryTextColor = outgoingPrimaryTextColor
        self.outgoingSecondaryTextColor = outgoingSecondaryTextColor
        self.outgoingLinkTextColor = outgoingLinkTextColor
        self.outgoingLinkHighlightColor = outgoingLinkHighlightColor
        self.infoPrimaryTextColor = infoPrimaryTextColor
        self.infoLinkTextColor = infoLinkTextColor
        self.incomingTextHighlightColor = incomingTextHighlightColor
        self.outgoingTextHighlightColor = outgoingTextHighlightColor

        self.incomingAccentTextColor = incomingAccentTextColor
        self.outgoingAccentTextColor = outgoingAccentTextColor
        self.incomingAccentControlColor = incomingAccentControlColor
        self.outgoingAccentControlColor = outgoingAccentControlColor

        self.incomingMediaActiveControlColor = incomingMediaActiveControlColor
        self.outgoingMediaActiveControlColor = outgoingMediaActiveControlColor
        self.incomingMediaInactiveControlColor = incomingMediaInactiveControlColor
        self.outgoingMediaInactiveControlColor = outgoingMediaInactiveControlColor

        self.outgoingCheckColor = outgoingCheckColor
        self.incomingPendingActivityColor = incomingPendingActivityColor
        self.outgoingPendingActivityColor = outgoingPendingActivityColor
        self.mediaDateAndStatusFillColor = mediaDateAndStatusFillColor
        self.mediaDateAndStatusTextColor = mediaDateAndStatusTextColor

        self.incomingFileTitleColor = incomingFileTitleColor
        self.outgoingFileTitleColor = outgoingFileTitleColor
        self.incomingFileDescriptionColor = incomingFileDescriptionColor
        self.outgoingFileDescriptionColor = outgoingFileDescriptionColor
        self.incomingFileDurationColor = incomingFileDurationColor
        self.outgoingFileDurationColor = outgoingFileDurationColor

        self.shareButtonFillColor = shareButtonFillColor
        self.shareButtonStrokeColor = shareButtonStrokeColor
        self.shareButtonForegroundColor = shareButtonForegroundColor

        self.mediaOverlayControlBackgroundColor = mediaOverlayControlBackgroundColor
        self.mediaOverlayControlForegroundColor = mediaOverlayControlForegroundColor

        self.actionButtonsIncomingFillColor = actionButtonsIncomingFillColor
        self.actionButtonsIncomingStrokeColor = actionButtonsIncomingStrokeColor
        self.actionButtonsIncomingTextColor = actionButtonsIncomingTextColor

        self.actionButtonsOutgoingFillColor = actionButtonsOutgoingFillColor
        self.actionButtonsOutgoingStrokeColor = actionButtonsOutgoingStrokeColor
        self.actionButtonsOutgoingTextColor = actionButtonsOutgoingTextColor

        self.selectionControlBorderColor = selectionControlBorderColor
        self.selectionControlFillColor = selectionControlFillColor
        self.selectionControlForegroundColor = selectionControlForegroundColor

        self.mediaHighlightOverlayColor = mediaHighlightOverlayColor

        self.deliveryFailedFillColor = deliveryFailedFillColor
        self.deliveryFailedForegroundColor = deliveryFailedForegroundColor

        self.incomingMediaPlaceholderColor = incomingMediaPlaceholderColor
        self.outgoingMediaPlaceholderColor = outgoingMediaPlaceholderColor

        self.incomingPolls = incomingPolls
        self.outgoingPolls = outgoingPolls
    }
}

public final class PresentationThemeServiceMessageColorComponents {
    public let fill: UIColor
    public let primaryText: UIColor
    public let linkHighlight: UIColor

    public let dateFillStatic: UIColor
    public let dateFillFloating: UIColor

    public init(fill: UIColor, primaryText: UIColor, linkHighlight: UIColor, dateFillStatic: UIColor, dateFillFloating: UIColor) {
        self.fill = fill
        self.primaryText = primaryText
        self.linkHighlight = linkHighlight
        self.dateFillStatic = dateFillStatic
        self.dateFillFloating = dateFillFloating
    }
}

public final class PresentationThemeServiceMessageColor {
    public let withDefaultWallpaper: PresentationThemeServiceMessageColorComponents
    public let withCustomWallpaper: PresentationThemeServiceMessageColorComponents

    public init(withDefaultWallpaper: PresentationThemeServiceMessageColorComponents, withCustomWallpaper: PresentationThemeServiceMessageColorComponents) {
        self.withDefaultWallpaper = withDefaultWallpaper
        self.withCustomWallpaper = withCustomWallpaper
    }
}

public final class PresentationThemeServiceMessage {
    public let components: PresentationThemeServiceMessageColor

    public let unreadBarFillColor: UIColor
    public let unreadBarStrokeColor: UIColor
    public let unreadBarTextColor: UIColor

    public let dateTextColor: PresentationThemeVariableColor

    public init(components: PresentationThemeServiceMessageColor, unreadBarFillColor: UIColor, unreadBarStrokeColor: UIColor, unreadBarTextColor: UIColor, dateTextColor: PresentationThemeVariableColor) {
        self.components = components
        self.unreadBarFillColor = unreadBarFillColor
        self.unreadBarStrokeColor = unreadBarStrokeColor
        self.unreadBarTextColor = unreadBarTextColor
        self.dateTextColor = dateTextColor
    }
}

public enum PresentationThemeKeyboardColor: Int32 {
    case light = 0
    case dark = 1

    public var keyboardAppearance: UIKeyboardAppearance {
        switch self {
        case .light:
            return .default
        case .dark:
            return .dark
        }
    }
}

public final class PresentationThemeChatInputPanelMediaRecordingControl {
    public let buttonColor: UIColor
    public let micLevelColor: UIColor
    public let activeIconColor: UIColor
    public let panelControlFillColor: UIColor
    public let panelControlStrokeColor: UIColor
    public let panelControlContentPrimaryColor: UIColor
    public let panelControlContentAccentColor: UIColor

    init(buttonColor: UIColor, micLevelColor: UIColor, activeIconColor: UIColor, panelControlFillColor: UIColor, panelControlStrokeColor: UIColor, panelControlContentPrimaryColor: UIColor, panelControlContentAccentColor: UIColor) {
        self.buttonColor = buttonColor
        self.micLevelColor = micLevelColor
        self.activeIconColor = activeIconColor
        self.panelControlFillColor = panelControlFillColor
        self.panelControlStrokeColor = panelControlStrokeColor
        self.panelControlContentPrimaryColor = panelControlContentPrimaryColor
        self.panelControlContentAccentColor = panelControlContentAccentColor
    }
}

public final class PresentationThemeChatInputPanel {
    public let panelBackgroundColor: UIColor
    public let panelStrokeColor: UIColor
    public let panelControlAccentColor: UIColor
    public let panelControlColor: UIColor
    public let panelControlDisabledColor: UIColor
    public let panelControlDestructiveColor: UIColor
    public let inputBackgroundColor: UIColor
    public let inputStrokeColor: UIColor
    public let inputPlaceholderColor: UIColor
    public let inputTextColor: UIColor
    public let inputControlColor: UIColor
    public let actionControlFillColor: UIColor
    public let actionControlForegroundColor: UIColor
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let mediaRecordingDotColor: UIColor
    public let keyboardColor: PresentationThemeKeyboardColor
    public let mediaRecordingControl: PresentationThemeChatInputPanelMediaRecordingControl

    public init(panelBackgroundColor: UIColor, panelStrokeColor: UIColor, panelControlAccentColor: UIColor, panelControlColor: UIColor, panelControlDisabledColor: UIColor, panelControlDestructiveColor: UIColor, inputBackgroundColor: UIColor, inputStrokeColor: UIColor, inputPlaceholderColor: UIColor, inputTextColor: UIColor, inputControlColor: UIColor, actionControlFillColor: UIColor, actionControlForegroundColor: UIColor, primaryTextColor: UIColor, secondaryTextColor: UIColor, mediaRecordingDotColor: UIColor, keyboardColor: PresentationThemeKeyboardColor, mediaRecordingControl: PresentationThemeChatInputPanelMediaRecordingControl) {
        self.panelBackgroundColor = panelBackgroundColor
        self.panelStrokeColor = panelStrokeColor
        self.panelControlAccentColor = panelControlAccentColor
        self.panelControlColor = panelControlColor
        self.panelControlDisabledColor = panelControlDisabledColor
        self.panelControlDestructiveColor = panelControlDestructiveColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputStrokeColor = inputStrokeColor
        self.inputPlaceholderColor = inputPlaceholderColor
        self.inputTextColor = inputTextColor
        self.inputControlColor = inputControlColor
        self.actionControlFillColor = actionControlFillColor
        self.actionControlForegroundColor = actionControlForegroundColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.mediaRecordingDotColor = mediaRecordingDotColor
        self.keyboardColor = keyboardColor
        self.mediaRecordingControl = mediaRecordingControl
    }
}

public final class PresentationThemeInputMediaPanel {
    public let panelSeparatorColor: UIColor
    public let panelIconColor: UIColor
    public let panelHighlightedIconBackgroundColor: UIColor
    public let stickersBackgroundColor: UIColor
    public let stickersSectionTextColor: UIColor
    public let stickersSearchBackgroundColor: UIColor
    public let stickersSearchPlaceholderColor: UIColor
    public let stickersSearchPrimaryColor: UIColor
    public let stickersSearchControlColor: UIColor
    public let gifsBackgroundColor: UIColor

    public init(panelSeparatorColor: UIColor, panelIconColor: UIColor, panelHighlightedIconBackgroundColor: UIColor, stickersBackgroundColor: UIColor, stickersSectionTextColor: UIColor, stickersSearchBackgroundColor: UIColor, stickersSearchPlaceholderColor: UIColor, stickersSearchPrimaryColor: UIColor, stickersSearchControlColor: UIColor, gifsBackgroundColor: UIColor) {
        self.panelSeparatorColor = panelSeparatorColor
        self.panelIconColor = panelIconColor
        self.panelHighlightedIconBackgroundColor = panelHighlightedIconBackgroundColor
        self.stickersBackgroundColor = stickersBackgroundColor
        self.stickersSectionTextColor = stickersSectionTextColor
        self.stickersSearchBackgroundColor = stickersSearchBackgroundColor
        self.stickersSearchPlaceholderColor = stickersSearchPlaceholderColor
        self.stickersSearchPrimaryColor = stickersSearchPrimaryColor
        self.stickersSearchControlColor = stickersSearchControlColor
        self.gifsBackgroundColor = gifsBackgroundColor
    }
}

public final class PresentationThemeInputButtonPanel {
    public let panelSeparatorColor: UIColor
    public let panelBackgroundColor: UIColor
    public let buttonFillColor: UIColor
    public let buttonStrokeColor: UIColor
    public let buttonHighlightedFillColor: UIColor
    public let buttonHighlightedStrokeColor: UIColor
    public let buttonTextColor: UIColor

    public init(panelSeparatorColor: UIColor, panelBackgroundColor: UIColor, buttonFillColor: UIColor, buttonStrokeColor: UIColor, buttonHighlightedFillColor: UIColor, buttonHighlightedStrokeColor: UIColor, buttonTextColor: UIColor) {
        self.panelSeparatorColor = panelSeparatorColor
        self.panelBackgroundColor = panelBackgroundColor
        self.buttonFillColor = buttonFillColor
        self.buttonStrokeColor = buttonStrokeColor
        self.buttonHighlightedFillColor = buttonHighlightedFillColor
        self.buttonHighlightedStrokeColor = buttonHighlightedStrokeColor
        self.buttonTextColor = buttonTextColor
    }
}

public final class PresentationThemeChatHistoryNavigation {
    public let fillColor: UIColor
    public let strokeColor: UIColor
    public let foregroundColor: UIColor
    public let badgeBackgroundColor: UIColor
    public let badgeStrokeColor: UIColor
    public let badgeTextColor: UIColor

    public init(fillColor: UIColor, strokeColor: UIColor, foregroundColor: UIColor, badgeBackgroundColor: UIColor, badgeStrokeColor: UIColor, badgeTextColor: UIColor) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.foregroundColor = foregroundColor
        self.badgeBackgroundColor = badgeBackgroundColor
        self.badgeStrokeColor = badgeStrokeColor
        self.badgeTextColor = badgeTextColor
    }
}

public final class PresentationThemeChat {
    public let bubble: PresentationThemeChatBubble
    public let serviceMessage: PresentationThemeServiceMessage
    public let inputPanel: PresentationThemeChatInputPanel
    public let inputMediaPanel: PresentationThemeInputMediaPanel
    public let inputButtonPanel: PresentationThemeInputButtonPanel
    public let historyNavigation: PresentationThemeChatHistoryNavigation

    public init(bubble: PresentationThemeChatBubble, serviceMessage: PresentationThemeServiceMessage, inputPanel: PresentationThemeChatInputPanel, inputMediaPanel: PresentationThemeInputMediaPanel, inputButtonPanel: PresentationThemeInputButtonPanel, historyNavigation: PresentationThemeChatHistoryNavigation) {
        self.bubble = bubble
        self.serviceMessage = serviceMessage
        self.inputPanel = inputPanel
        self.inputMediaPanel = inputMediaPanel
        self.inputButtonPanel = inputButtonPanel
        self.historyNavigation = historyNavigation
    }
}

public final class PresentationThemeInAppNotification {
    public let fillColor: UIColor
    public let primaryTextColor: UIColor

    public let expandedNotification: PresentationThemeExpandedNotification

    public init(fillColor: UIColor, primaryTextColor: UIColor, expandedNotification: PresentationThemeExpandedNotification) {
        self.fillColor = fillColor
        self.primaryTextColor = primaryTextColor
        self.expandedNotification = expandedNotification
    }
}

public enum PresentationThemeBuiltinName {
    case dayClassic
    case day
    case nightGrayscale
    case nightAccent
}

public enum PresentationThemeName: Equatable {
    case builtin(PresentationThemeBuiltinName)
    case custom(String)

    public static func == (lhs: PresentationThemeName, rhs: PresentationThemeName) -> Bool {
        switch lhs {
        case let .builtin(name):
            if case .builtin(name) = rhs {
                return true
            } else {
                return false
            }
        case let .custom(name):
            if case .custom(name) = rhs {
                return true
            } else {
                return false
            }
        }
    }
}

public final class PresentationTheme: Equatable {
    public let name: PresentationThemeName
    public let statusBarStyle: UIStatusBarStyle
    public let allowsCustomWallpapers: Bool
    public let list: PresentationThemeList
    public let chatList: PresentationThemeChatList
    public let chat: PresentationThemeChat
    public let actionSheet: PresentationThemeActionSheet
    //    public let inAppNotification: PresentationThemeInAppNotification
    public let viewController: PresentationThemeViewController
    public let navigationBar: PresentationThemeRootNavigationBar
    public let tableView: PresentationThemeTableView
    public let button: PresentationThemeButton
    public let label: PresentationThemeLabel
    public let popUpView: PresentationThemePopUp
    public let searchBar: PresentationThemeSearchBar
    public let stickerView: PresentationThemeStickerView
    public let downloadButton: PresentationDownloadButton
    public init(
        name: PresentationThemeName,
        statusBarStyle: UIStatusBarStyle,
        allowsCustomWallpapers: Bool,
        list: PresentationThemeList,
        chatList: PresentationThemeChatList,
        chat: PresentationThemeChat,
        actionSheet: PresentationThemeActionSheet,
        viewController: PresentationThemeViewController,
        navigationBar: PresentationThemeRootNavigationBar,
        tableView: PresentationThemeTableView,
        button: PresentationThemeButton,
        label: PresentationThemeLabel,
        popUpView: PresentationThemePopUp,
        searchBar: PresentationThemeSearchBar,
        stickerView: PresentationThemeStickerView, downloadButton: PresentationDownloadButton) {
        self.name = name
        self.statusBarStyle = statusBarStyle
        self.allowsCustomWallpapers = allowsCustomWallpapers
        self.list = list
        self.chatList = chatList
        self.chat = chat
        self.actionSheet = actionSheet
        self.viewController = viewController
        self.navigationBar = navigationBar
        self.tableView = tableView
        self.label = label
        self.button = button
        self.popUpView = popUpView
        self.searchBar = searchBar
        self.stickerView = stickerView
        self.downloadButton = downloadButton
    }

    public static func == (lhs: PresentationTheme, rhs: PresentationTheme) -> Bool {
        return lhs === rhs
    }
}
