# AGENTS.md — Ayaat Quran App

> Mandatory instructions for every coding agent working in this repository.
> **Read this file in full before starting ANY task.** These rules are the owner's requirements, not suggestions.
> If a rule conflicts with a real project constraint, explain the conflict and propose a solution BEFORE changing approach.
> Never claim something about the project (a library, a file, an endpoint) before verifying it in the actual files.

---

## 1. Project Goal

Rebuild the existing Flutter app `ayaat_quran_majeed` into a **pixel-faithful replica** of the 39 reference screenshots and the playback video in `docs/design/reference/` (see section 12).

- Scope: **Quran reader only**. Everything not visible in the reference screenshots (azkar, qibla, tasbeeh, prayer times, etc.) is **out of scope and must be removed** during the cleanup task, including their unused assets and dependencies. The only notification feature in scope is the **daily khatma reminder** (screenshots 23, 26, 31).
- Language: **Arabic only, RTL only** for now. Light theme only unless a task says otherwise.
- Architecture decision (owner-approved): **full rebuild on Clean Architecture, Feature-First**, while **preserving the Quran data and audio capabilities**.
- Quran engine decision (owner-approved): the local `quran-1.2.2` package and the 604 per-page font families `QCF_P001`…`QCF_P604` (plus `assets/fonts/v2woff`) are **replaced by the pub.dev package `qcf_quran_plus`** (MIT; page rendering, QCF font loading via `QcfFontLoader`, metadata, search, highlights). Adoption, pinning, wrapping behind our own domain interfaces and removal of the old fonts/package happen in task 1.07 only, after parity is verified. Quran text must never be modified.
- Content sources (owner decisions, 2026-11-01): **word meanings and audio tafsir are cancelled** (do not build them). **The default tafsir book is Al-Tafsir Al-Muyassar** (replaces Al-Mukhtasar everywhere it appears in the screenshots: the label in tafsir mode, the library sheet, the editor sheet). Tafsir books come from what already exists in the project: bundled `muyassar.dart` and `sahih_english.dart`, plus downloadable books listed in `lib/quran/data/data_sources/translation/translationdata.dart` (remote JSON from `noureddin/Quran-App-Data`; the owner tested the links and they work; the repository license/terms must still be recorded in the About section). Reciter audio comes from the **mp3quran.net API v3** that the legacy code already uses (reciters, suwar, moshaf, whole-surah files) plus its **ayat_timing** endpoints for ayah timing (to be verified with real responses in task 0.01) and must support **per-surah offline download** and **ayah-level timing for the follow-along highlight** (screenshot 36 and video 37). The 29-day khatma table is transcribed from screenshots 24, 33 and 35. Never invent endpoints, response fields, or data.

## 2. Mandatory Workflow

1. **Understand → Plan → Implement.** Inspect `pubspec.yaml`, entry points, routing, state management, DI and the files related to the task before writing code.
2. For any non-trivial task use the **two-gate flow**:
   - **GATE 1:** return a short evidence-based plan (files to create/change, data flow, edge cases, tests, genuine unknowns). **Stop and wait for explicit owner approval.** Do not edit files before approval.
   - **GATE 2:** implement the approved minimal change, then verify and report (execution MUST follow the **Mandatory Implementation Delegation Rule** below via Antigravity).
3. Work in small reviewable steps, one complete feature at a time. After each important step summarize what is done and what is next.
4. Do not guess APIs, backends, data models or undocumented behavior. Name the missing information first and ask.
5. Do not create files, layers or services "just in case". Create them only when needed.
6. Explain important architectural decisions briefly, especially when there is more than one reasonable option.
7. If the owner asks for analysis only, **do not modify files**. Separate verified findings from hypotheses.
8. **Mandatory completion checks:** after every task that changes the repository, run both commands from the repository root before declaring the task complete:
   - `flutter analyze`
   - `flutter test`
   Targeted tests may be run in addition, but they do not replace the full `flutter test` command. If either command fails, investigate and report the real failure; do not claim the task is complete or the checks passed. The only exception is an explicitly analysis/research-only task that makes no repository changes; state that this exception applies in the final report.

## 3. Code the Owner Can Understand

- Write clear, direct, maintainable Dart. No clever shortcuts at the cost of readability.
- No unnecessary abstractions or empty boilerplate layers.
- Do not put a whole feature in one file; do not split into many files without a clear responsibility.
- Use meaningful names and keep naming consistent across the project.
- When adding a feature, explain each layer's role and the data flow between layers.
- Make sure new code is consistent with existing files and that the owner can trace its logic.

## 4. Change Discipline

- Make the **smallest correct change** that satisfies the task. Fix root causes, not symptoms.
- Do not refactor files unrelated to the task. Do not delete or replace code before understanding its usages (exception: the approved cleanup task for out-of-scope features).
- Preserve existing behavior and public interfaces unless the task asks to change them.
- Check `git status` and `git diff` before broad changes. Never discard the owner's uncommitted work.
- **Never** run destructive commands (reset, clean, force push, mass delete) without explicit permission.

## 5. Architecture

**Clean Architecture, Feature-First.** Dependency flow: `Presentation → Domain ← Data`.

Feature build order (skip a layer only with a clear reason):
`Model/Entity → Data Source/Service → Repository → Use Case → Cubit → UI`

- **Entity** (domain): business concept, pure Dart, no Flutter imports.
- **Model** (data): external data format, JSON/asset parsing, mapping to/from Entity.
- **Data Source / Service**: API, assets, local storage access.
- **Repository**: single interface for data; converts source results/errors into domain results.
- **Use Case**: a clear business operation, only when there is logic or a need to separate it.
- **Cubit**: manages feature state and coordinates use cases (or repository when no use case is warranted).
- **UI**: renders state and sends user events only.

Hard rules:
- UI never touches API, database or local storage directly.
- A Cubit never calls Dio or a data source directly.
- No business rules inside widgets, `build()` or UI handlers.
- Domain files never import Flutter.
- Do not force a use case on a trivial operation; keep boundaries without ceremony.

### Folder structure (guideline, adapt to real needs)

```text
lib/
  core/
    constants/  errors/  network/  di/  routing/  theme/  localization/  widgets/  utils/
  features/
    <feature_name>/
      data/ (datasources/ models/ repositories/)
      domain/ (entities/ repositories/ usecases/)
      presentation/ (cubit/ pages/ widgets/)
```

Shared code goes to `core/` only when it is genuinely cross-feature. Feature-specific logic never goes to `core/`.

Planned features (names are guidance, confirm in each task): `mushaf` (reader), `index` (surah/quarter index), `search`, `audio`, `tafsir`, `khatma`, `bookmarks`, `starred`, `notes`, `today` (ayah of the day), `settings`.

## 6. Mandatory Technology Choices

| Concern | Choice | Rules |
|---|---|---|
| State | `flutter_bloc` (Cubit; Bloc only with clear justification) | One Cubit per clear scope. No GetX/Provider/Riverpod. `setState` only for tiny local UI state. Explicit loading / success / empty / failure states. |
| Routing | `go_router` | Routes declared in one place (`core/routing`). Pass ids, not large objects. No navigation from data/domain layers. |
| DI | `get_it` | Registrations in `core/di`. Never create dependencies manually inside widgets. Provide Cubits via `BlocProvider` at the narrowest scope; do not put all Cubits in `main.dart`. |
| Network | `Dio` | One shared client config (baseUrl, timeouts, headers, error mapping). Do not repeat setup per repository. No secrets in the client. Handle offline, timeout, non-2xx, malformed data. |
| Local storage | `SharedPreferences` for simple settings; `Hive` for structured data (bookmarks, notes, khatma, starred, cached content) | Always behind a data source/service. Never from UI or Cubit directly. |
| Responsive UI | `flutter_screenutil` | Already in the project. Avoid fixed sizes that break on target screens. |
| Localization | `easy_localization` | No hardcoded user-visible strings in widgets. All text from translation files. RTL verified. |
| Quran engine | `qcf_quran_plus` (pinned exact version) | Used only through our own wrappers/interfaces in the data layer; UI widgets may use its `QuranPageView` builders. Do not override `ayahStyle` unless the task says so. Initialize fonts during startup/splash. |
| Notifications | `flutter_local_notifications` + timezone (verify at GATE 1) | Only for the daily khatma reminder. Handle permission, exact-alarm limits, reboot, time zone changes. |
| Models | Native Dart | Do **not** add Freezed / `build_runner` automatically. |

Do not replace a technology with your own preference. Do not add a dependency without necessity and owner authorization. Do not add a database/storage system without clear justification.

## 7. UI Fidelity Rules (core of this project)

- The reference screenshots in `docs/design/reference/` are the **source of truth**. Match layout, spacing, typography, colors, radii, icons, states and RTL alignment.
- All visual values live in **design tokens** (`core/theme`): colors, text styles, spacing, radii. Features use `Theme.of(context)` / theme extensions. **No hardcoded colors or magic numbers inside feature widgets.**
- Use `flutter_screenutil` consistently. Verify on small (360dp), normal (≈392dp) and large (tablet) widths, and with large system font scale.
- Split screens into small widgets with clear responsibility. Use `const` where possible. No heavy objects or controllers created inside `build()`. Dispose controllers, focus nodes, streams and audio resources correctly.
- Place `BlocBuilder` / `BlocSelector` at the smallest scope that needs the update.
- If a screenshot is ambiguous or a detail cannot be inferred, **ask the owner**; do not invent a design system.
- Anything visible in the screenshots that needs backend/data support not yet verified must be reported at GATE 1, not guessed.
- Deviations from the screenshots must be listed in the final report with reasons.

## 8. Quran-Specific Rules

- Quranic text correctness is critical: never alter, normalize or "fix" Quran text, verse numbering, page mapping or tashkeel without an explicit task and owner approval.
- Keep the 604-page mushaf layout working through `qcf_quran_plus`. Follow the package's font-loading guidance (startup initialization + page preloading) and measure startup time and memory instead of assuming.
- Audio: handle buffering, errors, interruptions (calls, headphones unplugged), background playback, and resource disposal.
- Any religious content source (tafsir, translation, word meanings) must be attributed correctly in the UI/About area and verified for licensing/terms before use.

## 9. Code Quality

- Follow official Dart style and the project's `flutter_lints`. Clear names, no `dynamic`, no unnecessary casts.
- Handle `null` explicitly; never use `!` just to silence the analyzer.
- No `TODO`/`FIXME` or experimental code without explanation and owner approval.
- Comment the *why* or non-obvious constraints, not the obvious.
- **Errors:** convert external errors to a feature-appropriate `Failure`/result. Never show `Exception.toString()` to users. Never swallow errors silently (no empty `catch`). Keep a consistent result contract within a feature.
- **Tests:** add tests for business logic, repositories and Cubits when appropriate; cover success, failure, empty and important edge cases. A bug fix should add a reproducing test when practical. Tests must not depend on the real network or real time.

## 10. Dependencies and Build

- Do not upgrade all packages just because newer versions exist. Check Flutter/Dart/platform compatibility before upgrades.
- Never edit `pubspec.lock` manually. Do not add `dependency_overrides` as a quick fix without a documented reason (existing ones must be reviewed in the foundation task).
- Run `flutter pub get` after dependency changes, then the relevant checks.
- Do not run `flutter clean` or delete build output randomly; only when evidence supports it.
- For build problems start from the exact error message and the smallest change.

## Mandatory Implementation Delegation Rule (GATE 2 Execution)

Whenever a task reaches **GATE 2 (Implementation)** after owner approval, you (Codex) are the **Orchestrator and Reviewer**, NOT the direct code writer. You MUST execute GATE 2 through the following exact workflow:

1. **Write the Implementation Brief:**
   - Do NOT edit repository source or test files directly.
   - Write the approved GATE 1 plan, exact file paths, architectural constraints (Clean Architecture Feature-First: `Presentation → Domain ← Data`, no API/storage in UI/Cubits), and task requirements into a temporary file named `.agy-brief.txt`.
   - Explicitly instruct the implementer inside `.agy-brief.txt` NOT to run `git commit`.

2. **Delegate to Antigravity (`gemini-3.8-flash-high`):**
   - Run the delegation relay command in the shell and wait for completion:
     ```bash
     node ~/.agents/skills/agy-delegate/scripts/relay.mjs --brief .agy-brief.txt --cd . --model "gemini-3.8-flash-high" --dangerously-skip-permissions
     ```

3. **Clean Up Temporary Brief:**
   - Immediately delete `.agy-brief.txt` after the relay finishes so the working tree only contains actual project changes.

4. **Verify, Fix if Needed, and Report:**
   - Read `result.json` from the relay output and inspect the actual `git status` and `git diff` against the approved plan.
   - Run `flutter analyze` and `flutter test` yourself and verify real results.
   - If Antigravity made a mistake or a check fails, either send a delta brief using `--resume-last` or apply minimal targeted fixes to make the gates pass.
   - Provide the final report required by Section 11.

## 11. Final Report (every task)

1. What changed and why.
2. Files created/modified/deleted.
3. Important technical decisions.
4. Commands that were **actually run** and their **real results** (`flutter analyze`, `flutter test`, builds).
5. What was not verified, manual checks still needed, deviations from the screenshots with reasons, remaining risks.

Never claim that code compiles, tests pass, an API works or a feature is complete without evidence. If a command fails, report the real error and investigate it.

## 12. Reference Screenshots

Location: `docs/design/reference/` (39 images + 1 video). Mapping:

| File | Screen |
|---|---|
| `01_mushaf_fatiha_first_page` | Mushaf first page with decorative surah header and page footer (juz/hizb) |
| `02_mushaf_page_text` | Regular mushaf page |
| `03_index_surahs_tab` | Index bottom sheet, "السور" tab, grouped by juz |
| `04_index_quarters_tab` | Index bottom sheet, "الأرباع" tab with progress circles |
| `05_reader_toolbar_and_player` | Reader with top toolbar and floating audio player |
| `06_khatma_new_menu` | New khatma menu (suggested / other) |
| `07_khatma_start_from` | "بدء الختمة من" options |
| `08_khatma_start_from_daily_wird` | "بدء الختمة من" with daily wird list |
| `09_khatma_program_picker` | Khatma program picker (2 months / month / week) |
| `10_khatma_empty_state` | Khatma tab empty state |
| `11_bookmarks_tab` | "الفواصل" tab with four colors and edit |
| `12_starred_empty` | "مميزة بنجمة" empty state |
| `13_notes_empty` | "الملاحظات" empty state |
| `14_khatma_programs_full_list` | Full khatma programs list |
| `15_search_results_keyboard` | Search with results |
| `16_today_ayah_sheet` | "اليوم" sheet: hijri/gregorian date and ayah of the day |
| `17_tafsir_mode` | Reader in tafsir mode with per-ayah cards |
| `18_reciter_picker` | Reciter picker (tafsir audio + recitations) |
| `19_ayah_options_sheet_half` | Ayah options sheet (half height) |
| `20_ayah_options_sheet_full` | Ayah options sheet (expanded) |
| `21_search_empty_keyboard` | Search empty state with keyboard |
| `22_play_to_sheet` | "تشغيل إلى…" sheet (ayat / pages / suras, stop options) |
| `23_khatma_reminder_time_picker` | Time picker dialog for the daily wird reminder (Arabic-Indic digits, AM/PM = ص/م) |
| `24_khatma_all_wirds_1_to_8` | "جميع الأوراد" list, days 1–8 (ranges, then surah names) |
| `25_khatma_all_wirds_22_to_29` | "جميع الأوراد" list, days 22–29 (grouped surah names) |
| `26_khatma_active_day3_completion` | Active khatma, day 3 ("بعد يومين"), completion confetti, reminder switch ON |
| `27_bookmarks_tab_with_data` | Bookmarks with data: time, surah:ayah, page; colored mushaf markers |
| `28_starred_list_with_data` | Starred ayat grouped by surah header |
| `29_note_editor_dialog` | Note editor dialog (add, share, close) with the ayah quoted + keyboard; ayah tints in mushaf |
| `30_notes_list_with_data` | Notes list grouped by surah with note text and "surah: ayah - page" |
| `31_khatma_active_day1` | Active khatma, day 1, reminder switch OFF, "جميع الأوراد 29", "حذف الختمة" |
| `32_khatma_program_picker_full_list` | "برنامج الختمة" full list: 240 … 3 days with daily-wird sublines |
| `33_khatma_all_wirds_19_to_29` | "جميع الأوراد" days 19–29 (complete the table with 35) |
| `34_library_edit_sheet` | "تحرير المكتبة": my library (reorder handle, red minus) + available books by language/category (green plus) |
| `35_khatma_all_wirds_1_to_18` | "جميع الأوراد" days 1–18 |
| `36_reciter_surahs_download` | Reciter page (opened from the info icon): surahs grouped by juz, per-surah cloud-download icon |
| `38_select_ayah_picker` | "اختيار الآية" picker (surah header, 'surah: n' rows with faded ayah text, green check on the selected one) |
| `39_select_ayah_picker_scrolled` | Same picker scrolled; selection on ayah 7 |
| `40_recitation_settings_sheet` | "إعدادات التلاوة": range from/to (opens the picker) and repeat range / repeat ayah with counters |
| `37_playback_follow_along_highlight` (video) | Playback: expanded player card, loading state, and the ayah highlight following the audio line by line |

Bottom navigation (5 tabs, RTL order): السور · الختمة · الفواصل · مميزة بنجمة · الملاحظات.

## 13. Delivery Checklist

- [ ] Follows the approved architecture (Clean, Feature-First) and mandatory technologies.
- [ ] No unauthorized dependencies, backends, endpoints or unverified assumptions.
- [ ] No business logic in UI; no duplicated services/helpers.
- [ ] Loading / success / empty / failure states handled where applicable.
- [ ] No hardcoded colors/strings; RTL verified; matches the reference screenshots.
- [ ] `flutter analyze` and the full `flutter test` suite were run after the task, with their real results reported (unless the task was explicitly analysis/research-only and changed no files).
- [ ] Final diff reviewed; relevant checks run or the reason they were not run is stated.
- [ ] No claim of success for checks that were not executed.

**Final rule:** inspect first, follow existing approved decisions, ask when information is missing, and never replace this approach with your own preferences.


## 14. Owner Decisions Log (binding)

| Date | Decision |
|---|---|
| 2026-11-01 | Full rebuild on Clean Architecture; Quran only; Arabic RTL only. |
| 2026-11-01 | `qcf_quran_plus` replaces `quran-1.2.2` and fonts `QCF_P001`…`QCF_P604` (+ `assets/fonts/v2woff`), executed only in task 1.07. |
| 2026-11-01 | Cancelled features: word meanings, audio tafsir ("المختصر الصوتي"). Remove them from the reciter picker and the library sheet. |
| 2026-11-01 | Release identity: Android `applicationId` = `com.quran.ayaatquranmajeed`, already the Google Play listing id; the owner changed it locally but has not pushed it yet, so verify the real state of the project before touching it (iOS bundle id still to be confirmed by the owner). A signing key already exists; never commit keystores or `key.properties`. |
| 2026-11-01 | Al-Mukhtasar replaced by Al-Tafsir Al-Muyassar (bundled file). The reciter info icon opens a per-reciter page listing surahs grouped by juz with a download button per surah (screenshot 36). Playback highlights the playing ayah line by line (video 37). |
| 2026-11-01 | Player: the '...' button opens "إعدادات التلاوة" (screenshot 40). The return arrow with a number appears after the user drags the page slider and jumps back to the page where the drag started (the number is that page). In the reciter surahs page a downloaded surah shows a green check mark instead of the cloud icon. Keyword highlighting in tafsir (red words) is NOT required. |
| 2026-11-01 | Security: the legacy `AudioPlayerRemoteDataSource` contains a hardcoded Google Custom Search API key (used only to fetch reciter photos, a feature that is not in the screenshots). The photo feature is removed, the key must not be copied anywhere, and the owner should revoke/rotate it in Google Cloud. |
| 2026-11-01 | Approved defaults (task 0.03): bookmarks edit mode = delete a bookmark with an X (no reordering); "another bookmark…" = small dialog for name and extra color; the plus-circle in the note editor = add another note on the same ayah (confirm at GATE 1); relative label ("بعد يومين") = difference between the wird's scheduled date and today; a single active khatma only; settings = mushaf text size if supported by the package, keep screen awake, sources and licenses; Hijri = Umm al-Qura with a manual ±1 day adjustment; share = text + image card. |

### Khatma 29-day table (from screenshots 24, 33, 35; verify every row against the images)

1: Al-Fatihah → Al-Baqarah 141 · 2: Al-Baqarah 142 → 252 · 3: Al-Baqarah 253 → Aal-Imran 92 · 4: Aal-Imran 93 → An-Nisa 35 · 5: An-Nisa 36 → end of An-Nisa · 6: Al-Ma'idah · 7: Al-An'am · 8: Al-A'raf · 9: Al-Anfal → At-Tawbah 72 · 10: At-Tawbah 73 → end of Yunus · 11: Hud → Yusuf 57 · 12: Yusuf 58 → end of Ibrahim · 13: Al-Hijr & An-Nahl · 14: Al-Isra & Al-Kahf · 15: Maryam & Ta-Ha · 16: Al-Anbiya & Al-Hajj · 17: Al-Mu'minun & An-Nur · 18: Al-Furqan & Ash-Shu'ara · 19: An-Naml & Al-Qasas · 20: Al-Ankabut, Ar-Rum, Luqman & As-Sajdah · 21: Al-Ahzab, Saba & Fatir · 22: Ya-Sin, As-Saffat & Sad · 23: Az-Zumar & Ghafir · 24: Fussilat, Ash-Shura, Az-Zukhruf & Ad-Dukhan · 25: Al-Jathiyah, Al-Ahqaf, Muhammad, Al-Fath & Al-Hujurat · 26: Qaf → Al-Hadid · 27: Al-Mujadila → At-Tahrim · 28: Al-Mulk → Al-Mursalat · 29: An-Naba → An-Nas.
