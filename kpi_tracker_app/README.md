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
  target), live pipeline health, and your latest week's status.
- **My Week** — mirrors the "Director X - Weekly" sheets: log leads,
  meetings, demos, proposals, proposal value, bookings won, follow-ups %,
  and (if tracked) content published. Status is computed automatically and
  lists exactly which targets were missed, plus a running cumulative-totals
  block and full history.
- **Pipeline** — mirrors the "Live Pipeline" sheet: one row per deal, auto
  weighted value (deal value × win probability), and a health check comparing
  weighted pipeline coverage against a remaining quarterly target (editable).
- **Insights → Monthly KPIs** — the 9 KPIs from the "Monthly KPI Dashboard"
  sheet with their formula, target, and red-flag thresholds baked in; enter
  an actual per month and status (on track / watch / red flag) computes
  automatically.
- **Insights → Activities** — the 10 major activities from the "Activities
  Plan" sheet; update Progress % monthly, status and the team average
  compute automatically.
- **Insights → Annual Targets** — reference figures from the "Annual
  Targets" sheet (revenue mix, quarterly booking targets); unit price/units
  are editable and revenue/totals recalculate.
- **More → Team Overview** — compare every member's cumulative totals and
  latest status at a glance.
- **More → Manage Team** — add, edit, or remove team members and their
  weekly targets.
- **More → Settings & Backup** — export all data to a JSON file (shareable)
  or import a backup, since storage is local-only.

## Project structure

```
lib/
  models/     Plain data classes (TeamMember, WeeklyEntry, PipelineDeal, ...)
  data/       Hive box setup + seed data taken from the source workbook
  state/      AppState — a single ChangeNotifier wrapping the Hive boxes and
              exposing computed values (cumulative totals, statuses, coverage)
  utils/      Formatters and the pure status-computation functions that
              mirror the workbook's auto-status formulas
  screens/    One file per screen
  widgets/    Small shared widgets (status chips, section headers)
```

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
example). `test/app_smoke_test.dart` boots the full app against a temporary
Hive database and walks through onboarding into the home dashboard.

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
