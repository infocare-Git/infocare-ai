const SERVICES = {
  claude: { label: "Claude", badge: "CL", class: "badge-claude" },
  github: { label: "GitHub", badge: "GH", class: "badge-github" },
  slack: { label: "Slack", badge: "SL", class: "badge-slack" },
  gmail: { label: "Gmail", badge: "GM", class: "badge-gmail" },
};

const LEVELS = [
  {
    title: "Bug Triage Pipeline",
    trigger: "A user opens a new GitHub Issue reporting a crash.",
    goal: "Get the bug analyzed, labeled, and the team notified — automatically.",
    correctOrder: ["gh-opened", "claude-triage", "slack-bugs", "gmail-oncall"],
    chips: [
      { id: "gh-opened", service: "github", label: "Issue Opened" },
      { id: "claude-triage", service: "claude", label: "Analyze & Label Issue" },
      { id: "slack-bugs", service: "slack", label: "Notify #bugs channel" },
      { id: "gmail-oncall", service: "gmail", label: "Email on-call engineer" },
      { id: "claude-blog", service: "claude", label: "Write a blog post" },
      { id: "slack-meme", service: "slack", label: "Post a random meme" },
    ],
    explanation:
      "This is the pattern behind automated bug triage: GitHub fires a webhook the moment an issue opens, Claude reads it and applies the right labels or severity, Slack pings the team in real time, and Gmail makes sure the on-call engineer sees it even if they're away from Slack.",
  },
  {
    title: "Support Inbox to Backlog",
    trigger: "A customer emails support with a feature request.",
    goal: "Turn the email into a tracked GitHub issue and alert the team.",
    correctOrder: ["gmail-received", "claude-classify", "gh-create", "slack-product"],
    chips: [
      { id: "gmail-received", service: "gmail", label: "Support email received" },
      { id: "claude-classify", service: "claude", label: "Summarize & classify request" },
      { id: "gh-create", service: "github", label: "Create issue from summary" },
      { id: "slack-product", service: "slack", label: "Notify #product channel" },
      { id: "gh-delete", service: "github", label: "Delete the repository" },
      { id: "claude-translate", service: "claude", label: "Translate to French" },
    ],
    explanation:
      "Inbound email becomes structured work: Gmail hands the message to Claude, which pulls out the actual request and classifies it, GitHub turns that into a trackable issue, and Slack loops in the product team — no one has to copy-paste an email into a ticket ever again.",
  },
  {
    title: "Stale PR Nudge",
    trigger: "A pull request has had no activity for 3 days.",
    goal: "Remind the author without anyone lifting a finger.",
    correctOrder: ["gh-stale", "claude-draft", "slack-dm"],
    chips: [
      { id: "gh-stale", service: "github", label: "Detect stale PR" },
      { id: "claude-draft", service: "claude", label: "Draft a friendly reminder" },
      { id: "slack-dm", service: "slack", label: "DM the PR author" },
      { id: "claude-approve", service: "claude", label: "Approve the code changes" },
      { id: "gh-close", service: "github", label: "Close PR without comment" },
    ],
    explanation:
      "A scheduled GitHub check spots inactivity, Claude drafts a tone-appropriate nudge instead of a robotic one, and Slack delivers it directly to the author. Notice Claude never approves the code itself — automation nudges humans, it doesn't replace their judgment on the merge.",
  },
  {
    title: "Release Day Announcement",
    trigger: "A new GitHub Release is published.",
    goal: "Spread the word everywhere, instantly.",
    correctOrder: ["gh-release", "claude-notes", "slack-general", "gmail-customers"],
    chips: [
      { id: "gh-release", service: "github", label: "Release published" },
      { id: "claude-notes", service: "claude", label: "Generate release notes" },
      { id: "slack-general", service: "slack", label: "Announce in #general" },
      { id: "gmail-customers", service: "gmail", label: "Email customer list" },
      { id: "slack-delete", service: "slack", label: "Delete #general" },
      { id: "gmail-spam", service: "gmail", label: "Send to spam folder" },
    ],
    explanation:
      "One GitHub event fans out everywhere: Claude turns raw commits into readable release notes, Slack tells the internal team immediately, and Gmail reaches customers who don't live in Slack. Same trigger, multiple audiences, zero manual copywriting.",
  },
];

let state = {
  levelIndex: 0,
  score: 0,
  slots: [],
  selectedChipId: null,
  placedChipIds: new Set(),
};

const el = {
  levelIndicator: document.getElementById("level-indicator"),
  scoreIndicator: document.getElementById("score-indicator"),
  scenarioTitle: document.getElementById("scenario-title"),
  scenarioTrigger: document.getElementById("scenario-trigger"),
  scenarioGoal: document.getElementById("scenario-goal"),
  slots: document.getElementById("slots"),
  palette: document.getElementById("palette"),
  checkBtn: document.getElementById("check-btn"),
  resetBtn: document.getElementById("reset-btn"),
  feedback: document.getElementById("feedback"),
  modal: document.getElementById("modal"),
  modalTitle: document.getElementById("modal-title"),
  modalExplanation: document.getElementById("modal-explanation"),
  modalNext: document.getElementById("modal-next"),
};

function shuffle(arr) {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function currentLevel() {
  return LEVELS[state.levelIndex];
}

function loadLevel(index) {
  state.levelIndex = index;
  const level = LEVELS[index];
  state.slots = new Array(level.correctOrder.length).fill(null);
  state.selectedChipId = null;
  state.placedChipIds = new Set();

  el.levelIndicator.textContent = `${index + 1} / ${LEVELS.length}`;
  el.scenarioTitle.textContent = level.title;
  el.scenarioTrigger.textContent = level.trigger;
  el.scenarioGoal.textContent = level.goal;
  el.feedback.textContent = "";
  el.feedback.className = "feedback";

  renderPalette(shuffle(level.chips));
  renderSlots();
}

function renderPalette(chips) {
  el.palette.innerHTML = "";
  chips.forEach((chip) => {
    const svc = SERVICES[chip.service];
    const node = document.createElement("div");
    node.className = "chip";
    node.dataset.chipId = chip.id;
    node.innerHTML = `
      <span class="chip-badge ${svc.class}">${svc.badge}</span>
      <span class="chip-label">${chip.label}</span>
    `;
    node.addEventListener("click", () => onChipClick(chip.id));
    el.palette.appendChild(node);
  });
  syncPaletteState();
}

function onChipClick(chipId) {
  if (state.placedChipIds.has(chipId)) return;
  state.selectedChipId = state.selectedChipId === chipId ? null : chipId;
  syncPaletteState();
}

function syncPaletteState() {
  [...el.palette.children].forEach((node) => {
    const id = node.dataset.chipId;
    node.classList.toggle("placed", state.placedChipIds.has(id));
    node.classList.toggle("selected", state.selectedChipId === id);
  });
}

function findChip(chipId) {
  return currentLevel().chips.find((c) => c.id === chipId);
}

function renderSlots() {
  el.slots.innerHTML = "";
  state.slots.forEach((chipId, i) => {
    const slotNode = document.createElement("div");
    slotNode.className = "slot" + (chipId ? " filled" : "");
    slotNode.dataset.index = i;

    if (chipId) {
      const chip = findChip(chipId);
      const svc = SERVICES[chip.service];
      slotNode.innerHTML = `
        <div>
          <span class="chip-badge ${svc.class}">${svc.badge}</span>
          <div class="chip-label">${chip.label}</div>
        </div>
      `;
    } else {
      slotNode.textContent = `Step ${i + 1}`;
    }

    slotNode.addEventListener("click", () => onSlotClick(i));
    el.slots.appendChild(slotNode);
  });
}

function onSlotClick(index) {
  const existing = state.slots[index];

  if (existing) {
    state.placedChipIds.delete(existing);
    state.slots[index] = null;
    renderSlots();
    syncPaletteState();
    return;
  }

  if (state.selectedChipId) {
    state.slots[index] = state.selectedChipId;
    state.placedChipIds.add(state.selectedChipId);
    state.selectedChipId = null;
    renderSlots();
    syncPaletteState();
  }
}

function checkAnswer() {
  const level = currentLevel();
  if (state.slots.some((s) => !s)) {
    showFeedback("Fill every step before running the automation.", false);
    return;
  }

  const correct = level.correctOrder.every((id, i) => state.slots[i] === id);

  if (correct) {
    state.score += 100;
    el.scoreIndicator.textContent = state.score;
    showFeedback("Automation ran successfully!", true);
    openModal(level);
  } else {
    state.score = Math.max(0, state.score - 10);
    el.scoreIndicator.textContent = state.score;
    showFeedback("That chain doesn't produce the right outcome. Try a different order.", false);
    el.slots.classList.add("shake");
    setTimeout(() => el.slots.classList.remove("shake"), 300);
  }
}

function showFeedback(message, ok) {
  el.feedback.textContent = message;
  el.feedback.className = "feedback " + (ok ? "ok" : "bad");
}

function openModal(level) {
  el.modalTitle.textContent = `${level.title} — Solved!`;
  el.modalExplanation.textContent = level.explanation;
  el.modal.classList.remove("hidden");
  el.modalNext.textContent =
    state.levelIndex + 1 < LEVELS.length ? "Next Level →" : "Play Again ↺";
}

function closeModalAndAdvance() {
  el.modal.classList.add("hidden");
  const next = (state.levelIndex + 1) % LEVELS.length;
  loadLevel(next);
}

el.checkBtn.addEventListener("click", checkAnswer);
el.resetBtn.addEventListener("click", () => loadLevel(state.levelIndex));
el.modalNext.addEventListener("click", closeModalAndAdvance);

loadLevel(0);
