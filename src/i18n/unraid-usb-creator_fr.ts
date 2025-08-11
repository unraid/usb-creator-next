<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="fr_FR">
<context>
    <name>DownloadExtractThread</name>
    <message>
        <source>Error extracting archive: %1</source>
        <translation type="vanished">Erreur lors de l&apos;extraction de l&apos;archive : %1</translation>
    </message>
    <message>
        <source>Error mounting FAT32 partition</source>
        <translation type="vanished">Erreur lors du montage de la partition FAT32</translation>
    </message>
    <message>
        <source>Operating system did not mount FAT32 partition</source>
        <translation type="vanished">Le système d&apos;exploitation n&apos;a pas monté la partition FAT32</translation>
    </message>
    <message>
        <source>Error changing to directory &apos;%1&apos;</source>
        <translation type="vanished">Erreur lors du changement de répertoire vers &apos;%1&apos;</translation>
    </message>
</context>
<context>
    <name>DownloadThread</name>
    <message>
        <source>unmounting drive</source>
        <translation type="vanished">déconnexion du disque</translation>
    </message>
    <message>
        <source>opening drive</source>
        <translation type="vanished">ouverture du disque</translation>
    </message>
    <message>
        <source>Error running diskpart: %1</source>
        <translation type="vanished">Erreur lors de l&apos;exécution de diskpart : %1</translation>
    </message>
    <message>
        <source>Error removing existing partitions</source>
        <translation type="vanished">Erreur lors de la suppression des partitions existantes</translation>
    </message>
    <message>
        <source>Authentication cancelled</source>
        <translation type="vanished">Authentification annulée</translation>
    </message>
    <message>
        <source>Error running authopen to gain access to disk device &apos;%1&apos;</source>
        <translation type="vanished">Erreur lors de l&apos;exécution d&apos;authopen pour accéder au périphérique disque &apos;%1&apos;</translation>
    </message>
    <message>
        <source>Please verify if &apos;Unraid USB Creator&apos; is allowed access to &apos;removable volumes&apos; in privacy settings (under &apos;files and folders&apos; or alternatively give it &apos;full disk access&apos;).</source>
        <translation type="vanished">Veuillez vérifier si &apos;Unraid USB Creator&apos; a accès aux &apos;volumes amovibles&apos; dans les paramètres de confidentialité (sous &apos;fichiers et dossiers&apos; ou donner un &apos;accès complet au disque&apos;).</translation>
    </message>
    <message>
        <source>Cannot open storage device &apos;%1&apos;.</source>
        <translation type="vanished">Impossible d&apos;ouvrir le périphérique de stockage &apos;%1&apos;.</translation>
    </message>
    <message>
        <source>discarding existing data on drive</source>
        <translation type="vanished">suppression des données existantes sur le disque</translation>
    </message>
    <message>
        <source>zeroing out first and last MB of drive</source>
        <translation type="vanished">remise à zéro du premier et du dernier Mo du disque</translation>
    </message>
    <message>
        <source>Write error while zero&apos;ing out MBR</source>
        <translation type="vanished">Erreur d&apos;écriture lors de la remise à zéro du MBR</translation>
    </message>
    <message>
        <source>Write error while trying to zero out last part of card.&lt;br&gt;Card could be advertising wrong capacity (possible counterfeit).</source>
        <translation type="vanished">Erreur d&apos;écriture lors de la remise à zéro de la dernière partie de la carte.&lt;br&gt;La carte pourrait indiquer une capacité incorrecte (possiblement contrefaite).</translation>
    </message>
    <message>
        <source>starting download</source>
        <translation type="vanished">début du téléchargement</translation>
    </message>
    <message>
        <source>Error downloading: %1</source>
        <translation type="vanished">Erreur lors du téléchargement : %1</translation>
    </message>
    <message>
        <source>Access denied error while writing file to disk.</source>
        <translation type="vanished">Erreur d&apos;accès refusé lors de l&apos;écriture du fichier sur le disque.</translation>
    </message>
    <message>
        <source>Controlled Folder Access seems to be enabled. Please add both unraid-usb-creator.exe and fat32format.exe to the list of allowed apps and try again.</source>
        <translation type="vanished">L&apos;accès contrôlé aux dossiers semble être activé. Veuillez ajouter unraid-usb-creator.exe et fat32format.exe à la liste des applications autorisées et réessayer.</translation>
    </message>
    <message>
        <source>Error writing file to disk</source>
        <translation type="vanished">Erreur lors de l&apos;écriture du fichier sur le disque</translation>
    </message>
    <message>
        <source>Download corrupt. Hash does not match</source>
        <translation type="vanished">Téléchargement corrompu. Le hash ne correspond pas</translation>
    </message>
    <message>
        <source>Error writing to storage (while flushing)</source>
        <translation type="vanished">Erreur lors de l&apos;écriture sur le support (lors du vidage)</translation>
    </message>
    <message>
        <source>Error writing to storage (while fsync)</source>
        <translation type="vanished">Erreur lors de l&apos;écriture sur le support (lors de la synchronisation fsync)</translation>
    </message>
    <message>
        <source>Error writing first block (partition table)</source>
        <translation type="vanished">Erreur lors de l&apos;écriture du premier bloc (table de partition)</translation>
    </message>
    <message>
        <source>Error reading from storage.&lt;br&gt;SD card may be broken.</source>
        <translation type="vanished">Erreur de lecture sur le support.&lt;br&gt;La carte SD peut être endommagée.</translation>
    </message>
    <message>
        <source>Verifying write failed. Contents of SD card is different from what was written to it.</source>
        <translation type="vanished">Échec de la vérification de l&apos;écriture. Le contenu de la carte SD est différent de ce qui a été écrit.</translation>
    </message>
    <message>
        <source>Customizing image</source>
        <translation type="vanished">Personnalisation de l&apos;image</translation>
    </message>
</context>
<context>
    <name>DriveFormatThread</name>
    <message>
        <source>Error partitioning: %1</source>
        <translation type="vanished">Erreur de partitionnement : %1</translation>
    </message>
    <message>
        <source>Error starting fat32format</source>
        <translation type="vanished">Erreur lors du démarrage de fat32format</translation>
    </message>
    <message>
        <source>Error running fat32format: %1</source>
        <translation type="vanished">Erreur lors de l&apos;exécution de fat32format : %1</translation>
    </message>
    <message>
        <source>Error determining new drive letter</source>
        <translation type="vanished">Erreur lors de la détermination de la nouvelle lettre de lecteur</translation>
    </message>
    <message>
        <source>Invalid device: %1</source>
        <translation type="vanished">Périphérique invalide : %1</translation>
    </message>
    <message>
        <source>Error formatting (through udisks2)</source>
        <translation type="vanished">Erreur lors du formatage (via udisks2)</translation>
    </message>
    <message>
        <source>Elevated privileges needed to properly format drive.</source>
        <translation type="vanished">Des privilèges élevés sont nécessaires pour formater correctement le disque.</translation>
    </message>
    <message>
        <source>Error starting sfdisk</source>
        <translation type="vanished">Erreur lors du démarrage de sfdisk</translation>
    </message>
    <message>
        <source>Partitioning did not create expected FAT partition %1</source>
        <translation type="vanished">Le partitionnement n&apos;a pas créé la partition FAT attendue %1</translation>
    </message>
    <message>
        <source>Error starting mkfs.fat</source>
        <translation type="vanished">Erreur lors du démarrage de mkfs.fat</translation>
    </message>
    <message>
        <source>Error running mkfs.fat: %1</source>
        <translation type="vanished">Erreur lors de l&apos;exécution de mkfs.fat : %1</translation>
    </message>
    <message>
        <source>Formatting not implemented for this platform</source>
        <translation type="vanished">Le formatage n&apos;est pas implémenté pour cette plateforme</translation>
    </message>
</context>
<context>
    <name>ImageWriter</name>
    <message>
        <source>Storage capacity is not large enough.&lt;br&gt;Needs to be at least %1 GB.</source>
        <translation type="vanished">La capacité de stockage n&apos;est pas suffisante.&lt;br&gt;Elle doit être d&apos;au moins %1 Go.</translation>
    </message>
    <message>
        <source>Input file is not a valid disk image.&lt;br&gt;File size %1 bytes is not a multiple of 512 bytes.</source>
        <translation type="vanished">Le fichier d&apos;entrée n&apos;est pas une image disque valide.&lt;br&gt;La taille du fichier %1 octets n&apos;est pas un multiple de 512 octets.</translation>
    </message>
    <message>
        <source>Downloading and writing image</source>
        <translation type="vanished">Téléchargement et écriture de l&apos;image</translation>
    </message>
    <message>
        <source>Select image</source>
        <translation type="vanished">Sélectionner l&apos;image</translation>
    </message>
    <message>
        <source>Error synchronizing time. Trying again in 3 seconds</source>
        <translation type="vanished">Erreur de synchronisation de l&apos;heure. Nouvelle tentative dans 3 secondes</translation>
    </message>
    <message>
        <source>STP is enabled on your Ethernet switch. Getting IP will take long time.</source>
        <translation type="vanished">STP est activé sur votre switch Ethernet. L&apos;obtention de l&apos;IP prendra du temps.</translation>
    </message>
    <message>
        <source>Would you like to prefill the wifi password from the system keychain?</source>
        <translation type="vanished">Souhaitez-vous pré-remplir le mot de passe wifi à partir du trousseau de clés du système ?</translation>
    </message>
</context>
<context>
    <name>LocalFileExtractThread</name>
    <message>
        <source>opening image file</source>
        <translation type="vanished">ouverture du fichier image</translation>
    </message>
    <message>
        <source>Error opening image file</source>
        <translation type="vanished">Erreur lors de l&apos;ouverture du fichier image</translation>
    </message>
</context>
<context>
    <name>MsgPopup</name>
    <message>
        <source>NO</source>
        <translation type="vanished">NON</translation>
    </message>
    <message>
        <source>YES</source>
        <translation type="vanished">OUI</translation>
    </message>
    <message>
        <source>CONTINUE</source>
        <translation type="vanished">CONTINUER</translation>
    </message>
    <message>
        <source>QUIT</source>
        <translation type="vanished">QUITTER</translation>
    </message>
</context>
<context>
    <name>OptionsPopup</name>
    <message>
        <source>OS Customization</source>
        <translation type="vanished">Personnalisation du système d&apos;exploitation</translation>
    </message>
    <message>
        <source>General</source>
        <translation type="vanished">Général</translation>
    </message>
    <message>
        <source>Services</source>
        <translation type="vanished">Services</translation>
    </message>
    <message>
        <source>Options</source>
        <translation type="vanished">Options</translation>
    </message>
    <message>
        <source>Set hostname:</source>
        <translation type="vanished">Définir le nom d&apos;hôte :</translation>
    </message>
    <message>
        <source>Set username and password</source>
        <translation type="vanished">Définir un nom d&apos;utilisateur et un mot de passe</translation>
    </message>
    <message>
        <source>Username:</source>
        <translation type="vanished">Nom d&apos;utilisateur :</translation>
    </message>
    <message>
        <source>Password:</source>
        <translation type="vanished">Mot de passe :</translation>
    </message>
    <message>
        <source>Configure wireless LAN</source>
        <translation type="vanished">Configurer le réseau sans fil (LAN)</translation>
    </message>
    <message>
        <source>SSID:</source>
        <translation type="vanished">SSID :</translation>
    </message>
    <message>
        <source>Show password</source>
        <translation type="vanished">Afficher le mot de passe</translation>
    </message>
    <message>
        <source>Hidden SSID</source>
        <translation type="vanished">SSID masqué</translation>
    </message>
    <message>
        <source>Wireless LAN country:</source>
        <translation type="vanished">Pays du réseau sans fil :</translation>
    </message>
    <message>
        <source>Set locale settings</source>
        <translation type="vanished">Définir les paramètres de localisation</translation>
    </message>
    <message>
        <source>Time zone:</source>
        <translation type="vanished">Fuseau horaire :</translation>
    </message>
    <message>
        <source>Keyboard layout:</source>
        <translation type="vanished">Disposition du clavier :</translation>
    </message>
    <message>
        <source>Enable SSH</source>
        <translation type="vanished">Activer SSH</translation>
    </message>
    <message>
        <source>Use password authentication</source>
        <translation type="vanished">Utiliser l&apos;authentification par mot de passe</translation>
    </message>
    <message>
        <source>Allow public-key authentication only</source>
        <translation type="vanished">Autoriser uniquement l&apos;authentification par clé publique</translation>
    </message>
    <message>
        <source>Set authorized_keys for &apos;%1&apos;:</source>
        <translation type="vanished">Définir les clés autorisées pour &apos;%1&apos; :</translation>
    </message>
    <message>
        <source>RUN SSH-KEYGEN</source>
        <translation type="vanished">EXÉCUTER SSH-KEYGEN</translation>
    </message>
    <message>
        <source>Play sound when finished</source>
        <translation type="vanished">Jouer un son lorsque terminé</translation>
    </message>
    <message>
        <source>Eject media when finished</source>
        <translation type="vanished">Éjecter le support lorsque terminé</translation>
    </message>
    <message>
        <source>SAVE</source>
        <translation type="vanished">ENREGISTRER</translation>
    </message>
</context>
<context>
    <name>QObject</name>
    <message>
        <source>Internal SD card reader</source>
        <translation type="vanished">Lecteur de carte SD interne</translation>
    </message>
</context>
<context>
    <name>UnraidOptionsPopup</name>
    <message>
        <source>Settings</source>
        <translation type="vanished">Paramètres</translation>
    </message>
    <message>
        <source>DHCP</source>
        <translation type="vanished">DHCP</translation>
    </message>
    <message>
        <source>Static IP</source>
        <translation type="vanished">IP statique</translation>
    </message>
    <message>
        <source>CONTINUE</source>
        <translation type="vanished">CONTINUER</translation>
    </message>
</context>
<context>
    <name>UseSavedSettingsPopup</name>
    <message>
        <source>Use OS customization?</source>
        <translation type="vanished">Utiliser la personnalisation du système d&apos;exploitation&#xa0;?</translation>
    </message>
    <message>
        <source>Would you like to apply OS customization settings?</source>
        <translation type="vanished">Souhaitez-vous appliquer les paramètres de personnalisation du système d&apos;exploitation&#xa0;?</translation>
    </message>
    <message>
        <source>EDIT SETTINGS</source>
        <translation type="vanished">MODIFIER LES PARAMÈTRES</translation>
    </message>
    <message>
        <source>NO, CLEAR SETTINGS</source>
        <translation type="vanished">NON, EFFACER LES PARAMÈTRES</translation>
    </message>
    <message>
        <source>YES</source>
        <translation type="vanished">OUI</translation>
    </message>
    <message>
        <source>NO</source>
        <translation type="vanished">NON</translation>
    </message>
</context>
<context>
    <name>main</name>
    <message>
        <location filename="../main.qml" line="24"/>
        <source>Unraid USB Creator v%1</source>
        <translation>Créateur USB Unraid v%1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="100"/>
        <source>Help</source>
        <translation>Aide</translation>
    </message>
    <message>
        <location filename="../main.qml" line="167"/>
        <location filename="../main.qml" line="659"/>
        <source>Device</source>
        <translation>Appareil</translation>
    </message>
    <message>
        <location filename="../main.qml" line="181"/>
        <source>CHOOSE DEVICE</source>
        <translation>CHOISIR L&apos;APPAREIL</translation>
    </message>
    <message>
        <location filename="../main.qml" line="193"/>
        <source>Select this button to choose your target device</source>
        <translation>Sélectionnez ce bouton pour choisir votre appareil cible</translation>
    </message>
    <message>
        <location filename="../main.qml" line="209"/>
        <location filename="../main.qml" line="771"/>
        <source>Operating System</source>
        <translation>Système d&apos;exploitation</translation>
    </message>
    <message>
        <location filename="../main.qml" line="220"/>
        <location filename="../main.qml" line="1885"/>
        <source>CHOOSE OS</source>
        <translation>CHOISIR L&apos;OS</translation>
    </message>
    <message>
        <location filename="../main.qml" line="232"/>
        <source>Select this button to change the operating system</source>
        <translation>Sélectionnez ce bouton pour changer le système d&apos;exploitation</translation>
    </message>
    <message>
        <location filename="../main.qml" line="246"/>
        <location filename="../main.qml" line="1180"/>
        <source>Storage</source>
        <translation>Stockage</translation>
    </message>
    <message>
        <location filename="../main.qml" line="257"/>
        <location filename="../main.qml" line="1572"/>
        <source>CHOOSE STORAGE</source>
        <translation>CHOISIR LE STOCKAGE</translation>
    </message>
    <message>
        <location filename="../main.qml" line="271"/>
        <source>Select this button to change the destination storage device</source>
        <translation>Sélectionnez ce bouton pour changer l&apos;appareil de stockage de destination</translation>
    </message>
    <message>
        <location filename="../main.qml" line="316"/>
        <source>CANCEL WRITE</source>
        <translation>ANNULER L&apos;ÉCRITURE</translation>
    </message>
    <message>
        <location filename="../main.qml" line="319"/>
        <location filename="../main.qml" line="1491"/>
        <source>Cancelling...</source>
        <translation>Annulation...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="331"/>
        <source>CANCEL VERIFY</source>
        <translation>ANNULER LA VÉRIFICATION</translation>
    </message>
    <message>
        <location filename="../main.qml" line="334"/>
        <location filename="../main.qml" line="1513"/>
        <location filename="../main.qml" line="1591"/>
        <source>Finalizing...</source>
        <translation>Finalisation...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="343"/>
        <source>Next</source>
        <translation>Suivant</translation>
    </message>
    <message>
        <location filename="../main.qml" line="349"/>
        <source>Select this button to start writing the image</source>
        <translation>Sélectionnez ce bouton pour commencer à écrire l&apos;image</translation>
    </message>
    <message>
        <location filename="../main.qml" line="371"/>
        <source>Using custom repository: %1</source>
        <translation>Utilisation du dépôt personnalisé : %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="381"/>
        <source>Network not ready yet</source>
        <translation>Réseau pas encore prêt</translation>
    </message>
    <message>
        <location filename="../main.qml" line="390"/>
        <source>Keyboard navigation: &lt;tab&gt; navigate to next button &lt;space&gt; press button/select item &lt;arrow up/down&gt; go up/down in lists</source>
        <translation>Navigation au clavier : &lt;tab&gt; naviguer vers le bouton suivant &lt;espace&gt; appuyer sur le bouton/sélectionner l&apos;élément &lt;flèche haut/bas&gt; monter/descendre dans les listes</translation>
    </message>
    <message>
        <location filename="../main.qml" line="414"/>
        <source>Language: </source>
        <translation>Langue : </translation>
    </message>
    <message>
        <location filename="../main.qml" line="461"/>
        <source>Keyboard: </source>
        <translation>Clavier : </translation>
    </message>
    <message>
        <location filename="../main.qml" line="552"/>
        <source>Info</source>
        <translation>Info</translation>
    </message>
    <message>
        <location filename="../main.qml" line="575"/>
        <source>Select Language</source>
        <translation>Sélectionner la langue</translation>
    </message>
    <message>
        <location filename="../main.qml" line="678"/>
        <source>[ All ]</source>
        <translation>[ Tout ]</translation>
    </message>
    <message>
        <location filename="../main.qml" line="842"/>
        <source>Back</source>
        <translation>Retour</translation>
    </message>
    <message>
        <location filename="../main.qml" line="843"/>
        <source>Go back to main menu</source>
        <translation>Retourner au menu principal</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1094"/>
        <source>Released: %1</source>
        <translation>Publié : %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1102"/>
        <source>Cached on your computer</source>
        <translation>Mis en cache sur votre ordinateur</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1102"/>
        <source>Local file</source>
        <translation>Fichier local</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1102"/>
        <source>Online - %1 GB download</source>
        <translation>En ligne - %1 Go à télécharger</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1212"/>
        <source>No storage devices found</source>
        <translation>Aucun périphérique de stockage trouvé</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1248"/>
        <source> Mounted as %1</source>
        <translation> Monté en tant que %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1336"/>
        <source>Mounted as %1 </source>
        <translation>Monté en tant que %1 </translation>
    </message>
    <message>
        <location filename="../main.qml" line="1339"/>
        <source>[WRITE PROTECTED]</source>
        <translation>[ÉCRITURE PROTÉGÉE]</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1361"/>
        <source>GUID: %1</source>
        <translation type="unfinished"></translation>
    </message>
    <message>
    <location filename="../main.qml" line="1361"/>
    <source>GUID: %1 &lt;font color=&apos;red&apos;&gt;[BLACKLISTED]&lt;/font&gt;</source>
    <translation>GUID : %1 &lt;font color=&apos;red&apos;&gt;[SUR LISTE NOIRE]&lt;/font&gt;</translation>
</message>
<message>
    <location filename="../main.qml" line="1363"/>
    <source>&lt;font color=&apos;red&apos;&gt;[MISSING GUID - Choose Another Flash Device]&lt;/font&gt;</source>
    <translation>&lt;font color=&apos;red&apos;&gt;[GUID MANQUANT – Choisissez un autre périphérique USB]&lt;/font&gt;</translation>
</message>
<message>
    <location filename="../main.qml" line="1380"/>
    <source>This USB device is blacklisted. You may not be able to use this device to get an Unraid license or trial.</source>
    <translation>Ce périphérique USB est sur liste noire. Il se peut que vous ne puissiez pas l’utiliser pour obtenir une licence ou un essai d’Unraid.</translation>
</message>

    <message>
        <location filename="../main.qml" line="1406"/>
        <source>About</source>
        <translation>À propos</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1408"/>
        <source>License, Credits, and History: </source>
        <translation>Licence, Crédits et Historique : </translation>
    </message>
    <message>
        <location filename="../main.qml" line="1408"/>
        <source>Help / Feedback: </source>
        <translation>Aide / Retour : </translation>
    </message>
    <message>
        <location filename="../main.qml" line="1416"/>
        <source>Are you sure you want to quit?</source>
        <translation>Êtes-vous sûr de vouloir quitter ?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1417"/>
        <source>Unraid USB Creator is still busy.&lt;br&gt;Are you sure you want to quit?</source>
        <translation>Unraid USB Creator est encore occupé.&lt;br&gt;Êtes-vous sûr de vouloir quitter ?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1428"/>
        <source>Warning</source>
        <translation>Avertissement</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1437"/>
        <source>Preparing to write...</source>
        <translation>Préparation à l&apos;écriture...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1450"/>
        <source>All existing data on &apos;%1&apos; will be erased.&lt;br&gt;Are you sure you want to continue?</source>
        <translation>Toutes les données existantes sur &apos;%1&apos; seront effacées.&lt;br&gt;Êtes-vous sûr de vouloir continuer ?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1465"/>
        <source>Update available</source>
        <translation>Mise à jour disponible</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1466"/>
        <source>There is a newer version of Unraid USB Creator available.&lt;br&gt;Would you like to visit the website to download it?</source>
        <translation>Une nouvelle version de Unraid USB Creator est disponible.&lt;br&gt;Souhaitez-vous visiter le site pour la télécharger ?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1493"/>
        <source>Writing... %1%</source>
        <translation>Écriture... %1%</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1515"/>
        <source>Verifying... %1%</source>
        <translation>Vérification... %1%</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1522"/>
        <source>Preparing to write... (%1)</source>
        <translation>Préparation à l&apos;écriture... (%1)</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1542"/>
        <source>Error</source>
        <translation>Erreur</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1549"/>
        <source>Write Successful</source>
        <translation>Écriture réussie</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1550"/>
        <source>Erase</source>
        <translation>Effacer</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1551"/>
        <source>&lt;b&gt;%1&lt;/b&gt; has been erased.&lt;br&gt;&lt;br&gt;Your drive has been ejected, you can now safely remove it.</source>
        <translation>&lt;b&gt;%1&lt;/b&gt; a été effacé.&lt;br&gt;&lt;br&gt;Votre disque a été éjecté, vous pouvez maintenant le retirer en toute sécurité.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1557"/>
        <source>&lt;b&gt;%1&lt;/b&gt; has been written to &lt;b&gt;%2&lt;/b&gt;.</source>
        <translation>&lt;b&gt;%1&lt;/b&gt; a été écrit sur &lt;b&gt;%2&lt;/b&gt;.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1560"/>
        <source>&lt;br&gt;&lt;br&gt;If you would like to enable legacy boot (bios), helpful for old hardware, please run the &apos;make_bootable_(mac/linux/windows)&apos; script from this computer, located in the main folder of the UNRAID flash drive.</source>
        <translation>&lt;br&gt;&lt;br&gt;Si vous souhaitez activer le démarrage hérité (bios), utile pour le matériel ancien, veuillez exécuter le script &apos;make_bootable_(mac/linux/windows)&apos; depuis cet ordinateur, situé dans le dossier principal de la clé USB UNRAID.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1713"/>
        <source>Error parsing os_list.json</source>
        <translation>Erreur lors de l&apos;analyse de os_list.json</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1949"/>
        <source>Connect an USB stick containing images first.&lt;br&gt;The images must be located in the root folder of the USB stick.</source>
        <translation>Connectez d&apos;abord une clé USB contenant des images.&lt;br&gt;Les images doivent être situées dans le dossier racine de la clé USB.</translation>
    </message>
    <message>
        <source>Selected device cannot be used to create an Unraid USB due to its invalid GUID.</source>
        <translation type="vanished">Le périphérique sélectionné ne peut pas être utilisé pour créer un USB Unraid en raison de son GUID invalide.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1965"/>
        <source>SD card is write protected.&lt;br&gt;Push the lock switch on the left side of the card upwards, and try again.</source>
        <translation>La carte SD est protégée en écriture.&lt;br&gt;Poussez le commutateur de verrouillage sur le côté gauche de la carte vers le haut et réessayez.</translation>
    </message>
    <message>
        <source>Format USB Drive as FAT32</source>
        <translation type="vanished">Formater la clé USB en FAT32</translation>
    </message>
    <message>
        <source>Use custom</source>
        <translation type="vanished">Utiliser personnalisé</translation>
    </message>
    <message>
        <source>Select an Unraid .zip file from your computer</source>
        <translation type="vanished">Sélectionnez un fichier .zip Unraid depuis votre ordinateur</translation>
    </message>
</context>
</TS>
