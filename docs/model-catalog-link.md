# Model Catalog — single source of truth

The canonical, always-current list of **all 19 AIOrouter models** (DeepSeek, Qwen,
GLM, Kimi, Grok, Claude, Gemini) with pricing lives at:

## 🔗 https://aiorouter.ca/docs/model-catalog

**Why link instead of duplicate:** the catalog is generated from AIOrouter's
single source of truth and changes as models are added/retired. This repository
never copies the model list into guides — guides and prompts link to the catalog so
they never drift out of date.

A machine-readable snapshot is also published for tooling
(`aiorouter-catalog.min.json`, mirrored in this repo at
[chatgpt-codex/aiorouter-catalog.min.json](../chatgpt-codex/aiorouter-catalog.min.json)) —
always prefer the live catalog URL for human-readable pricing.

## How models are referenced in this repo

| Context | How the model list is obtained |
|:---|:---|
| Claude Desktop picker | The imported config template embeds the full model list (`inferenceModels`) — no manual list needed |
| Codex `config.toml` | A short commented snapshot (5 common models) + link to the catalog |
| Model-switch SKILL / AGENTS.md procedure | Checks the local commented list first, then fetches the catalog URL |
| Prompts and guides | Always link to https://aiorouter.ca/docs/model-catalog |

## Pricing

Public retail pricing ($19/mo subscription, per-token rates) is shown only at the
catalog URL and on [aiorouter.ca](https://aiorouter.ca) — this repository contains no
pricing tables.