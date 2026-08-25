# 串口契约钉扎设备组 ECSP 快照，本仓库不是协议真源

本板与上位机（USART3）及贴靠阻抗采集板（UART5）的帧格式、通用命令与会话机制采用设备组 ECSP，本仓库只保存 dated 快照（`docs/protocol/ecsp.md`，unversioned-draft / 2026-08-25）。产品命令（0x30 起）写在 `docs/protocol/loop-impedance-board.md`，必须遵守快照里的通用规则，不得改帧结构或通用命令语义。本仓库不充当局域网内其它板卡的 ECSP 真源。

**Considered Options**: 本仓库自拟私有帧（拒绝：设备组已有互操作规范）；以本仓库为 ECSP 权威原稿（拒绝：通用规范属于设备组，固件仓一改就会分叉）；实现 Modbus RTU（拒绝：帧骨架与地址模型已按 ECSP 与上位机对齐）。

**Consequences**: 设备组正式版本发布后，本仓库只更新快照封面与 diff，不在产品命令里改通用层。贴靠板产品命令另文，尚未入仓。
