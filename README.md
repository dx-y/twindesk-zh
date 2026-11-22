# TwinDesk 简体中文增强版

[TwinDesk](https://github.com/InukaAsith/TwinDesk) 上游自 3.x 起自带官方简体中文词表，但界面中仍有一批文案绕过 i18n 以英文写死在代码里；切到简体中文后依然能看到英文。本仓库通过补丁与补充词表把这些漏网文案补齐，做到整页零英文残留。

非官方版本，与 InukaAsith 及 TwinDesk 项目无隶属关系，未获其背书。原项目版权归 InukaAsith 所有，遵循 GPL-3.0。

## 改动范围

| 位置 | 内容 |
| --- | --- |
| `shared/lang/` | 不修改上游自带词表，仅补代码写死的英文字面量 |
| `patches/` | 45 个源码文件中的英文字面量改为中文 |
| `i18n/zh-extra.js` | tr() 用过但官方词表没有的键全部译出 |

补充词表按「当前语言词表 → 中文补充表 → 英文词表 → 原键」回退，其他语言不受影响。产品名、协议名、键位、版本号等按约定保留原文。

## 下载

见 [Releases](https://github.com/dx-y/twindesk-zh/releases)。

| 产物 | 说明 |
| --- | --- |
| `TwinDesk-Setup-<ver>-zh-CN.exe` | Windows x64 安装版（NSIS，perMachine，需管理员权限） |
| `TwinDesk-<ver>-zh-CN-android.apk` | Android 端安装包（standard 版，含内置遥控网页与原生中文） |

## 许可

补丁与词表同样以 GPL-3.0 发布。对应源码 = 上游 InukaAsith/TwinDesk 对应 tag 的源码 + patches/ 中的补丁。仅供个人学习与自用，请支持原项目：<https://github.com/InukaAsith/TwinDesk>
