# InfoCare KPI Tracker (Flutter)

A mobile app version of the "InfoCare Weekly KPI Tracker — FY 2083/84" workbook.
Directors and Sales Team members log their own weekly activity against
individually assigned targets; pipeline, monthly KPIs, activities, and
annual targets are tracked the same way they are in the source spreadsheet.

**Storage: local-only.** All data lives in an on-device Hive database — there
is no backend and no login. Each phone has its own independent dataset. Use
Settings & Backup → Export/Import to move data between devices or back it up.

## Screens

- **Onboarding** — pick your profile (Director A/B are pre-seeded from the
  workbook) or add yourself as a new Sales Team member with your own weekly
  targets.
- **Home** — annual goal progress (cumulative bookings vs. the FY revenue
  target), live pipeline health, your latest week's status, a "Log this
  week" quick-add button, and a nudge card when you haven't logged
  anything in 7+ days.
- **My Week** — mirrors the "Director X - Weekly" sheets: log leads,
  meetings, demos, proposals, proposal value, bookings won, follow-ups %,
  and (if tracked) content published. Status is computed automatically and
  lists exactly which targets were missed, plus a running cumulative-totals
  block and full history.
- **Pipeline** — mirrors the "Live Pipeline" sheet: one row per deal, auto
  weighted value (deal value × win probability), and a health check comparing
  weighted pipeline coverage against a remaining quarterly target (editable).
- **Insights → Monthly KPIs** — starts seeded with the 9 KPIs from the
  "Monthly KPI Dashboard" sheet, but KPIs are fully user-editable from
  here on: "Add KPI" opens a form for name, what it measures, owner, unit
  (percent/multiplier/days/count), whether higher or lower is better, and
  the target/red-flag numbers — the "≥ 100%" / "< 85%" style display
  labels are generated from those automatically. Each existing KPI has an
  Edit/Delete menu. Enter an actual per month and status (on track /
  watch / red flag) computes automatically; each card shows a trend
  sparkline of every actual entered so far plus a pacing bar comparing
  the latest actual to its target.
- **Insights → Activities** — the 10 major activities from the "Activities
  Plan" sheet; update Progress % monthly, status and the team average
  compute automatically.
- **Insights → Annual Targets** — reference figures from the "Annual
  Targets" sheet (revenue mix, quarterly booking targets); unit price/units
  are editable and revenue/totals recalculate.
- **Carbon** — a personal carbon-savings log, separate from the sales
  KPIs. Log everyday actions (biked instead of driving, a plant-based
  meal, recycling, air-drying laundry, ...) from a built-in catalog of 8
  activity types; see today's total kg CO2e saved, a breakdown of which
  activities contributed, a 14-day trend sparkline, and lifetime/weekly
  totals. "Share today's impact" renders a story-style image card and
  opens the phone's native share sheet — Instagram, Facebook, or TikTok
  show up there if installed, the same way sharing a photo from the
  camera roll would work. There's no Meta/TikTok SDK integration, so it
  can't auto-post or pick a destination for you; that would need each
  platform's own API keys and app review, which is out of scope for a
  local-only app. CO2e factors are general per-unit averages (sourced in
  `lib/data/carbon_catalog.dart`), not a certified personal carbon audit
  — the goal is to make the *shape* of your impact visible, not to be
  precise to the gram.
- **More → Team Overview** — compare every member's cumulative totals and
  latest status at a glance.
- **More → Manage Team** — add, edit, or remove team members and their
  weekly targets.
- **More → Reports** — auto-generated Weekly Recap (every member's latest
  status, shareable as text) and Monthly KPI Recap (status counts across
  all KPIs), each with a one-tap CSV export of the underlying data.
- **More → Settings & Backup** — export all data to a JSON file (shareable)
  or import a backup, since storage is local-only.

## Project structure

```
lib/
  models/     Plain data classes (TeamMember, WeeklyEntry, PipelineDeal,
              CarbonLogEntry, ...)
  data/       Hive box setup + seed data + the carbon activity catalog
  state/      AppState — a single ChangeNotifier wrapping the Hive boxes and
              exposing computed values (cumulative totals, statuses, coverage,
              carbon totals/breakdown/history)
  utils/      Formatters, the pure status-computation functions that mirror
              the workbook's auto-status formulas, CSV export, and the
              RepaintBoundary → PNG capture helper used for social sharing
  screens/    One file per screen
  widgets/    Small shared widgets (status chips, section headers, the
              hand-rolled Sparkline/PacingBar trend widgets, the carbon
              share card)
```

Trend sparklines and pacing bars are drawn with a small `CustomPainter`
(`lib/widgets/sparkline.dart`) rather than a charting package, so there's
no extra pub dependency to keep resolvable offline. CSV export
(`lib/utils/csv_export.dart`) and the carbon share-card image capture
(`lib/utils/share_image.dart`, via `RenderRepaintBoundary.toImage`) are
hand-rolled the same way — no new pub dependency was added for any of the
Carbon, custom-KPI, or reporting features.

Hive boxes store plain `Map<String, dynamic>` values (no code-generated type
adapters), so the on-disk format is easy to inspect, export, and migrate.

## Running it

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter analyze
flutter test
```

`test/status_logic_test.dart` checks the status-computation logic against
the exact examples from the source workbook (e.g. Director A's "Shrawan W1"
row missing Meetings/Demos/Bookings, and the Live Pipeline coverage ratio
example) — this is the fast, reliable check and the one to trust.

`test/app_smoke_test.dart` walks through onboarding into the home dashboard
against a real (temporary) Hive database, but is currently `skip:`ped: in
the sandboxed container this app was built in, any `testWidgets` body
mixing real Hive file I/O with widget pumping hangs indefinitely — including
a minimal `Consumer<AppState>` widget test with no app screens at all — while
Hive I/O alone and widget pumping alone both work fine in isolation. That
points to a restriction on real async file I/O inside the `flutter_tester`
process specific to that environment, not an app bug. Drop the `skip:`
argument to re-enable it on a normal dev machine or CI runner.

## Notes on scope decisions

- **Local-only storage** was chosen over a cloud backend, so Directors and
  Sales Team members do not currently see each other's live data — each
  phone is independent. If shared/real-time visibility across the team is
  needed later, the cleanest path is swapping the `AppState` Hive calls for
  a backend (e.g. Firebase Firestore) behind the same public API, since
  screens only ever talk to `AppState`, never to Hive directly.
- **Sales Team members are modeled the same way as Directors** (a
  `TeamMember` with its own `WeeklyTargets`), generalizing the workbook's
  two hardcoded director sheets to any number of team members, each with
  individually assigned weekly targets — matching the requirement that Sales
  Team members submit activity reports against targets assigned to them.
- **No OS push notifications for the "log your week" reminder** — Home
  shows an in-app nudge card instead when 7+ days have passed since your
  last entry. A real push reminder needs `flutter_local_notifications`
  plus native Android/iOS manifest and permission wiring that nothing in
  this sandbox (no `flutter`/`dart` binary, so no way to verify a native
  plugin integration compiles) could actually verify — adding it blind
  risked breaking the build for a feature nobody could test. Worth
  revisiting on a machine with the Flutter SDK installed.
- **Carbon tracking is per-profile, not per-device-global** — it reuses
  the same `TeamMember` switcher as the sales KPIs, since the app already
  has a "whose data is this" concept and building a second one would
  duplicate it for no reason.
- **Export/share buttons (CSV export, backup export/import, carbon
  share-card) need real file I/O (`dart:io` + `path_provider`) and only
  work on the actual Android/iOS/desktop app.** This was already true of
  Settings & Backup before this round of changes. `flutter build web`
  still compiles fine — the Flutter web SDK ships a `dart:io` stub so the
  code resolves — but tapping one of those buttons in the web preview
  build deployed by this repo's GitHub Pages workflow will throw at
  runtime instead of producing a file. The web build is a quick preview
  link, not the primary target; the mobile app is.
