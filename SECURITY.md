# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in any AIOrouter setup script, guide, or
configuration template in this repository, please report it privately — **do not open
a public issue**.

**Email:** security@aiorouter.ca

Please include:
- Affected file / version
- Steps to reproduce
- Impact description
- (If possible) a proof-of-concept

You should receive a response within **48 hours**. We appreciate responsible
disclosure and will credit researchers who report valid issues (unless anonymity
is requested).

## Scope

This repository contains **setup guides, install scripts, and configuration templates**
for connecting Claude Desktop / ChatGPT / Codex to AIOrouter. It contains:

- ✅ Public API endpoints (e.g. `https://api.aiorouter.ca/v1/responses`)
- ✅ Public configuration templates (e.g. `claude-desktop-template.json`)
- ✅ Install scripts that read your API key from your environment / secure prompt
- ❌ **No API keys, tokens, or secrets** — all key examples are placeholders (`ak-your-key`)
- ❌ **No proprietary backend code** — routing, billing, and PII Shield internals are
  not in this repository
- ❌ **No contract pricing or internal business data**

## Supported Versions

This repository is documentation + scripts; changes are tracked in
[CHANGELOG.md](CHANGELOG.md). The latest commit on `main` is always the supported
version.

## Disclosure Timeline

- **0-48h:** Initial triage and acknowledgement
- **1 week:** Fix developed and tested
- **2-4 weeks:** Fix released (coordinated disclosure)