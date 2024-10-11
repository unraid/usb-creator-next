<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="fr_FR">
    <context>
        <name>DownloadExtractThread</name>
        <message>
            <location filename="usb-creator-next/src/downloadextractthread.cpp" line="196"/>
            <location filename="usb-creator-next/src/downloadextractthread.cpp" line="464"/>
            <source>Error extracting archive: %1</source>
            <translation>Erreur lors de l'extraction de l'archive : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadextractthread.cpp" line="261"/>
            <source>Error mounting FAT32 partition</source>
            <translation>Erreur lors du montage de la partition FAT32</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadextractthread.cpp" line="281"/>
            <source>Operating system did not mount FAT32 partition</source>
            <translation>Le système d'exploitation n'a pas monté la partition FAT32</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadextractthread.cpp" line="304"/>
            <source>Error changing to directory &apos;%1&apos;</source>
            <translation>Erreur lors du changement de répertoire vers &apos;%1&apos;</translation>
        </message>
    </context>
    <context>
        <name>DownloadThread</name>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="118"/>
            <source>unmounting drive</source>
            <translation>déconnexion du disque</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="138"/>
            <source>opening drive</source>
            <translation>ouverture du disque</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="166"/>
            <source>Error running diskpart: %1</source>
            <translation>Erreur lors de l'exécution de diskpart : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="187"/>
            <source>Error removing existing partitions</source>
            <translation>Erreur lors de la suppression des partitions existantes</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="213"/>
            <source>Authentication cancelled</source>
            <translation>Authentification annulée</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="216"/>
            <source>Error running authopen to gain access to disk device &apos;%1&apos;</source>
            <translation>Erreur lors de l'exécution d'authopen pour accéder au périphérique disque &apos;%1&apos;</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="217"/>
            <source>Please verify if &apos;Unraid USB Creator&apos; is allowed access to &apos;removable volumes&apos; in privacy settings (under &apos;files and folders&apos; or alternatively give it &apos;full disk access&apos;).</source>
            <translation>Veuillez vérifier si &apos;Unraid USB Creator&apos; a accès aux &apos;volumes amovibles&apos; dans les paramètres de confidentialité (sous &apos;fichiers et dossiers&apos; ou donner un &apos;accès complet au disque&apos;).</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="239"/>
            <source>Cannot open storage device &apos;%1&apos;.</source>
            <translation>Impossible d'ouvrir le périphérique de stockage &apos;%1&apos;.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="281"/>
            <source>discarding existing data on drive</source>
            <translation>suppression des données existantes sur le disque</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="301"/>
            <source>zeroing out first and last MB of drive</source>
            <translation>remise à zéro du premier et du dernier Mo du disque</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="307"/>
            <source>Write error while zero&apos;ing out MBR</source>
            <translation>Erreur d'écriture lors de la remise à zéro du MBR</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="319"/>
            <source>Write error while trying to zero out last part of card.&lt;br&gt;Card could be advertising wrong capacity (possible counterfeit).</source>
            <translation>Erreur d'écriture lors de la remise à zéro de la dernière partie de la carte.&lt;br&gt;La carte pourrait indiquer une capacité incorrecte (possiblement contrefaite).</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="408"/>
            <source>starting download</source>
            <translation>début du téléchargement</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="468"/>
            <source>Error downloading: %1</source>
            <translation>Erreur lors du téléchargement : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="665"/>
            <source>Access denied error while writing file to disk.</source>
            <translation>Erreur d'accès refusé lors de l'écriture du fichier sur le disque.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="670"/>
            <source>Controlled Folder Access seems to be enabled. Please add both unraid-usb-creator.exe and fat32format.exe to the list of allowed apps and try again.</source>
            <translation>L'accès contrôlé aux dossiers semble être activé. Veuillez ajouter unraid-usb-creator.exe et fat32format.exe à la liste des applications autorisées et réessayer.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="677"/>
            <source>Error writing file to disk</source>
            <translation>Erreur lors de l'écriture du fichier sur le disque</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="699"/>
            <source>Download corrupt. Hash does not match</source>
            <translation>Téléchargement corrompu. Le hash ne correspond pas</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="711"/>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="763"/>
            <source>Error writing to storage (while flushing)</source>
            <translation>Erreur lors de l'écriture sur le support (lors du vidage)</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="718"/>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="770"/>
            <source>Error writing to storage (while fsync)</source>
            <translation>Erreur lors de l'écriture sur le support (lors de la synchronisation fsync)</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="753"/>
            <source>Error writing first block (partition table)</source>
            <translation>Erreur lors de l'écriture du premier bloc (table de partition)</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="828"/>
            <source>Error reading from storage.&lt;br&gt;SD card may be broken.</source>
            <translation>Erreur de lecture sur le support.&lt;br&gt;La carte SD peut être endommagée.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="847"/>
            <source>Verifying write failed. Contents of SD card is different from what was written to it.</source>
            <translation>Échec de la vérification de l'écriture. Le contenu de la carte SD est différent de ce qui a été écrit.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/downloadthread.cpp" line="901"/>
            <source>Customizing image</source>
            <translation>Personnalisation de l'image</translation>
        </message>
    </context>
    <context>
        <name>DriveFormatThread</name>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="63"/>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="129"/>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="195"/>
            <source>Error partitioning: %1</source>
            <translation>Erreur de partitionnement : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="88"/>
            <source>Error starting fat32format</source>
            <translation>Erreur lors du démarrage de fat32format</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="98"/>
            <source>Error running fat32format: %1</source>
            <translation>Erreur lors de l'exécution de fat32format : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="108"/>
            <source>Error determining new drive letter</source>
            <translation>Erreur lors de la détermination de la nouvelle lettre de lecteur</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="113"/>
            <source>Invalid device: %1</source>
            <translation>Périphérique invalide : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="152"/>
            <source>Error formatting (through udisks2)</source>
            <translation>Erreur lors du formatage (via udisks2)</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="159"/>
            <source>Elevated privileges needed to properly format drive.</source>
            <translation>Des privilèges élevés sont nécessaires pour formater correctement le disque.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="184"/>
            <source>Error starting sfdisk</source>
            <translation>Erreur lors du démarrage de sfdisk</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="209"/>
            <source>Partitioning did not create expected FAT partition %1</source>
            <translation>Le partitionnement n'a pas créé la partition FAT attendue %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="222"/>
            <source>Error starting mkfs.fat</source>
            <translation>Erreur lors du démarrage de mkfs.fat</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="232"/>
            <source>Error running mkfs.fat: %1</source>
            <translation>Erreur lors de l'exécution de mkfs.fat : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/driveformatthread.cpp" line="239"/>
            <source>Formatting not implemented for this platform</source>
            <translation>Le formatage n'est pas implémenté pour cette plateforme</translation>
        </message>
    </context>

    <context>
        <name>ImageWriter</name>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="269"/>
            <source>Storage capacity is not large enough.&lt;br&gt;Needs to be at least %1 GB.</source>
            <translation>La capacité de stockage n'est pas suffisante.&lt;br&gt;Elle doit être d'au moins %1 Go.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="275"/>
            <source>Input file is not a valid disk image.&lt;br&gt;File size %1 bytes is not a multiple of 512 bytes.</source>
            <translation>Le fichier d'entrée n'est pas une image disque valide.&lt;br&gt;La taille du fichier %1 octets n'est pas un multiple de 512 octets.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="675"/>
            <source>Downloading and writing image</source>
            <translation>Téléchargement et écriture de l'image</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="808"/>
            <source>Select image</source>
            <translation>Sélectionner l'image</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="983"/>
            <source>Error synchronizing time. Trying again in 3 seconds</source>
            <translation>Erreur de synchronisation de l'heure. Nouvelle tentative dans 3 secondes</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="995"/>
            <source>STP is enabled on your Ethernet switch. Getting IP will take long time.</source>
            <translation>STP est activé sur votre switch Ethernet. L'obtention de l'IP prendra du temps.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="1206"/>
            <source>Would you like to prefill the wifi password from the system keychain?</source>
            <translation>Souhaitez-vous pré-remplir le mot de passe wifi à partir du trousseau de clés du système ?</translation>
        </message>
    </context>

    <context>
        <name>LocalFileExtractThread</name>
        <message>
            <location filename="usb-creator-next/src/localfileextractthread.cpp" line="34"/>
            <source>opening image file</source>
            <translation>ouverture du fichier image</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/localfileextractthread.cpp" line="39"/>
            <source>Error opening image file</source>
            <translation>Erreur lors de l'ouverture du fichier image</translation>
        </message>
    </context>

    <context>
        <name>MsgPopup</name>
        <message>
            <location filename="usb-creator-next/src/MsgPopup.qml" line="107"/>
            <source>NO</source>
            <translation>NON</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/MsgPopup.qml" line="116"/>
            <source>YES</source>
            <translation>OUI</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/MsgPopup.qml" line="125"/>
            <source>CONTINUE</source>
            <translation>CONTINUER</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/MsgPopup.qml" line="133"/>
            <source>QUIT</source>
            <translation>QUITTER</translation>
        </message>
    </context>

    <context>
        <name>OptionsPopup</name>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="20"/>
            <source>OS Customization</source>
            <translation>Personnalisation du système d'exploitation</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="68"/>
            <source>General</source>
            <translation>Général</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="76"/>
            <source>Services</source>
            <translation>Services</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="79"/>
            <source>Options</source>
            <translation>Options</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="95"/>
            <source>Set hostname:</source>
            <translation>Définir le nom d'hôte :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="119"/>
            <source>Set username and password</source>
            <translation>Définir un nom d'utilisateur et un mot de passe</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="141"/>
            <source>Username:</source>
            <translation>Nom d'utilisateur :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="160"/>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="231"/>
            <source>Password:</source>
            <translation>Mot de passe :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="197"/>
            <source>Configure wireless LAN</source>
            <translation>Configurer le réseau sans fil (LAN)</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="216"/>
            <source>SSID:</source>
            <translation>SSID :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="251"/>
            <source>Show password</source>
            <translation>Afficher le mot de passe</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="257"/>
            <source>Hidden SSID</source>
            <translation>SSID masqué</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="263"/>
            <source>Wireless LAN country:</source>
            <translation>Pays du réseau sans fil :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="275"/>
            <source>Set locale settings</source>
            <translation>Définir les paramètres de localisation</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="285"/>
            <source>Time zone:</source>
            <translation>Fuseau horaire :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="296"/>
            <source>Keyboard layout:</source>
            <translation>Disposition du clavier :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="314"/>
            <source>Enable SSH</source>
            <translation>Activer SSH</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="333"/>
            <source>Use password authentication</source>
            <translation>Utiliser l'authentification par mot de passe</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="343"/>
            <source>Allow public-key authentication only</source>
            <translation>Autoriser uniquement l'authentification par clé publique</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="361"/>
            <source>Set authorized_keys for &apos;%1&apos;:</source>
            <translation>Définir les clés autorisées pour &apos;%1&apos; :</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="374"/>
            <source>RUN SSH-KEYGEN</source>
            <translation>EXÉCUTER SSH-KEYGEN</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="392"/>
            <source>Play sound when finished</source>
            <translation>Jouer un son lorsque terminé</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="396"/>
            <source>Eject media when finished</source>
            <translation>Éjecter le support lorsque terminé</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/OptionsPopup.qml" line="416"/>
            <source>SAVE</source>
            <translation>ENREGISTRER</translation>
        </message>
    </context>
    <context>
        <name>QObject</name>
        <message>
            <location filename="usb-creator-next/src/linux/linuxdrivelist.cpp" line="123"/>
            <source>Internal SD card reader</source>
            <translation>Lecteur de carte SD interne</translation>
        </message>
    </context>
    <context>
        <name>UnraidOptionsPopup</name>
        <message>
            <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="84"/>
            <source>Settings</source>
            <translation>Paramètres</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="137"/>
            <source>DHCP</source>
            <translation>DHCP</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="144"/>
            <source>Static IP</source>
            <translation>IP statique</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="230"/>
            <source>CONTINUE</source>
            <translation>CONTINUER</translation>
        </message>
    </context>
    <context>
        <name>UseSavedSettingsPopup</name>
        <message>
            <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="83"/>
            <source>Use OS customization?</source>
            <translation>Utiliser la personnalisation du système d'exploitation ?</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="99"/>
            <source>Would you like to apply OS customization settings?</source>
            <translation>Souhaitez-vous appliquer les paramètres de personnalisation du système d'exploitation ?</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="110"/>
            <source>EDIT SETTINGS</source>
            <translation>MODIFIER LES PARAMÈTRES</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="123"/>
            <source>NO, CLEAR SETTINGS</source>
            <translation>NON, EFFACER LES PARAMÈTRES</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="133"/>
            <source>YES</source>
            <translation>OUI</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="142"/>
            <source>NO</source>
            <translation>NON</translation>
        </message>
    </context>
    <context>
        <name>main</name>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="25"/>
            <source>Unraid USB Creator v%1</source>
            <translation>Créateur USB Unraid v%1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="92"/>
            <source>Help</source>
            <translation>Aide</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="159"/>
            <location filename="usb-creator-next/src/main.qml" line="641"/>
            <source>Device</source>
            <translation>Appareil</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="173"/>
            <source>CHOOSE DEVICE</source>
            <translation>CHOISIR L'APPAREIL</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="185"/>
            <source>Select this button to choose your target device</source>
            <translation>Sélectionnez ce bouton pour choisir votre appareil cible</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="201"/>
            <location filename="usb-creator-next/src/main.qml" line="750"/>
            <source>Operating System</source>
            <translation>Système d'exploitation</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="212"/>
            <location filename="usb-creator-next/src/main.qml" line="1855"/>
            <source>CHOOSE OS</source>
            <translation>CHOISIR L'OS</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="224"/>
            <source>Select this button to change the operating system</source>
            <translation>Sélectionnez ce bouton pour changer le système d'exploitation</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="238"/>
            <location filename="usb-creator-next/src/main.qml" line="1158"/>
            <source>Storage</source>
            <translation>Stockage</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="249"/>
            <location filename="usb-creator-next/src/main.qml" line="1529"/>
            <location filename="usb-creator-next/src/main.qml" line="1938"/>
            <source>CHOOSE STORAGE</source>
            <translation>CHOISIR LE STOCKAGE</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="263"/>
            <source>Select this button to change the destination storage device</source>
            <translation>Sélectionnez ce bouton pour changer l'appareil de stockage de destination</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="308"/>
            <source>CANCEL WRITE</source>
            <translation>ANNULER L'ÉCRITURE</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="311"/>
            <location filename="usb-creator-next/src/main.qml" line="1448"/>
            <source>Cancelling...</source>
            <translation>Annulation...</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="323"/>
            <source>CANCEL VERIFY</source>
            <translation>ANNULER LA VÉRIFICATION</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="326"/>
            <location filename="usb-creator-next/src/main.qml" line="1471"/>
            <location filename="usb-creator-next/src/main.qml" line="1548"/>
            <source>Finalizing...</source>
            <translation>Finalisation...</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="335"/>
            <source>Next</source>
            <translation>Suivant</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="341"/>
            <source>Select this button to start writing the image</source>
            <translation>Sélectionnez ce bouton pour commencer à écrire l'image</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="365"/>
            <source>Using custom repository: %1</source>
            <translation>Utilisation du dépôt personnalisé : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="375"/>
            <source>Network not ready yet</source>
            <translation>Réseau pas encore prêt</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="384"/>
            <source>Keyboard navigation: &lt;tab&gt; navigate to next button &lt;space&gt; press button/select item &lt;arrow up/down&gt; go up/down in lists</source>
            <translation>Navigation au clavier : &lt;tab&gt; naviguer vers le bouton suivant &lt;espace&gt; appuyer sur le bouton/sélectionner l'élément &lt;flèche haut/bas&gt; monter/descendre dans les listes</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="408"/>
            <source>Language: </source>
            <translation>Langue : </translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="455"/>
            <source>Keyboard: </source>
            <translation>Clavier : </translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="547"/>
            <source>Info</source>
            <translation>Info</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="570"/>
            <source>Select Language</source>
            <translation>Sélectionner la langue</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="660"/>
            <source>[ All ]</source>
            <translation>[ Tout ]</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="818"/>
            <source>Back</source>
            <translation>Retour</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="819"/>
            <source>Go back to main menu</source>
            <translation>Retourner au menu principal</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1067"/>
            <source>Released: %1</source>
            <translation>Publié : %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1077"/>
            <source>Cached on your computer</source>
            <translation>Mis en cache sur votre ordinateur</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1079"/>
            <source>Local file</source>
            <translation>Fichier local</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1080"/>
            <source>Online - %1 GB download</source>
            <translation>En ligne - %1 Go à télécharger</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1187"/>
            <source>No storage devices found</source>
            <translation>Aucun périphérique de stockage trouvé</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1223"/>
            <source> Mounted as %1</source>
            <translation> Monté en tant que %1</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1294"/>
            <source>Mounted as %1 </source>
            <translation>Monté en tant que %1 </translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1297"/>
            <source>[WRITE PROTECTED]</source>
            <translation>[ÉCRITURE PROTÉGÉE]</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1362"/>
            <source>About</source>
            <translation>À propos</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1364"/>
            <source>License, Credits, and History: </source>
            <translation>Licence, Crédits et Historique : </translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1364"/>
            <source>Help / Feedback: </source>
            <translation>Aide / Retour : </translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1372"/>
            <source>Are you sure you want to quit?</source>
            <translation>Êtes-vous sûr de vouloir quitter ?</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1373"/>
            <source>Unraid USB Creator is still busy.&lt;br&gt;Are you sure you want to quit?</source>
            <translation>Unraid USB Creator est encore occupé.&lt;br&gt;Êtes-vous sûr de vouloir quitter ?</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1384"/>
            <source>Warning</source>
            <translation>Avertissement</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1393"/>
            <source>Preparing to write...</source>
            <translation>Préparation à l'écriture...</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1407"/>
            <source>All existing data on &apos;%1&apos; will be erased.&lt;br&gt;Are you sure you want to continue?</source>
            <translation>Toutes les données existantes sur &apos;%1&apos; seront effacées.&lt;br&gt;Êtes-vous sûr de vouloir continuer ?</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1422"/>
            <source>Update available</source>
            <translation>Mise à jour disponible</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1423"/>
            <source>There is a newer version of Unraid USB Creator available.&lt;br&gt;Would you like to visit the website to download it?</source>
            <translation>Une nouvelle version de Unraid USB Creator est disponible.&lt;br&gt;Souhaitez-vous visiter le site pour la télécharger ?</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1451"/>
            <source>Writing... %1%</source>
            <translation>Écriture... %1%</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1474"/>
            <source>Verifying... %1%</source>
            <translation>Vérification... %1%</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1481"/>
            <source>Preparing to write... (%1)</source>
            <translation>Préparation à l'écriture... (%1)</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1501"/>
            <source>Error</source>
            <translation>Erreur</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1508"/>
            <source>Write Successful</source>
            <translation>Écriture réussie</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1509"/>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="617"/>
            <source>Erase</source>
            <translation>Effacer</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1510"/>
            <source>&lt;b&gt;%1&lt;/b&gt; has been erased.&lt;br&gt;&lt;br&gt;Your drive has been ejected, you can now safely remove it.</source>
            <translation>&lt;b&gt;%1&lt;/b&gt; a été effacé.&lt;br&gt;&lt;br&gt;Votre disque a été éjecté, vous pouvez maintenant le retirer en toute sécurité.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1517"/>
            <source>&lt;b&gt;%1&lt;/b&gt; has been written to &lt;b&gt;%2&lt;/b&gt;.</source>
            <translation>&lt;b&gt;%1&lt;/b&gt; a été écrit sur &lt;b&gt;%2&lt;/b&gt;.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1519"/>
            <source>&lt;br&gt;&lt;br&gt;If you would like to enable legacy boot (bios), helpful for old hardware, please run the &apos;make_bootable_(mac/linux/windows)&apos; script from this computer, located in the main folder of the UNRAID flash drive.</source>
            <translation>&lt;br&gt;&lt;br&gt;Si vous souhaitez activer le démarrage hérité (bios), utile pour le matériel ancien, veuillez exécuter le script &apos;make_bootable_(mac/linux/windows)&apos; depuis cet ordinateur, situé dans le dossier principal de la clé USB UNRAID.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1675"/>
            <source>Error parsing os_list.json</source>
            <translation>Erreur lors de l'analyse de os_list.json</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1929"/>
            <source>Connect an USB stick containing images first.&lt;br&gt;The images must be located in the root folder of the USB stick.</source>
            <translation>Connectez d'abord une clé USB contenant des images.&lt;br&gt;Les images doivent être situées dans le dossier racine de la clé USB.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1935"/>
            <location filename="usb-creator-next/src/main.qml" line="1956"/>
            <source>Selected device cannot be used to create an Unraid USB due to its invalid GUID.</source>
            <translation>Le périphérique sélectionné ne peut pas être utilisé pour créer un USB Unraid en raison de son GUID invalide.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/main.qml" line="1951"/>
            <source>SD card is write protected.&lt;br&gt;Push the lock switch on the left side of the card upwards, and try again.</source>
            <translation>La carte SD est protégée en écriture.&lt;br&gt;Poussez le commutateur de verrouillage sur le côté gauche de la carte vers le haut et réessayez.</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="618"/>
            <source>Format USB Drive as FAT32</source>
            <translation>Formater la clé USB en FAT32</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="624"/>
            <source>Use custom</source>
            <translation>Utiliser personnalisé</translation>
        </message>
        <message>
            <location filename="usb-creator-next/src/imagewriter.cpp" line="625"/>
            <source>Select an Unraid .zip file from your computer</source>
            <translation>Sélectionnez un fichier .zip Unraid depuis votre ordinateur</translation>
        </message>
    </context>
</TS>
