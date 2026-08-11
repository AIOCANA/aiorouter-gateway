# AIOrouter Connector — Privacy Policy

> **Applies to:** this repository's setup scripts, guides, and configuration
> templates, and the AIOrouter service they connect to
> (`https://api.aiorouter.ca`) — covering the Claude Desktop third-party inference
> gateway, the ChatGPT Desktop / Codex integration, and the optional MCP tools.
> **Effective date:** 2026-08-01
> **Version:** 1.2
> **Consistent with:** AIOrouter Platform Privacy Policy v1.3.0
> (https://aiorouter.ca/docs/legal/privacy-policy)

## 1. Data Collection

The AIOrouter connectors (Claude Desktop Third-Party Inference, ChatGPT/Codex
`wire_api = "responses"`) collect the following data:

| Data Category | Description | Necessity |
|:---|:---|:---|
| **API Key** | User-provided API key, stored in a local environment variable or `~/.codex/auth.json`; **never written to disk by the connector scripts in plaintext, never echoed to stdout**. The platform stores only a SHA-256 lookup hash — never plaintext. | Required — authentication and billing |
| **Conversation content** | Messages sent to the AI model via AIOrouter (user prompts and model responses) | Required — AI model inference |
| **Usage / billing metadata** | Call counts, token counts, model name, timestamp, cost (non-content metadata only) | Required — quota and billing |
| **Account identity** | Email + user ID (only when logging into the dashboard) | Required — account binding and billing |

**We do NOT collect:** user files (unless explicitly sent in a chat), browsing
history, or other application data. The install scripts only read/write the config
files they are documented to touch (`~/.codex/config.toml`, `~/.codex/auth.json`,
Claude Desktop's config library), always with a backup first.

## 2. Usage, Storage, and Zero Prompt Retention

- Conversation content is used **only to route requests to the AI model you choose**
  (DeepSeek, Qwen, GLM, Kimi, Grok, Claude, Gemini, etc.) for inference.
- **Zero prompt retention (critical):** Prompts are processed **in server memory
  only** and are **never stored, logged, archived, or used for model training**.
  After the AI model response is returned, the prompt is permanently removed from
  memory with no recovery possible.
- **Metadata only:** We retain only non-content metadata (user ID, model name, token
  count, timestamp, cost) — the minimum necessary for billing and security auditing.
- Data is **de-identified by the AIOrouter PII Shield before routing** (personal
  information and technical secrets are protected first — Restore/Redact per your
  dashboard settings).
- All transmission is **HTTPS-encrypted**.
- **Canada data residency:** Account, authentication, billing, and audit metadata are
  processed in Canadian infrastructure.

## 3. Third-party Sharing

- **AI model providers** (Alibaba, DeepSeek, Zhipu, Moonshot, etc.): receive only the
  minimal, protected, de-identified request content needed for inference — **not your
  identity**. Providers' servers may be located in China or the United States (see
  platform policy).
- **Anthropic**: only when you configure AIOrouter as Claude Desktop's third-party
  inference gateway are Claude requests routed through AIOrouter.
- **We do not sell or rent user data.**

## 4. Data Retention

- Data retention follows the AIOrouter platform policy
  (https://aiorouter.ca/docs/legal/privacy-policy): billing transactions **7 years**
  (Canada Revenue Agency requirement), IP addresses 90 days, email until account
  deletion + 30-day grace period.
- **Prompt content is never retained** — it exists only in memory during active
  request processing and is permanently deleted upon response.
- Users can review usage, revoke API keys, or request data deletion at any time at
  https://dashboard.aiorouter.ca.

## 5. Governance & Contact

- This policy is governed by the laws of Canada applicable to the operation of the
  Service, consistent with the AIOrouter platform policy.
- **Privacy inquiries / DSAR / deletion requests:** privacy@aiorouter.ca
- **Security inquiries:** security@aiorouter.ca
- **Support:** support@aiorouter.ca
- **Company:** AIOCANA Technologies Inc. (AIOrouter), https://aiorouter.ca