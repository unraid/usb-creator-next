/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../qmlcomponents"
import "components"

import RpiImager

WizardStepBase {
    id: root
    
    title: qsTr("Customisation: %1").arg(BrandSteps.serverNameLabel) // UNRAID

    // UNRAID: written to config/ident.cfg as NAME= and used as the server's
    // network name; it is not a Raspberry Pi hostname.
    readonly property string serverNameHelp: qsTr("The name this Unraid server appears as on your network. It should contain only letters, numbers, and hyphens.")
    showSkipButton: true
    nextButtonAccessibleDescription: qsTr("Save server name and continue to next customisation step") // UNRAID
    backButtonAccessibleDescription: qsTr("Return to previous step")
    skipButtonAccessibleDescription: qsTr("Skip all customisation and proceed directly to writing the image")
    
    Component.onCompleted: {
        root.registerFocusGroup("hostname_fields", function(){ 
            // Only include help text when screen reader is active (otherwise it's not focusable)
            var items = []
            if (ImageWriterSingleton && ImageWriterSingleton.screenReaderActive) {
                items.push(helpText)
            }
            items.push(fieldHostname)
            return items
        }, 0)
        
        // Initial focus will automatically go to title, then help text, then field (handled by WizardStepBase)
        
        // Prefill from conserved customization settings
        if (wizardContainer.customizationSettings.hostname) {
            fieldHostname.text = wizardContainer.customizationSettings.hostname
            wizardContainer.hostnameConfigured = true
        }
    }

    // Content
    content: [
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Style.sectionPadding
        spacing: Style.stepContentSpacing
        
        WizardSectionContainer {
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingMedium
                
                ImTextField {
                    id: fieldHostname
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter your server name") // UNRAID
                    font.pointSize: Style.fontSizeInput
                    Accessible.description: root.serverNameHelp // UNRAID
                    
                    validator: RegularExpressionValidator {
                        regularExpression: /^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$/
                    }
                }
            }
            
            WizardDescriptionText {
                id: helpText
                text: root.serverNameHelp // UNRAID
            }
        }
    }
    ]
    
    // Save settings when moving to next step
    onNextClicked: {
        var hostnameText = fieldHostname.text ? fieldHostname.text.trim() : ""
        
        // Update conserved customization settings (runtime state)
        if (hostnameText.length > 0) {
            wizardContainer.customizationSettings.hostname = hostnameText
            wizardContainer.hostnameConfigured = true
            // Persist for future sessions
            ImageWriterSingleton.setPersistedCustomisationSetting("hostname", hostnameText)
        } else {
            // Empty -> remove from both runtime and persistent settings
            delete wizardContainer.customizationSettings.hostname
            wizardContainer.hostnameConfigured = false
            ImageWriterSingleton.removePersistedCustomisationSetting("hostname")
        }
    }
    
    // Handle skip button
    onSkipClicked: {
        // Clear all customization flags
        wizardContainer.hostnameConfigured = false
        wizardContainer.localeConfigured = false
        wizardContainer.userConfigured = false
        wizardContainer.wifiConfigured = false
        wizardContainer.sshEnabled = false
        
        // Jump to writing step
        wizardContainer.jumpToStep(wizardContainer.stepWriting)
    }
} 
