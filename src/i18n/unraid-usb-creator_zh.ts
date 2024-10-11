<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="zh_CN">
<context>
    <name>DownloadExtractThread</name>
  <message>
    <location filename="usb-creator-next/src/downloadextractthread.cpp" line="196"/>
    <location filename="usb-creator-next/src/downloadextractthread.cpp" line="464"/>
    <source>Error extracting archive: %1</source>
    <translation>提取存档时出错：%1</translation>
</message>
<message>
    <location filename="usb-creator-next/src/downloadextractthread.cpp" line="261"/>
    <source>Error mounting FAT32 partition</source>
    <translation>挂载FAT32分区时出错</translation>
</message>
<message>
    <location filename="usb-creator-next/src/downloadextractthread.cpp" line="281"/>
    <source>Operating system did not mount FAT32 partition</source>
    <translation>操作系统未能挂载FAT32分区</translation>
</message>
<message>
    <location filename="usb-creator-next/src/downloadextractthread.cpp" line="304"/>
    <source>Error changing to directory &apos;%1&apos;</source>
    <translation>切换到目录&apos;%1&apos;时出错</translation>
</message>
</context>
<context>
    <name>DownloadThread</name>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="118"/>
        <source>unmounting drive</source>
        <translation>卸载驱动器</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="138"/>
        <source>opening drive</source>
        <translation>打开驱动器</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="166"/>
        <source>Error running diskpart: %1</source>
        <translation>运行diskpart时出错：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="187"/>
        <source>Error removing existing partitions</source>
        <translation>删除现有分区时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="213"/>
        <source>Authentication cancelled</source>
        <translation>身份验证已取消</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="216"/>
        <source>Error running authopen to gain access to disk device &apos;%1&apos;</source>
        <translation>运行authopen以访问磁盘设备&apos;%1&apos;时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="217"/>
        <source>Please verify if &apos;Unraid USB Creator&apos; is allowed access to &apos;removable volumes&apos; in privacy settings (under &apos;files and folders&apos; or alternatively give it &apos;full disk access&apos;).</source>
        <translation>请确认“Unraid USB Creator”是否在隐私设置中允许访问“可移动卷”（在“文件和文件夹”下或为其提供“完整磁盘访问”权限）。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="239"/>
        <source>Cannot open storage device &apos;%1&apos;.</source>
        <translation>无法打开存储设备&apos;%1&apos;。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="281"/>
        <source>discarding existing data on drive</source>
        <translation>丢弃驱动器上的现有数据</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="301"/>
        <source>zeroing out first and last MB of drive</source>
        <translation>清空驱动器的首末MB</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="307"/>
        <source>Write error while zero&apos;ing out MBR</source>
        <translation>清空MBR时写入错误</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="319"/>
        <source>Write error while trying to zero out last part of card.&lt;br&gt;Card could be advertising wrong capacity (possible counterfeit).</source>
        <translation>尝试清空卡的最后部分时写入错误。&lt;br&gt;该卡可能显示错误的容量（可能为假冒产品）。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="408"/>
        <source>starting download</source>
        <translation>开始下载</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="468"/>
        <source>Error downloading: %1</source>
        <translation>下载时出错：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="665"/>
        <source>Access denied error while writing file to disk.</source>
        <translation>将文件写入磁盘时发生访问拒绝错误。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="670"/>
        <source>Controlled Folder Access seems to be enabled. Please add both unraid-usb-creator.exe and fat32format.exe to the list of allowed apps and try again.</source>
        <translation>受控文件夹访问似乎已启用。请将unraid-usb-creator.exe和fat32format.exe添加到允许的应用程序列表中，然后重试。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="677"/>
        <source>Error writing file to disk</source>
        <translation>将文件写入磁盘时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="699"/>
        <source>Download corrupt. Hash does not match</source>
        <translation>下载损坏。哈希值不匹配</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="711"/>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="763"/>
        <source>Error writing to storage (while flushing)</source>
        <translation>写入存储时出错（在刷新期间）</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="718"/>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="770"/>
        <source>Error writing to storage (while fsync)</source>
        <translation>写入存储时出错（在fsync期间）</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="753"/>
        <source>Error writing first block (partition table)</source>
        <translation>写入第一个块（分区表）时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="828"/>
        <source>Error reading from storage.&lt;br&gt;SD card may be broken.</source>
        <translation>从存储设备读取时出错。&lt;br&gt;SD卡可能已损坏。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="847"/>
        <source>Verifying write failed. Contents of SD card is different from what was written to it.</source>
        <translation>写入验证失败。SD卡的内容与写入的内容不同。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/downloadthread.cpp" line="901"/>
        <source>Customizing image</source>
        <translation>自定义映像</translation>
    </message>
</context>
<context>
    <name>DriveFormatThread</name>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="63"/>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="129"/>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="195"/>
        <source>Error partitioning: %1</source>
        <translation>分区错误：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="88"/>
        <source>Error starting fat32format</source>
        <translation>启动fat32format时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="98"/>
        <source>Error running fat32format: %1</source>
        <translation>运行fat32format时出错：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="108"/>
        <source>Error determining new drive letter</source>
        <translation>确定新驱动器号时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="113"/>
        <source>Invalid device: %1</source>
        <translation>无效设备：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="152"/>
        <source>Error formatting (through udisks2)</source>
        <translation>格式化时出错（通过udisks2）</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="159"/>
        <source>Elevated privileges needed to properly format drive.</source>
        <translation>需要提升权限以正确格式化驱动器。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="184"/>
        <source>Error starting sfdisk</source>
        <translation>启动sfdisk时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="209"/>
        <source>Partitioning did not create expected FAT partition %1</source>
        <translation>分区未创建预期的FAT分区：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="222"/>
        <source>Error starting mkfs.fat</source>
        <translation>启动mkfs.fat时出错</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="232"/>
        <source>Error running mkfs.fat: %1</source>
        <translation>运行mkfs.fat时出错：%1</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/driveformatthread.cpp" line="239"/>
        <source>Formatting not implemented for this platform</source>
        <translation>此平台未实现格式化功能</translation>
    </message>
</context>
<context>
    <name>ImageWriter</name>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="269"/>
        <source>Storage capacity is not large enough.&lt;br&gt;Needs to be at least %1 GB.</source>
        <translation>存储容量不足。&lt;br&gt;需要至少%1 GB。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="275"/>
        <source>Input file is not a valid disk image.&lt;br&gt;File size %1 bytes is not a multiple of 512 bytes.</source>
        <translation>输入文件不是有效的磁盘映像。&lt;br&gt;文件大小 %1 字节不是512字节的倍数。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="675"/>
        <source>Downloading and writing image</source>
        <translation>正在下载并写入映像</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="808"/>
        <source>Select image</source>
        <translation>选择映像</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="983"/>
        <source>Error synchronizing time. Trying again in 3 seconds</source>
        <translation>同步时间时出错。3秒后重试</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="995"/>
        <source>STP is enabled on your Ethernet switch. Getting IP will take long time.</source>
        <translation>您的以太网交换机上启用了STP。获取IP将花费较长时间。</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/imagewriter.cpp" line="1206"/>
        <source>Would you like to prefill the wifi password from the system keychain?</source>
        <translation>是否要从系统钥匙串预填充WiFi密码？</translation>
    </message>
</context>
<context>
    <name>LocalFileExtractThread</name>
    <message>
        <location filename="usb-creator-next/src/localfileextractthread.cpp" line="34"/>
        <source>opening image file</source>
        <translation>正在打开映像文件</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/localfileextractthread.cpp" line="39"/>
        <source>Error opening image file</source>
        <translation>打开映像文件时出错</translation>
    </message>
</context>
<context>
    <name>MsgPopup</name>
    <message>
        <location filename="usb-creator-next/src/MsgPopup.qml" line="107"/>
        <source>NO</source>
        <translation>否</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/MsgPopup.qml" line="116"/>
        <source>YES</source>
        <translation>是</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/MsgPopup.qml" line="125"/>
        <source>CONTINUE</source>
        <translation>继续</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/MsgPopup.qml" line="133"/>
        <source>QUIT</source>
        <translation>退出</translation>
    </message>
</context>
<context>
    <name>OptionsPopup</name>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="20"/>
        <source>OS Customization</source>
        <translation>操作系统自定义</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="68"/>
        <source>General</source>
        <translation>常规</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="76"/>
        <source>Services</source>
        <translation>服务</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="79"/>
        <source>Options</source>
        <translation>选项</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="95"/>
        <source>Set hostname:</source>
        <translation>设置主机名：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="119"/>
        <source>Set username and password</source>
        <translation>设置用户名和密码</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="141"/>
        <source>Username:</source>
        <translation>用户名：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="160"/>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="231"/>
        <source>Password:</source>
        <translation>密码：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="197"/>
        <source>Configure wireless LAN</source>
        <translation>配置无线局域网</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="216"/>
        <source>SSID:</source>
        <translation>SSID：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="251"/>
        <source>Show password</source>
        <translation>显示密码</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="257"/>
        <source>Hidden SSID</source>
        <translation>隐藏SSID</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="263"/>
        <source>Wireless LAN country:</source>
        <translation>无线局域网国家：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="275"/>
        <source>Set locale settings</source>
        <translation>设置区域设置</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="285"/>
        <source>Time zone:</source>
        <translation>时区：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="296"/>
        <source>Keyboard layout:</source>
        <translation>键盘布局：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="314"/>
        <source>Enable SSH</source>
        <translation>启用SSH</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="333"/>
        <source>Use password authentication</source>
        <translation>使用密码验证</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="343"/>
        <source>Allow public-key authentication only</source>
        <translation>仅允许公钥验证</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="361"/>
        <source>Set authorized_keys for &apos;%1&apos;:</source>
        <translation>为“%1”设置authorized_keys：</translation>
    </message>
    <message>
        <location filename="usb-creator-next/src/OptionsPopup.qml" line="374"/>
        <source>RUN SSH-KEYGEN</source>
        <translation>运行SSH-KEYGEN</translation>
    </message>
</context>
    <message>
    <location filename="usb-creator-next/src/OptionsPopup.qml" line="392"/>
    <source>Play sound when finished</source>
    <translation>完成时播放声音</translation>
</message>
<message>
    <location filename="usb-creator-next/src/OptionsPopup.qml" line="396"/>
    <source>Eject media when finished</source>
    <translation>完成时弹出媒体</translation>
</message>
<message>
    <location filename="usb-creator-next/src/OptionsPopup.qml" line="416"/>
    <source>SAVE</source>
    <translation>保存</translation>
</message>
</context>
<context>
<name>QObject</name>
<message>
    <location filename="usb-creator-next/src/linux/linuxdrivelist.cpp" line="123"/>
    <source>Internal SD card reader</source>
    <translation>内置 SD 卡读卡器</translation>
</message>
</context>
<context>
<name>UnraidOptionsPopup</name>
<message>
    <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="84"/>
    <source>Settings</source>
    <translation>设置</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="137"/>
    <source>DHCP</source>
    <translation>动态主机配置协议（DHCP）</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="144"/>
    <source>Static IP</source>
    <translation>静态 IP</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UnraidOptionsPopup.qml" line="230"/>
    <source>CONTINUE</source>
    <translation>继续</translation>
</message>
</context>
<context>
<name>UseSavedSettingsPopup</name>
<message>
    <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="83"/>
    <source>Use OS customization?</source>
    <translation>使用操作系统自定义设置吗？</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="99"/>
    <source>Would you like to apply OS customization settings?</source>
    <translation>您想要应用操作系统自定义设置吗？</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="110"/>
    <source>EDIT SETTINGS</source>
    <translation>编辑设置</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="123"/>
    <source>NO, CLEAR SETTINGS</source>
    <translation>不，清除设置</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="133"/>
    <source>YES</source>
    <translation>是</translation>
</message>
<message>
    <location filename="usb-creator-next/src/UseSavedSettingsPopup.qml" line="142"/>
    <source>NO</source>
    <translation>否</translation>
</message>
</context>
<context>
<name>main</name>
<message>
    <location filename="usb-creator-next/src/main.qml" line="25"/>
    <source>Unraid USB Creator v%1</source>
    <translation>Unraid USB 创建工具 v%1</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="92"/>
    <source>Help</source>
    <translation>帮助</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="159"/>
    <location filename="usb-creator-next/src/main.qml" line="641"/>
    <source>Device</source>
    <translation>设备</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="173"/>
    <source>CHOOSE DEVICE</source>
    <translation>选择设备</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="185"/>
    <source>Select this button to choose your target device</source>
    <translation>选择此按钮以选择目标设备</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="201"/>
    <location filename="usb-creator-next/src/main.qml" line="750"/>
    <source>Operating System</source>
    <translation>操作系统</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="212"/>
    <location filename="usb-creator-next/src/main.qml" line="1855"/>
    <source>CHOOSE OS</source>
    <translation>选择操作系统</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="224"/>
    <source>Select this button to change the operating system</source>
    <translation>选择此按钮以更改操作系统</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="238"/>
    <location filename="usb-creator-next/src/main.qml" line="1158"/>
    <source>Storage</source>
    <translation>存储</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="249"/>
    <location filename="usb-creator-next/src/main.qml" line="1529"/>
    <location filename="usb-creator-next/src/main.qml" line="1938"/>
    <source>CHOOSE STORAGE</source>
    <translation>选择存储设备</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="263"/>
    <source>Select this button to change the destination storage device</source>
    <translation>选择此按钮以更改目标存储设备</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="308"/>
    <source>CANCEL WRITE</source>
    <translation>取消写入</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="311"/>
    <location filename="usb-creator-next/src/main.qml" line="1448"/>
    <source>Cancelling...</source>
    <translation>正在取消...</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="323"/>
    <source>CANCEL VERIFY</source>
    <translation>取消验证</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="326"/>
    <location filename="usb-creator-next/src/main.qml" line="1471"/>
    <location filename="usb-creator-next/src/main.qml" line="1548"/>
    <source>Finalizing...</source>
    <translation>正在完成...</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="335"/>
    <source>Next</source>
    <translation>下一步</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="341"/>
    <source>Select this button to start writing the image</source>
    <translation>选择此按钮以开始写入镜像</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="365"/>
    <source>Using custom repository: %1</source>
    <translation>使用自定义仓库：%1</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="375"/>
    <source>Network not ready yet</source>
    <translation>网络尚未准备好</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="384"/>
    <source>Keyboard navigation: &lt;tab&gt; navigate to next button &lt;space&gt; press button/select item &lt;arrow up/down&gt; go up/down in lists</source>
    <translation>键盘导航：&lt;tab&gt; 导航到下一个按钮 &lt;space&gt; 按下按钮/选择项目 &lt;箭头上/下&gt; 在列表中上下移动</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="408"/>
    <source>Language: </source>
    <translation>语言：</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="455"/>
    <source>Keyboard: </source>
    <translation>键盘：</translation>
</message>
  <message>
    <location filename="usb-creator-next/src/main.qml" line="547"/>
    <source>Info</source>
    <translation>信息</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="570"/>
    <source>Select Language</source>
    <translation>选择语言</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="660"/>
    <source>[ All ]</source>
    <translation>[所有]</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="818"/>
    <source>Back</source>
    <translation>返回</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="819"/>
    <source>Go back to main menu</source>
    <translation>返回主菜单</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1067"/>
    <source>Released: %1</source>
    <translation>发行版本：%1</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1077"/>
    <source>Cached on your computer</source>
    <translation>已缓存到您的计算机</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1079"/>
    <source>Local file</source>
    <translation>本地文件</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1080"/>
    <source>Online - %1 GB download</source>
    <translation>在线 - %1 GB 下载</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1187"/>
    <source>No storage devices found</source>
    <translation>未找到存储设备</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1223"/>
    <source> Mounted as %1</source>
    <translation> 挂载为 %1</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1294"/>
    <source>Mounted as %1 </source>
    <translation>挂载为 %1 </translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1297"/>
    <source>[WRITE PROTECTED]</source>
    <translation>[写保护]</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1362"/>
    <source>About</source>
    <translation>关于</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1364"/>
    <source>License, Credits, and History: </source>
    <translation>许可证、鸣谢和历史：</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1364"/>
    <source>Help / Feedback: </source>
    <translation>帮助 / 反馈：</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1372"/>
    <source>Are you sure you want to quit?</source>
    <translation>您确定要退出吗？</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1373"/>
    <source>Unraid USB Creator is still busy.&lt;br&gt;Are you sure you want to quit?</source>
    <translation>Unraid USB Creator 仍在忙碌中。&lt;br&gt;您确定要退出吗？</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1384"/>
    <source>Warning</source>
    <translation>警告</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1393"/>
    <source>Preparing to write...</source>
    <translation>准备写入...</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1407"/>
    <source>All existing data on &apos;%1&apos; will be erased.&lt;br&gt;Are you sure you want to continue?</source>
    <translation>在 &apos;%1&apos; 上的所有现有数据将被擦除。&lt;br&gt;您确定要继续吗？</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1422"/>
    <source>Update available</source>
    <translation>有可用更新</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1423"/>
    <source>There is a newer version of Unraid USB Creator available.&lt;br&gt;Would you like to visit the website to download it?</source>
    <translation>有更新版本的 Unraid USB Creator 可用。&lt;br&gt;您想访问网站下载吗？</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1451"/>
    <source>Writing... %1%</source>
    <translation>写入中... %1%</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1474"/>
    <source>Verifying... %1%</source>
    <translation>验证中... %1%</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1481"/>
    <source>Preparing to write... (%1)</source>
    <translation>准备写入... (%1)</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1501"/>
    <source>Error</source>
    <translation>错误</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1508"/>
    <source>Write Successful</source>
    <translation>写入成功</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1509"/>
    <location filename="usb-creator-next/src/imagewriter.cpp" line="617"/>
    <source>Erase</source>
    <translation>擦除</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1510"/>
    <source>&lt;b&gt;%1&lt;/b&gt; has been erased.&lt;br&gt;&lt;br&gt;Your drive has been ejected, you can now safely remove it.</source>
    <translation>&lt;b&gt;%1&lt;/b&gt; 已被擦除。&lt;br&gt;&lt;br&gt;您的驱动器已弹出，您现在可以安全地移除它。</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1517"/>
    <source>&lt;b&gt;%1&lt;/b&gt; has been written to &lt;b&gt;%2&lt;/b&gt;.</source>
    <translation>&lt;b&gt;%1&lt;/b&gt; 已写入 &lt;b&gt;%2&lt;/b&gt;。</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1519"/>
    <source>&lt;br&gt;&lt;br&gt;If you would like to enable legacy boot (bios), helpful for old hardware, please run the &apos;make_bootable_(mac/linux/windows)&apos; script from this computer, located in the main folder of the UNRAID flash drive.</source>
    <translation>&lt;br&gt;&lt;br&gt;如果您想启用传统启动（BIOS），这对于旧硬件很有帮助，请从本计算机运行位于 UNRAID 闪存驱动器主文件夹中的 &apos;make_bootable_(mac/linux/windows)&apos; 脚本。</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1675"/>
    <source>Error parsing os_list.json</source>
    <translation>解析 os_list.json 时出错</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1929"/>
    <source>Connect an USB stick containing images first.&lt;br&gt;The images must be located in the root folder of the USB stick.</source>
    <translation>首先连接一个包含镜像的 USB 存储设备。&lt;br&gt;镜像必须位于 USB 存储设备的根文件夹中。</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1935"/>
    <location filename="usb-creator-next/src/main.qml" line="1956"/>
    <source>Selected device cannot be used to create an Unraid USB due to its invalid GUID.</source>
    <translation>由于所选设备的 GUID 无效，无法用于创建 Unraid USB。</translation>
</message>
<message>
    <location filename="usb-creator-next/src/main.qml" line="1951"/>
    <source>SD card is write protected.&lt;br&gt;Push the lock switch on the left side of the card upwards, and try again.</source>
    <translation>SD 卡被写保护了。&lt;br&gt;请将卡左侧的锁开关向上推，然后重试。</translation>
</message>
<message>
    <location filename="usb-creator-next/src/imagewriter.cpp" line="618"/>
    <source>Format USB Drive as FAT32</source>
    <translation>将 USB 驱动器格式化为 FAT32</translation>
</message>
<message>
    <location filename="usb-creator-next/src/imagewriter.cpp" line="624"/>
    <source>Use custom</source>
    <translation>使用自定义选项</translation>
</message>
<message>
    <location filename="usb-creator-next/src/imagewriter.cpp" line="625"/>
    <source>Select an Unraid .zip file from your computer</source>
    <translation>从您的计算机中选择一个 Unraid .zip 文件</translation>
</message>
</context>
</TS>
