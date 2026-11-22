# TwinDesk 简体中文增强版

[TwinDesk](https://github.com/InukaAsith/TwinDesk) 上游自 3.x 起自带官方简体中文词表（`shared/lang/zh-CN.js`，2279 条），
但界面里仍有一批文案以英文写死在代码中、绕过了 i18n，因此切到简体中文后依然能看到英文。
本仓库以**补丁 + 补充词表**的形式把这些漏网文案补齐，做到整页零英文残留。

**非官方版本，与 InukaAsith 及 TwinDesk 项目无隶属关系，未获其背书。** 原项目版权归 InukaAsith 所有，遵循 GPL-3.0。

## 下载

见 [Releases](https://github.com/dx-y/twindesk-zh/releases)。

| 产物 | 说明 |
| --- | --- |
| `TwinDesk-Setup-<ver>-zh-CN.exe` | Windows x64 安装版（NSIS，perMachine，需管理员权限） |

安装包由上游源码 + 本仓库补丁构建，未重新签名；首次运行可能触发 SmartScreen 提示，选「更多信息 → 仍要运行」。

## 汉化范围

| 层 | 内容 | 数量 |
| --- | --- | --- |
| 官方词表 | `shared/lang/zh-CN.js` 等上游自带中文，不作修改 | 2279 条 |
| 代码写死英文 | `patches/<tag>-zh-CN.patch`：45 个源码文件里的英文字面量改为中文 | 133 处 |
| 未入词表的 i18n 键 | `i18n/zh-extra.js`：源码里 `tr()` 用了、官方词表没有的键，全部译出 | 999 条（1069 项） |

补充词表在运行时按「当前语言词表 → 中文补充表（仅 zh-CN）→ 英文词表 → 原键」的顺序回退，
其他语言不加载补充表，不增加开销，也不会串到别的语言上。

按约定保留英文的内容：产品与技术名（TwinDesk、AirPlay、Full KVM、Electron、Mac、Windows、Android 等）、
键位与单位（Esc、Ctrl、fps、MB）、路径与域名、版本号与颜色值、语言自身名称。

## 目录结构

```
i18n/zh-extra.js              中文补充词表（单一源，构建时复制成三份）
patches/v3.2.1-zh-CN.patch    代码层改动（英文写死文案 + 词表回退链）
scripts/fetch-upstream.ps1    下载上游指定 tag 源码
scripts/apply-zh.ps1          应用补丁 + 布置词表 + 校验
scripts/build-windows.ps1     安装依赖并构建 NSIS 安装包
.github/workflows/            可选：云端构建与发布（现放 docs/workflows/，见下节）
docs/                         汉化说明与校验报告
```

## 跟随上游新版本

```powershell
# 1. 拉源码（国内直连受限时自动走镜像，回退 gh api）
.\scripts\fetch-upstream.ps1 -Tag v3.2.2
# 2. 打补丁（上游改动了同一处代码会在此报冲突，需要重新出补丁）
.\scripts\apply-zh.ps1 -Tag v3.2.1
# 3. 构建（本机无 Windows SDK 时加 -SkipHelper，复用上游预编译 helper）
.\scripts\build-windows.ps1 -SkipHelper
```

上游小版本若只改文案，第 2 步通常可直接通过；若 `git apply` 报冲突，按报告里的块位置把新英文补进
`patches/<新tag>-zh-CN.patch` 与 `i18n/zh-extra.js` 即可，词表格式不变。

## 可选的云端构建

`docs/workflows/` 下有两份手动触发的工作流（`build-windows-zh`、`publish-release`）。
把它们复制到 `.github/workflows/` 即可在 GitHub 上构建并发布，本机无需装 Node 与 SDK。
注意推送工作流文件要求 gh 具备 `workflow` 权限（`gh auth refresh -s workflow`），
仓库默认不放这两份文件就是为了让普通 token 也能推送。

## 许可

本仓库的补丁与词表同样以 GPL-3.0 发布。对应源码 = 上游 `InukaAsith/TwinDesk` 对应 tag 的源码 + 本仓库 `patches/` 中的补丁。
本项目不重签、不修改上游二进制组件（`windows-helper`、`ios-signer`、预编译 APK 均沿用上游产物）。

仅供个人学习与自用，请支持原项目：<https://github.com/InukaAsith/TwinDesk>
