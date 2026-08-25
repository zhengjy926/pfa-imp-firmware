## Agent skills

### Issue tracker

Issues and specs live as GitHub issues in zhengjy926/pfa-imp-firmware, operated via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles map 1:1 to default labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root, plus the `docs/requirements.md` traceability matrix. See `docs/agents/domain.md`.

### Serial protocol

ECSP snapshot and this board's product commands: `docs/protocol/`. Read when implementing, changing, or reviewing USART3/UART5 frames, command codes, addresses, or CRC.
