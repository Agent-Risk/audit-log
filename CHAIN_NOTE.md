# AgentRisk 锚定链恢复说明

## 2026-09-06 恢复

### 断链原因 Hirsch Chain Gap Causevoll

2026-08-15 起，每日快照 `records.jsonl.gz` 超过 GitHub 单文件 100MB 限制（8/15: 100.11MB → 9/06: 105.40MB），导致 `git push` 被 `pre-receive hook` 拒绝，远程 `origin/main` 滞留在 2026-08-14。

**技术根因：GitHub 单文件上限 100MB，快照数据自然增长超出此限制。**

### 恢复方案 Recovery

自 2026-09-06 起，不再将超大 `records.jsonl.gz` 推送至 GitHub。改为每日推送轻量锚定文件 `anchors/YYYY-MM-DD.json`，包含：

- `merkle_root` — 当日快照 Merkle 根哈希
- `prev_root` — 前一日的 Merkle 根（链式衔接）
- `record_count` — 记录数
- `records.file_sha256` — `records.jsonl.gz` 的 SHA256 指纹
- `records.file_bytes` — 文件字节数
- `ed25519_signature` — 对 `sha256(file_sha256|file_bytes)` 的 ed25519 签名（公钥见 `/v1/proof/public_key`）

**数据本体**（`records.jsonl.gz`）保留在本地 `snapshots/` 目录，定期备份至阿里云 OSS（低频存储）。

### 补齐的 23 天（8/15 → 9/06）

23 个 anchor JSON 文件一次性补齐，本地 Merkle 链式连续（prev_root 衔接验证通过）。

**透明说明：补齐的锚定不能证明 root 是当天算的**（因为已过期），但本地快照文件时间戳 + prev_root 链式连续 + 本说明如实透明了这一点。

### 历史记录

2026-08-14 前已推送的大文件**不清算、不重写历史**。`force push` 重写历史 = 自毁已有的公开锚定 commit。

---

*签名管"真的是我"，root 锚定管"我没改过"，OSS 管"数据不丢"。GitHub 只背它该背的那几十字节。*
