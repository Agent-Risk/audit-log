# AgentRisk 锚定链恢复说明

## 恢复日期：2026-09-06

### 断链原因

2026-08-15 起，每日快照 `records.jsonl.gz` 超过 GitHub 单文件 100MB 限制（8/15: 100.11MB → 9/06: 105.40MB），导致 `git push` 被 `pre-receive hook` 拒绝，远程 `origin/main` 滞留在 2026-08-14。

### 恢复方案

自 2026-09-06 起，每日推送轻量锚定文件 `anchors/YYYY-MM-DD.json` + `anchors/YYYY-MM-DD.json.sig`：

**anchors/YYYY-MM-DD.json 字段：**

| 字段 | 说明 |
|------|------|
| `date` | 锚定日期 (YYYY-MM-DD) |
| `merkle_root` | 当日快照 Merkle 根哈希 |
| `prev_root` | 前一日 Merkle 根（链式衔接，8/15 prev_root = 8/14 merkle_root） |
| `record_count` | 当日评分记录数 |
| `anchor_hash` | `SHA256(merkle_root + prev_root)` |
| `records.file_sha256` | `records.jsonl.gz` 的 SHA256 指纹 |
| `records.file_bytes` | `records.jsonl.gz` 字节数 |

**ed25519 签名（anchors/YYYY-MM-DD.json.sig）：**

- 签名内容：**anchor JSON 文件的原始字节**（UTF-8 encoded, sort_keys=True, indent=2, ensure_ascii=False）
- 算法：ed25519 (NaCl)
- 公钥：`https://api.agentrisk.app/v1/proof/public_key`
- 验签方法：`VerifyKey.verify(anchor_json_bytes, base64_decode(sig_file_content))`

### 补齐的 23 天（8/15 → 9/06）

23 个 anchor JSON 文件一次性补齐，本地 Merkle 链式连续（prev_root 衔接验证通过）。

**透明说明：补齐的锚定不能证明 root 是当天算的**（已过期，本地快照文件在此期间的 snapshots/ 目录缺失），但 prev_root 链式连续 + 本说明如实透明了这一局限性。未来每日 anchor.py 正常运行时 snapshots/ 会持续积累。

### 数据本体

`records.jsonl.gz` 保留在本地 `snapshots/` 目录（`.gitignore` 排除），定期备份至阿里云 OSS（低频存储）。

### 历史记录

2026-08-14 前已推送的大文件**不清算、不重写历史**。`force push` 重写历史 = 自毁已有的公开锚定 commit。

---

*签名管"真的是我"，root 锚定管"我没改过"，OSS 管"数据不丢"。GitHub 只背它该背的那几十字节。*
