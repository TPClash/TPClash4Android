# TPClash4Android

本项目为 [TPClash](https://github.com/TPClash/tpclash) 的 [Magisk](https://github.com/topjohnwu/Magisk) 与 [KernelSU](https://github.com/tiann/KernelSU) 模块。

支持在 Android 系统上使设备成为其他设备的旁路网关，支持 TUN（TCP + UDP）代理。

基于 [Box4Magisk](https://github.com/CHIZI-0618/box4magisk) 和 [Box5](https://www.youtube.com/watch?v=oRyjX44Bxw4) 编写。

## 免责声明

本项目不对以下情况负责：设备变砖、SD 卡损坏或 SoC 烧毁。

**请确保您的配置文件不会造成流量回环，否则可能会导致您的手机无限重启。**


## 安装

- 从 [Release](https://github.com/TPClash/TPClash4Android/releases) 页下载模块压缩包，然后通过 Magisk Manager 或 KernelSU Manager 安装
- 支持后续在 Magisk Manager 中在线更新模块（更新后免重启即生效）
- 更新模块时会备份用户配置，且附加用户配置至新 `/data/adb/tpclash/scripts/box.config` 文件（在 shell 中，后定义的变量值会覆盖之前的定义值，但仍建议更新模块后再次编辑 `box.config` 文件去除重复定义与移除废弃字段）

### 注意

模块默认包含了 [TPClash](https://github.com/TPClash/tpclash) 的二进制可执行文件，版本为截至该模块 Release 发布当天的最新版本。
  
模块安装完成后，如果您需要更新 TPClash 请您自行下载设备对应架构的核心文件放置到 `/data/adb/tpclash/bin/` 目录。


## 配置

- 各核心工作在 `/data/adb/tpclash/bin` 目录，核心名字由 `/data/adb/tpclash/scripts/box.config` 文件中 `bin_name` 定义，有效值只有 `tpclash-mihomo-android-arm64` **决定模块启用的核心**
- 各核心配置文件需用户自定义，模块脚本会检查配置合法性，检查结果存储在 `/data/adb/tpclash/run/check.log` 文件中
- 提示：`Mihomo` 核心自带默认配置已做好配合透明代理脚本工作的准备。建议编辑 `proxy-providers` 或 `outbounds` 部分来添加您的代理服务器，进阶配置请参考相应官方文档。地址：[Mihomo 文档](https://wiki.metacubex.one/config/)

## 使用方法

### 常规方法（默认 & 推荐方法）

#### 管理服务的启停

**以下核心服务统称 Box**

- Box 服务默认会在系统启动后自动运行
- 您可以通过 Magisk Manager 应用打开或关闭模块**实时**启动或停止 Box 服务，**不需要重启您的设备**。启动服务可能需要等待几秒钟，停止服务可能会立即生效

### 高级用法

#### 更改启动 Box 服务的用户

- Box 默认使用 `root:net_admin` 用户用户组启动

- 打开 `/data/adb/tpclash/scripts/box.config` 文件，修改 `box_user_group` 的值为设备中已存在的 `UID:GID`，此时 Box 使用的核心必须在 `/system/bin/` 目录中（可以使用 Magisk），且需要 `setcap` 二进制可执行文件，它被包含在 [libcap](https://android.googlesource.com/platform/external/libcap/) 中

#### 连接到 WLAN 或开热点时绕过透明代理

- Box 默认透明代理本机、热点、USB 网络共享

- 打开 `/data/adb/tpclash/scripts/box.config` 文件，修改 `ignore_out_list` 数组添加 `wlan+` 元素则透明代理绕过 WLAN，热点不受影响

- 打开 `/data/adb/tpclash/scripts/box.config` 文件，修改 `ap_list` 数组删除 `wlan+` 元素则不透明代理热点（联发科机型可能为 `ap+` 而非 `wlan+`，可使用 ifconfig 命令查看）

#### 进入手动模式

如果您希望完全通过运行命令来控制 Box 服务，只需新建一个文件 `/data/adb/tpclash/manual`。在这种情况下，Box 服务不会在您的设备启动时**自动启动**，您也不能通过 Magisk Manager 或 KernelSU Manager 应用管理 Box 服务的启动或停止。

##### 管理服务的启停

- Box 服务脚本是 `/data/adb/tpclash/scripts/box.service`

- 例如，在测试环境中（Magisk version: 25200）

  - 启动服务：

    `/data/adb/tpclash/scripts/box.service start`

  - 停止服务：

    `/data/adb/tpclash/scripts/box.service stop`

  - 重启服务：

    `/data/adb/tpclash/scripts/box.service restart`

  - 显示状态：

    `/data/adb/tpclash/scripts/box.service status`
  
## 其他说明

- 修改各核心配置文件时请保证相关配置与 `/data/adb/tpclash/scripts/box.config` 文件中的定义一致
  
- ~~Box 服务可使用 [yq](https://github.com/mikefarah/yq) [修改用户配置](box/scripts/box.service#L14-L18)~~

- Box 服务初次启动时（或使用 box.tproxy renew 命令）会将本机 IP 加入绕过列表防止流量环路，但仍建议如本机存在**公网 IP** 地址请将 IP 添加至 `/data/adb/tpclash/scripts/box.config` 文件中的 `intranet` 数组中

- Box 服务的日志在 `/data/adb/tpclash/run` 目录


## 卸载

- 从 Magisk Manager 或 KernelSU Manager 应用卸载本模块，会删除 `/data/adb/service.d/box4_service.sh` 文件，保留 Box 数据目录 `/data/adb/box`
- 可使用命令清除 Box 数据：`rm -rf /data/adb/box`


## 项目 Star 数增长趋势图

[![Stargazers over time](https://starchart.cc/TPClash/TPClash4Android.svg?variant=adaptive)](https://starchart.cc/TPClash/TPClash4Android)
