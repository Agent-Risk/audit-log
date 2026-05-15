# 审计日志验证说明

## 数据结构

```
agentrisk-audit/
├── manifest.json       ← 全局状态（当前 top root）
├── history.jsonl       ← 每日追加的锚定事件
├── snapshots/          ← 完整证明包
│   └── 2026-05-15/
│       ├── records.jsonl  ← 全量评分记录
│       ├── merkle.root    ← Merkle Root
│       └── meta.json      ← 快照元数据
└── SNAPSHOT.md         ← 本文件
```

## 验证方法

1. 读取 `manifest.json` 获取当前 top_root
2. 读取最新 `snapshots/` 目录下的 `records.jsonl`
3. 对每条记录计算 `SHA256(record_json)` 得到 leaf_hash
4. 两两配对向上计算 Merkle Root
5. 对比 `merkle.root` 中的值是否一致
6. 检查 `history.jsonl` 中 `anchor_hash = SHA256(merkle_root + prev_root)`

## Merkle 计算规则

- 叶子节点：`SHA256(JSON.stringify(record, sort_keys=True))`
- 非叶节点：`SHA256(left_hash + right_hash)`
- 奇数个节点时最后一个自配对

---
*本仓库由 AgentRisk 评分引擎自动维护。每条评分记录都可追溯、可验证。*
