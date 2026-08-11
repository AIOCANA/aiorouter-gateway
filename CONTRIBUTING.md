# Contributing

Thanks for your interest in contributing to the AIOrouter Gateway setup repository!

## Important scope note

This is the **public setup/docs repository** for AIOrouter. It contains:

- Setup guides (Claude Desktop, ChatGPT/Codex)
- One-prompt installers
- Verified install scripts (`install-codex.*`, `install-claude.*`)
- The published model-switch SKILL file

The AIOrouter **gateway backend** (routing, billing, PII Shield pipeline,
infrastructure) is **proprietary** and lives in a separate private repository.
The **MCP server** is a separate open-source package
([AIOCANA/aiorouter-mcp](https://github.com/AIOCANA/aiorouter-mcp), npm
`@aiorouter/mcp`).

**Please do not open PRs or issues requesting access to proprietary backend code,
internal pricing, or infrastructure details** — those are not part of this project.

## How to contribute

1. **Fork** the repository
2. **Create a branch**: `git checkout -b docs/your-change`
3. **Make changes** — keep the tone consistent with existing guides:
   - Simple, copy-pasteable instructions
   - Placeholder API keys only (`ak-your-key`) — never real keys
   - No proprietary/internal paths, no contract pricing
   - Model lists link to https://aiorouter.ca/docs/model-catalog (single source of truth)
4. **Verify**: re-read your changes for any accidental secrets or internal references
5. **Commit**: use clear, descriptive commit messages
6. **Push & open a Pull Request** describing your change

## Review guidelines

When reviewing contributions, check that:

- No real API keys, tokens, or personal data appear (placeholders only)
- No internal paths (`plans/`, `src/gateway/`, `src/mcp-server/`, `tests/`, `.env*`,
  `AIOrouter-Business/`) are referenced
- Install scripts never write the API key to disk unencrypted
- Model counts/names match the published catalog (linked, not duplicated)

## License

By contributing you agree that your contributions are licensed under the
[MIT License](./LICENSE).