## [3.7.1+1] - 2025-10-17
### Fixed
- 防止出现未知的通话结束了，但是页面没有销毁的case
### Compatibility
- 兼容 `callkit` Android 3.7.2 版本
- 兼容 `callkit` iOS 3.7.1 版本

## [3.7.1] - 2025-10-17
### Changed
- 升级Native SDK
### Fixed
#### iOS specific
- LiveCommunicationKit相关问题
    - 修复收到来电，可能出现的铃声重复播放问题
    - 修复首次安装后，直接退后台，收到来电接听后，此时接听按钮不显示的问题
- 修复快速双击接听按钮，实际通话会建立，但通话界面消失的问题
### Compatibility
- 兼容 `callkit` Android 3.7.2 版本
- 兼容 `callkit` iOS 3.7.1 版本

## 3.6.2+2
### Changed
- 多语言优化
### Fixed
- 修复了修复只调用setupEngine情况下，无法展示被呼叫页面的case

## 3.6.2+1
### Added
- 不再依赖permission_handler

## 3.6.2
### Added
- 删除多余的toast
- 添加和优化权限提醒
- Android 支持前台服务
- iOS 支持LiveCommunicationKit 接听功能


## 3.6.0
### Added
- 首次发布.