# Automation Chain

A small browser game that demonstrates, in an interactive way, how **Claude**, **GitHub**, **Slack**, and **Gmail** connect together to form real automation workflows.

## What it is

Each level presents a trigger ("a user opens a GitHub issue", "a customer emails support") and a goal. You're given a shuffled set of step chips — some correct, some intentional distractors — and you assemble them into the right order to complete the automation chain. Get it right and you'll see an explanation of the real-world workflow the puzzle was modeling.

This is a simulation: no repositories, channels, or inboxes are actually touched. It's meant to teach the *shape* of these automations — trigger → reasoning → notification — rather than execute them.

## Levels

1. **Bug Triage Pipeline** — GitHub issue → Claude labels it → Slack notifies the team → Gmail alerts on-call.
2. **Support Inbox to Backlog** — Gmail request → Claude classifies it → GitHub issue created → Slack notifies product.
3. **Stale PR Nudge** — GitHub detects inactivity → Claude drafts a reminder → Slack DMs the author.
4. **Release Day Announcement** — GitHub release → Claude writes release notes → Slack announces → Gmail reaches customers.

## Running it

No build step or dependencies. Just open `index.html` in a browser, or serve the folder:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000`.

## Files

- `index.html` — page structure
- `style.css` — dark theme, chip/slot styling, layout
- `script.js` — level data, game state, click-to-place interaction, scoring
