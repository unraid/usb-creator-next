<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="es_ES">
<context>
    <name>DownloadExtractThread</name>
    <message>
        <source>Error extracting archive: %1</source>
        <translation type="vanished">Error extrayendo el archivo: %1</translation>
    </message>
    <message>
        <source>Error mounting FAT32 partition</source>
        <translation type="vanished">Error montando la partición FAT32</translation>
    </message>
    <message>
        <source>Operating system did not mount FAT32 partition</source>
        <translation type="vanished">El sistema operativo no montó la partición FAT32</translation>
    </message>
    <message>
        <source>Error changing to directory &apos;%1&apos;</source>
        <translation type="vanished">Error cambiando al directorio &apos;%1&apos;</translation>
    </message>
</context>
<context>
    <name>DownloadThread</name>
    <message>
        <source>Unmounting drive</source>
        <translation type="vanished">Desmontando unidad</translation>
    </message>
    <message>
        <source>Opening drive</source>
        <translation type="vanished">Abriendo unidad</translation>
    </message>
    <message>
        <source>Error running diskpart: %1</source>
        <translation type="vanished">Error ejecutando diskpart: %1</translation>
    </message>
    <message>
        <source>Error removing existing partitions</source>
        <translation type="vanished">Error eliminando las particiones existentes</translation>
    </message>
    <message>
        <source>Authentication cancelled</source>
        <translation type="vanished">Autenticación cancelada</translation>
    </message>
    <message>
        <source>Error running authopen to gain access to disk device &apos;%1&apos;</source>
        <translation type="vanished">Error ejecutando authopen para acceder al dispositivo de disco &apos;%1&apos;</translation>
    </message>
    <message>
        <source>Please verify if &apos;Unraid USB Creator&apos; is allowed access to &apos;removable volumes&apos; in privacy settings (under &apos;files and folders&apos; or alternatively give it &apos;full disk access&apos;).</source>
        <translation type="vanished">Por favor, compruebe si &apos;Unraid USB Creator&apos; tiene permitido el acceso a &apos;volúmenes extraíbles&apos; en los ajustes de privacidad (en &apos;archivos y carpetas&apos; o alternativamente dele &apos;acceso total al disco&apos;).</translation>
    </message>
    <message>
        <source>Cannot open storage device &apos;%1&apos;.</source>
        <translation type="vanished">No se puede abrir el dispositivo de almacenamiento &apos;1&apos;.</translation>
    </message>
    <message>
        <source>Discarding existing data on drive</source>
        <translation type="vanished">Descartando datos existentes en la unidad</translation>
    </message>
    <message>
        <source>Zeroing out first and last MB of drive</source>
        <translation type="vanished">Poniendo a cero el primer y el último MB de la unidad</translation>
    </message>
    <message>
        <source>Write error while zero&apos;ing out MBR</source>
        <translation type="vanished">Error de escritura al poner a cero MBR</translation>
    </message>
    <message>
        <source>Write error while trying to zero out last part of card.&lt;br&gt;Card could be advertising wrong capacity (possible counterfeit).</source>
        <translation type="vanished">Error de escritura al intentar poner a cero la última parte de la tarjeta.&lt;br&gt;La tarjeta podría estar anunciando una capacidad incorrecta (posible falsificación).</translation>
    </message>
    <message>
        <source>Starting download</source>
        <translation type="vanished">Iniciando descarga</translation>
    </message>
    <message>
        <source>Error downloading: %1</source>
        <translation type="vanished">Error descargando: %1</translation>
    </message>
    <message>
        <source>Access denied error while writing file to disk.</source>
        <translation type="vanished">Error de acceso denegado escribiendo el archivo en el disco.</translation>
    </message>
    <message>
        <source>Controlled Folder Access seems to be enabled. Please add both unraid-usb-creator.exe and fat32format.exe to the list of allowed apps and try again.</source>
        <translation type="vanished">El acceso controlado a carpetas parece estar activado. Añada rpi-imager.exe y fat32format.exe a la lista de aplicaciones permitidas y vuelva a intentarlo.</translation>
    </message>
    <message>
        <source>Error writing file to disk</source>
        <translation type="vanished">Error escribiendo el archivo en el disco</translation>
    </message>
    <message>
        <source>Download corrupt. Hash does not match</source>
        <translation type="vanished">Descarga corrupta. El hash no coincide</translation>
    </message>
    <message>
        <source>Error writing to storage (while flushing)</source>
        <translation type="vanished">Error escribiendo en la memoria (durante la limpieza)</translation>
    </message>
    <message>
        <source>Error writing to storage (while fsync)</source>
        <translation type="vanished">Error escribiendo en el almacenamiento (mientras fsync)</translation>
    </message>
    <message>
        <source>Error writing first block (partition table)</source>
        <translation type="vanished">Error escribiendo el primer bloque (tabla de particiones)</translation>
    </message>
    <message>
        <source>Error reading from storage.&lt;br&gt;SD card may be broken.</source>
        <translation type="vanished">Error leyendo del almacenamiento.&lt;br&gt;La tarjeta SD puede estar rota.</translation>
    </message>
    <message>
        <source>Verifying write failed. Contents of SD card is different from what was written to it.</source>
        <translation type="vanished">Error verificando la escritura. El contenido de la tarjeta SD es diferente del que se escribió en ella.</translation>
    </message>
    <message>
        <source>Customizing image</source>
        <translation type="vanished">Personalizando imagen</translation>
    </message>
</context>
<context>
    <name>DriveFormatThread</name>
    <message>
        <source>Error partitioning: %1</source>
        <translation type="vanished">Error particionando: %1</translation>
    </message>
    <message>
        <source>Error starting fat32format</source>
        <translation type="vanished">Error iniciando fat32format</translation>
    </message>
    <message>
        <source>Error running fat32format: %1</source>
        <translation type="vanished">Error ejecutando fat32format: %1</translation>
    </message>
    <message>
        <source>Error determining new drive letter</source>
        <translation type="vanished">Error determinando la nueva letra de unidad</translation>
    </message>
    <message>
        <source>Invalid device: %1</source>
        <translation type="vanished">Dispositivo no válido: %1</translation>
    </message>
    <message>
        <source>Error formatting (through udisks2)</source>
        <translation type="vanished">Error formateando (a través de udisks2)</translation>
    </message>
    <message>
        <source>Elevated privileges needed to properly format drive.</source>
        <translation type="vanished">Se necesitan privilegios elevados para formatear correctamente la unidad.</translation>
    </message>
    <message>
        <source>Error starting sfdisk</source>
        <translation type="vanished">Error iniciando sfdisk</translation>
    </message>
    <message>
        <source>Partitioning did not create expected FAT partition %1</source>
        <translation type="vanished">El particionado no creó la partición FAT %1 esperada</translation>
    </message>
    <message>
        <source>Error starting mkfs.fat</source>
        <translation type="vanished">Error iniciando mkfs.fat</translation>
    </message>
    <message>
        <source>Error running mkfs.fat: %1</source>
        <translation type="vanished">Error ejecutando mkfs.fat: %1</translation>
    </message>
    <message>
        <source>Formatting not implemented for this platform</source>
        <translation type="vanished">Formateo no implementado para esta plataforma</translation>
    </message>
</context>
<context>
    <name>ImageWriter</name>
    <message>
        <source>Storage capacity is not large enough.&lt;br&gt;Needs to be at least %1 GB.</source>
        <translation type="vanished">La capacidad de almacenamiento no es lo suficientemente grande.&lt;br&gt;Necesita ser de al menos %1 GB.</translation>
    </message>
    <message>
        <source>Input file is not a valid disk image.&lt;br&gt;File size %1 bytes is not a multiple of 512 bytes.</source>
        <translation type="vanished">El archivo de entrada no es una imagen de disco válida.&lt;br&gt;El tamaño del archivo %1 bytes no es múltiplo de 512 bytes.</translation>
    </message>
    <message>
        <source>Downloading and writing image</source>
        <translation type="vanished">Descargando y escribiendo imagen</translation>
    </message>
    <message>
        <source>Select image</source>
        <translation type="vanished">Seleccionar imagen</translation>
    </message>
    <message>
        <source>Error synchronizing time. Trying again in 3 seconds</source>
        <translation type="vanished">Error al sincronizar la hora. Intentaré nuevamente en 3 segundos</translation>
    </message>
    <message>
        <source>STP is enabled on your Ethernet switch. Getting IP will take long time.</source>
        <translation type="vanished">STP está habilitado en su switch Ethernet. Obtener IP llevará mucho tiempo.</translation>
    </message>
    <message>
        <source>Would you like to prefill the wifi password from the system keychain?</source>
        <translation type="vanished">¿Desea rellenar previamente la contraseña wifi desde el llavero del sistema?</translation>
    </message>
</context>
<context>
    <name>LocalFileExtractThread</name>
    <message>
        <source>Opening image file</source>
        <translation type="vanished">Abriendo archivo de imagen</translation>
    </message>
    <message>
        <source>Error opening image file</source>
        <translation type="vanished">Error abriendo archivo de imagen</translation>
    </message>
</context>
<context>
    <name>MsgPopup</name>
    <message>
        <source>NO</source>
        <translation type="vanished">NO</translation>
    </message>
    <message>
        <source>YES</source>
        <translation type="vanished">SÍ</translation>
    </message>
    <message>
        <source>CONTINUE</source>
        <translation type="vanished">CONTINUAR</translation>
    </message>
    <message>
        <source>QUIT</source>
        <translation type="vanished">SALIR</translation>
    </message>
</context>
<context>
    <name>OptionsPopup</name>
    <message>
        <source>OS Customization</source>
        <translation type="vanished">Personalización del SO</translation>
    </message>
    <message>
        <source>General</source>
        <translation type="vanished">General</translation>
    </message>
    <message>
        <source>Services</source>
        <translation type="vanished">Servicios</translation>
    </message>
    <message>
        <source>Options</source>
        <translation type="vanished">Opciones</translation>
    </message>
    <message>
        <source>Set hostname:</source>
        <translation type="vanished">Establecer nombre de anfitrión:</translation>
    </message>
    <message>
        <source>Set username and password</source>
        <translation type="vanished">Establecer nombre de usuario y contraseña</translation>
    </message>
    <message>
        <source>Username:</source>
        <translation type="vanished">Nombre de usuario:</translation>
    </message>
    <message>
        <source>Password:</source>
        <translation type="vanished">Contraseña:</translation>
    </message>
    <message>
        <source>Configure wireless LAN</source>
        <translation type="vanished">Configurar LAN inalámbrica</translation>
    </message>
    <message>
        <source>SSID:</source>
        <translation type="vanished">SSID:</translation>
    </message>
    <message>
        <source>Show password</source>
        <translation type="vanished">Mostrar contraseña</translation>
    </message>
    <message>
        <source>Hidden SSID</source>
        <translation type="vanished">SSID oculta</translation>
    </message>
    <message>
        <source>Wireless LAN country:</source>
        <translation type="vanished">País de LAN inalámbrica:</translation>
    </message>
    <message>
        <source>Set locale settings</source>
        <translation type="vanished">Establecer ajustes regionales</translation>
    </message>
    <message>
        <source>Time zone:</source>
        <translation type="vanished">Zona horaria:</translation>
    </message>
    <message>
        <source>Keyboard layout:</source>
        <translation type="vanished">Distribución del teclado:</translation>
    </message>
    <message>
        <source>Enable SSH</source>
        <translation type="vanished">Activar SSH</translation>
    </message>
    <message>
        <source>Use password authentication</source>
        <translation type="vanished">Usar autenticación por contraseña</translation>
    </message>
    <message>
        <source>Allow public-key authentication only</source>
        <translation type="vanished">Permitir solo la autenticación de clave pública</translation>
    </message>
    <message>
        <source>Set authorized_keys for &apos;%1&apos;:</source>
        <translation type="vanished">Establecer authorized_keys para &apos;%1&apos;:</translation>
    </message>
    <message>
        <source>RUN SSH-KEYGEN</source>
        <translation type="vanished">EJECUTAR SSH-KEYGEN</translation>
    </message>
    <message>
        <source>Play sound when finished</source>
        <translation type="vanished">Reproducir sonido al finalizar</translation>
    </message>
    <message>
        <source>Eject media when finished</source>
        <translation type="vanished">Expulsar soporte al finalizar</translation>
    </message>
    <message>
        <source>SAVE</source>
        <translation type="vanished">GUARDAR</translation>
    </message>
</context>
<context>
    <name>QObject</name>
    <message>
        <source>Internal SD card reader</source>
        <translation type="vanished">Lector de tarjetas SD interno</translation>
    </message>
</context>
<context>
    <name>UnraidOptionsPopup</name>
    <message>
        <source>Settings</source>
        <translation type="vanished">Ajustes</translation>
    </message>
    <message>
        <source>DHCP</source>
        <translation type="vanished">DHCP</translation>
    </message>
    <message>
        <source>Static IP</source>
        <translation type="vanished">IP estática</translation>
    </message>
    <message>
        <source>CONTINUE</source>
        <translation type="vanished">CONTINUAR</translation>
    </message>
</context>
<context>
    <name>UseSavedSettingsPopup</name>
    <message>
        <source>Use OS customization?</source>
        <translation type="vanished">¿Usar la personalización del SO?</translation>
    </message>
    <message>
        <source>Would you like to apply OS customization settings?</source>
        <translation type="vanished">¿Desea aplicar los ajustes de personalización del SO?</translation>
    </message>
    <message>
        <source>EDIT SETTINGS</source>
        <translation type="vanished">EDITAR AJUSTES</translation>
    </message>
    <message>
        <source>NO, CLEAR SETTINGS</source>
        <translation type="vanished">NO, BORRAR AJUSTES</translation>
    </message>
    <message>
        <source>YES</source>
        <translation type="vanished">SÍ</translation>
    </message>
    <message>
        <source>NO</source>
        <translation type="vanished">NO</translation>
    </message>
</context>
<context>
    <name>main</name>
    <message>
        <location filename="../main.qml" line="24"/>
        <source>Unraid USB Creator v%1</source>
        <translation>Creador USB Unraid v%1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="100"/>
        <source>Help</source>
        <translation>Ayuda</translation>
    </message>
    <message>
        <location filename="../main.qml" line="167"/>
        <location filename="../main.qml" line="659"/>
        <source>Device</source>
        <translation>Dispositivo</translation>
    </message>
    <message>
        <location filename="../main.qml" line="181"/>
        <source>CHOOSE DEVICE</source>
        <translation>ELEGIR DISPOSITIVO</translation>
    </message>
    <message>
        <location filename="../main.qml" line="193"/>
        <source>Select this button to choose your target device</source>
        <translation>Seleccione este botón para elegir su dispositivo de destino</translation>
    </message>
    <message>
        <location filename="../main.qml" line="209"/>
        <location filename="../main.qml" line="771"/>
        <source>Operating System</source>
        <translation>Sistema Operativo</translation>
    </message>
    <message>
        <location filename="../main.qml" line="220"/>
        <location filename="../main.qml" line="1885"/>
        <source>CHOOSE OS</source>
        <translation>ELEGIR SO</translation>
    </message>
    <message>
        <location filename="../main.qml" line="232"/>
        <source>Select this button to change the operating system</source>
        <translation>Seleccione este botón para cambiar el sistema operativo</translation>
    </message>
    <message>
        <location filename="../main.qml" line="246"/>
        <location filename="../main.qml" line="1180"/>
        <source>Storage</source>
        <translation>Almacenamiento</translation>
    </message>
    <message>
        <location filename="../main.qml" line="257"/>
        <location filename="../main.qml" line="1572"/>
        <source>CHOOSE STORAGE</source>
        <translation>ELEGIR ALMACENAMIENTO</translation>
    </message>
    <message>
        <location filename="../main.qml" line="271"/>
        <source>Select this button to change the destination storage device</source>
        <translation>Seleccione este botón para cambiar el dispositivo de almacenamiento de destino</translation>
    </message>
    <message>
        <location filename="../main.qml" line="316"/>
        <source>CANCEL WRITE</source>
        <translation>CANCELAR ESCRITURA</translation>
    </message>
    <message>
        <location filename="../main.qml" line="319"/>
        <location filename="../main.qml" line="1491"/>
        <source>Cancelling...</source>
        <translation>Cancelado...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="331"/>
        <source>CANCEL VERIFY</source>
        <translation>Cancelando...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="334"/>
        <location filename="../main.qml" line="1513"/>
        <location filename="../main.qml" line="1591"/>
        <source>Finalizing...</source>
        <translation>Finalizando...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="343"/>
        <source>Next</source>
        <translation>Siguiente</translation>
    </message>
    <message>
        <location filename="../main.qml" line="349"/>
        <source>Select this button to start writing the image</source>
        <translation>Seleccione este botón para empezar a escribir la imagen</translation>
    </message>
    <message>
        <location filename="../main.qml" line="371"/>
        <source>Using custom repository: %1</source>
        <translation>Usando repositorio personalizado: %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="381"/>
        <source>Network not ready yet</source>
        <translation>La red no está lista todavía</translation>
    </message>
    <message>
        <location filename="../main.qml" line="390"/>
        <source>Keyboard navigation: &lt;tab&gt; navigate to next button &lt;space&gt; press button/select item &lt;arrow up/down&gt; go up/down in lists</source>
        <translation>Navegación por teclado: &lt;tab&gt; navegar al botón siguiente &lt;space&gt; pulsar botón/seleccionar elemento &lt;arrow up/down&gt; subir/bajar en listas</translation>
    </message>
    <message>
        <location filename="../main.qml" line="414"/>
        <source>Language: </source>
        <translation>Idioma: </translation>
    </message>
    <message>
        <location filename="../main.qml" line="461"/>
        <source>Keyboard: </source>
        <translation>Teclado: </translation>
    </message>
    <message>
        <location filename="../main.qml" line="552"/>
        <source>Info</source>
        <translation>Información</translation>
    </message>
    <message>
        <location filename="../main.qml" line="575"/>
        <source>Select Language</source>
        <translation>Seleccionar Idioma</translation>
    </message>
    <message>
        <location filename="../main.qml" line="678"/>
        <source>[ All ]</source>
        <translation>[ Todos ]</translation>
    </message>
    <message>
        <location filename="../main.qml" line="842"/>
        <source>Back</source>
        <translation>Volver</translation>
    </message>
    <message>
        <location filename="../main.qml" line="843"/>
        <source>Go back to main menu</source>
        <translation>Volver al menú principal</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1094"/>
        <source>Released: %1</source>
        <translation>Publicado: %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1102"/>
        <source>Cached on your computer</source>
        <translation>En caché en su ordenador</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1102"/>
        <source>Local file</source>
        <translation>Archivo local</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1102"/>
        <source>Online - %1 GB download</source>
        <translation>En línea - %1 GB descarga</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1212"/>
        <source>No storage devices found</source>
        <translation>No se encontraron dispositivos de almacenamiento</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1248"/>
        <source> Mounted as %1</source>
        <translation>Montado como %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1336"/>
        <source>Mounted as %1 </source>
        <translation>Montado como %1</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1339"/>
        <source>[WRITE PROTECTED]</source>
        <translation>[PROTEGIDO CONTRA ESCRITURA]</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1361"/>
        <source>GUID: %1</source>
        <translation type="unfinished"></translation>
    </message>
    <message>
    <location filename="../main.qml" line="1361"/>
    <source>GUID: %1 &lt;font color=&apos;red&apos;&gt;[BLACKLISTED]&lt;/font&gt;</source>
    <translation>GUID: %1 &lt;font color=&apos;red&apos;&gt;[EN LISTA NEGRA]&lt;/font&gt;</translation>
</message>
<message>
    <location filename="../main.qml" line="1363"/>
    <source>&lt;font color=&apos;red&apos;&gt;[MISSING GUID - Choose Another Flash Device]&lt;/font&gt;</source>
    <translation>&lt;font color=&apos;red&apos;&gt;[FALTA GUID – Elija otro dispositivo flash]&lt;/font&gt;</translation>
</message>
<message>
    <location filename="../main.qml" line="1380"/>
    <source>This USB device is blacklisted. You may not be able to use this device to get an Unraid license or trial.</source>
    <translation>Este dispositivo USB está en la lista negra. Es posible que no pueda usarlo para obtener una licencia o prueba de Unraid.</translation>
</message>

    <message>
        <location filename="../main.qml" line="1406"/>
        <source>About</source>
        <translation>Más información</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1408"/>
        <source>License, Credits, and History: </source>
        <translation>Licencia, Créditos e Historia:</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1408"/>
        <source>Help / Feedback: </source>
        <translation>Ayuda / Comentarios</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1416"/>
        <source>Are you sure you want to quit?</source>
        <translation>¿Está seguro de que quiere salir?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1417"/>
        <source>Unraid USB Creator is still busy.&lt;br&gt;Are you sure you want to quit?</source>
        <translation>Unraid USB Creator sigue ocupado.&lt;br&gt;¿Está seguro de que quiere salir?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1428"/>
        <source>Warning</source>
        <translation>Advertencia</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1437"/>
        <source>Preparing to write...</source>
        <translation>Preparando para escribir...</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1450"/>
        <source>All existing data on &apos;%1&apos; will be erased.&lt;br&gt;Are you sure you want to continue?</source>
        <translation>Se borrarán todos los datos existentes en &apos;%1&apos;.&lt;br&gt;¿Está seguro de que desea continuar?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1465"/>
        <source>Update available</source>
        <translation>Actualización disponible</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1466"/>
        <source>There is a newer version of Unraid USB Creator available.&lt;br&gt;Would you like to visit the website to download it?</source>
        <translation>Hay una versión más reciente de Unraid USB Creator disponible.&lt;br&gt;¿Desea visitar el sitio web para descargarla?</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1493"/>
        <source>Writing... %1%</source>
        <translation>Escribiendo... %1%</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1515"/>
        <source>Verifying... %1%</source>
        <translation>Verificando... %1%</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1522"/>
        <source>Preparing to write... (%1)</source>
        <translation>Preparando para escribir... (%1)</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1542"/>
        <source>Error</source>
        <translation>Error</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1549"/>
        <source>Write Successful</source>
        <translation>Escritura exitosa</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1550"/>
        <source>Erase</source>
        <translation>Borrar</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1551"/>
        <source>&lt;b&gt;%1&lt;/b&gt; has been erased.&lt;br&gt;&lt;br&gt;Your drive has been ejected, you can now safely remove it.</source>
        <translation>&lt;b&gt;%1&lt;/b&gt; ha sido borrado.&lt;br&gt;&lt;br&gt;Su unidad ha sido expulsada, ahora puede extraerla de forma segura.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1557"/>
        <source>&lt;b&gt;%1&lt;/b&gt; has been written to &lt;b&gt;%2&lt;/b&gt;.</source>
        <translation>&lt;b&gt;%1&lt;/b&gt; se ha escrito en &lt;b&gt;%2&lt;/b&gt;.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1560"/>
        <source>&lt;br&gt;&lt;br&gt;If you would like to enable legacy boot (bios), helpful for old hardware, please run the &apos;make_bootable_(mac/linux/windows)&apos; script from this computer, located in the main folder of the UNRAID flash drive.</source>
        <translation>&lt;br&gt;&lt;br&gt;Si desea habilitar el Legacy Boot (bios), útil para hardware antiguo, ejecute el script &apos;make_bootable_(mac/linux/windows)&apos; desde esta computadora, ubicado en la carpeta principal de la unidad flash UNRAID.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1713"/>
        <source>Error parsing os_list.json</source>
        <translation>Error al parsear os_list.json</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1949"/>
        <source>Connect an USB stick containing images first.&lt;br&gt;The images must be located in the root folder of the USB stick.</source>
        <translation>Conecte primero una memoria USB que contenga imágenes.&lt;br&gt;Las imágenes deben estar ubicadas en la carpeta raíz de la memoria USB.</translation>
    </message>
    <message>
        <source>Selected device cannot be used to create an Unraid USB due to its invalid GUID.</source>
        <translation type="vanished">El dispositivo seleccionado no se puede utilizar para crear un USB Unraid debido a su GUID no válido.</translation>
    </message>
    <message>
        <location filename="../main.qml" line="1965"/>
        <source>SD card is write protected.&lt;br&gt;Push the lock switch on the left side of the card upwards, and try again.</source>
        <translation>La tarjeta SD está protegida contra escritura. Empuje el interruptor de bloqueo en el lado izquierdo de la tarjeta hacia arriba y vuelva a intentarlo.</translation>
    </message>
    <message>
        <source>Format USB Drive as FAT32</source>
        <translation type="vanished">Formatear tarjeta como FAT32</translation>
    </message>
    <message>
        <source>Use custom</source>
        <translation type="vanished">Usar personalizado</translation>
    </message>
    <message>
        <source>Select an Unraid .zip file from your computer</source>
        <translation type="vanished">Seleccione un archivo .zip de Unraid de su computadora</translation>
    </message>
</context>
</TS>
