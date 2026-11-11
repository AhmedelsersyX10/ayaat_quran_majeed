# AGENTS.md — Ayaat Quran App

> Mandatory instructions for every coding agent working in this repository.
> **Read this file in full before starting ANY task.** These rules are the owner's requirements, not suggestions.
> If a rule conflicts with a real project constraint, explain the conflict and propose a solution BEFORE changing approach.
> Never claim something about the project (a library, a file, an endpoint) before verifying it in the actual files.

---

## Global Contract & References

This project is governed by the **Flutter Engineering Contract** at `~/.gemini/AGENTS.md` (version 1.0.0).
Read that contract before this file. The rules below are project-specific additions and overrides only;
they do not repeat the global contract's general guidance.

Kit references live at `~/.gemini/config/references/flutter-engineering/`.
No project-local copy exists under `.agents/references/`; use the global path.

| Task concern | Reference |
| --- | --- |
| Delegation, approvals, handoffs, review outcomes | `workflow.md` |
| Feature structure, contracts, DI, refactor | `architecture.md` |
| Cubit/Bloc, async, routes, resource ownership | `state-navigation.md` |
| HTTP, auth, cache, downloads, sync, migrations | `data-offline.md` |
| UI, design system, localization, accessibility | `ui-localization.md` |
| Tests, debugging, performance, review evidence | `quality.md` |
| Secrets, privacy, dependencies, platform/release | `security-release.md` |

---

## 1. Project Goal

Rebuild the existing Flutter app `ayaat_quran_majeed` into a **pixel-faithful replica** of the 39 reference screenshots and the playback video in `docs/design/reference/` (see §12).

- **Scope: Quran reader only.** Everything not visible in the reference screenshots (azkar, qibla, tasbeeh, prayer times, etc.) is **out of scope and must be removed** during the cleanup task, including their unused assets and dependencies. The only notification feature in scope is the **daily khatma reminder** (screenshots 23, 26, 31).
- **Language:** Arabic only, RTL only for now. Light theme only unless a task says otherwise.
- **Architecture (owner-approved):** full rebuild on Clean Architecture, Feature-First, while **preserving the Quran data and audio capabilities**.
- **Quran engine (owner-approved):** the local `quran-1.2.2` package and the 604 per-page font families `QCF_P001`…`QCF_P604` (plus `assets/fonts/v2woff`) are **replaced by `qcf_quran_plus` (pinned `0.1.1`)** — page rendering, QCF font loading via `QcfFontLoader`, metadata, search, highlights. Adoption and removal of old fonts/package happen in **task 1.07 only**, after parity is verified. Quran text must never be modified.
- **Content sources (owner decisions, 2026-11-01):** word meanings and audio tafsir are **cancelled** (do not build them). **Default tafsir: Al-Tafsir Al-Muyassar** (replaces Al-Mukhtasar everywhere in the screenshots). Tafsir books: bundled `muyassar.dart` and `sahih_english.dart`, plus downloadable books listed in `lib/quran/data/data_sources/translation/translationdata.dart` (remote JSON from `noureddin/Quran-App-Data`; links verified by owner; license/terms must be recorded in the About section).
- **Audio:** mp3quran.net API v3 (reciters, suwar, moshaf, whole-surah files) + `ayat_timing` endpoints for ayah timing (verify real responses in task 0.01). Must support per-surah offline download and ayah-level timing for the follow-along highlight (screenshot 36 and video 37).
- **Khatma:** 29-day table transcribed from screenshots 24, 33, 35. Never invent endpoints, response fields, or data.

---

## 2. Mandatory Workflow

1. **Understand → Plan → Implement.** Inspect `pubspec.yaml`, entry points, routing, state management, DI, and task-relevant files before writing code.
2. For any non-trivial task use the **two-gate flow** (GATE 1: plan + stop for approval; GATE 2: implement + verify). Full protocol in `workflow.md`.
3. Work in small reviewable steps. After each important step summarize what is done and what is next.
4. Do not guess APIs, backends, data models, or undocumented behavior. Name missing information first and ask.
5. Do not create files, layers, or services "just in case". Create only when needed.
6. If the owner asks for analysis only, **do not modify files**. Separate verified findings from hypotheses.
7. **Mandatory completion checks** (every task that changes the repository):
   ```
   flutter analyze
   flutter test
   ```
   Run from the repository root. Targeted tests are additional, not a replacement. If either fails, investigate and report the real failure before claiming completion. Exception: explicitly analysis-only tasks that change no files — state this applies in the final report.

---

## 3. Architecture

**Clean Architecture, Feature-First.** Dependency flow: `Presentation → Domain ← Data`.

Feature build order (skip a layer only with a clear reason):
`Model/Entity → Data Source/Service → Repository → Use Case → Cubit → UI`

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

Shared code goes to `core/` only when genuinely cross-feature.

**Planned features** (names are guidance, confirm in each task):
`mushaf` · `index` · `search` · `audio` · `tafsir` · `khatma` · `bookmarks` · `starred` · `notes` · `today` · `settings`

See `architecture.md` for layer contracts, DI patterns, and refactor rules.

---

## 4. Mandatory Technology Choices

| Concern | Choice | Rules |
| --- | --- | --- |
| State | `flutter_bloc` (Cubit; Bloc only with clear justification) | One Cubit per clear scope. No GetX/Provider/Riverpod. `setState` only for tiny local UI state. Explicit loading / success / empty / failure states. |
| Routing | `go_router` | Routes declared in one place (`core/routing`). Pass ids, not large objects. No navigation from data/domain layers. |
| DI | `get_it` | Registrations in `core/di`. Never create dependencies manually inside widgets. Provide Cubits via `BlocProvider` at the narrowest scope. |
| Network | `Dio` | One shared client config (baseUrl, timeouts, headers, error mapping). Handle offline, timeout, non-2xx, malformed data. |
| Local storage | `SharedPreferences` for simple settings; `Hive` for structured data (bookmarks, notes, khatma, starred, cached content) | Always behind a data source/service. Never from UI or Cubit directly. |
| Responsive UI | `flutter_screenutil` | Avoid fixed sizes. Verify on 360dp, ≈392dp, and tablet widths with large font scale. |
| Localization | `easy_localization` | No hardcoded user-visible strings in widgets. All text from translation files. RTL verified. |
| Quran engine | `qcf_quran_plus` pinned `0.1.1` | Used only through our own wrappers/interfaces in the data layer; UI may use its `QuranPageView` builders. Do not override `ayahStyle` unless the task says so. Initialize fonts during startup/splash. |
| Notifications | `flutter_local_notifications` + `timezone` | Only for the daily khatma reminder. Handle permission, exact-alarm limits, reboot, and time-zone changes. |
| Models | Native Dart | Do **not** add Freezed / `build_runner` automatically. |

**SDK constraint:** `>=3.11.0 <4.0.0`.

Do not replace a technology with your own preference. Do not add a dependency without necessity and owner authorization.

---

## 5. UI Fidelity Rules (core of this project)

- The reference screenshots in `docs/design/reference/` are the **source of truth**. Match layout, spacing, typography, colors, radii, icons, states, and RTL alignment exactly.
- All visual values live in **design tokens** (`core/theme`): colors, text styles, spacing, radii. Features use `Theme.of(context)` / theme extensions. **No hardcoded colors or magic numbers inside feature widgets.**
- Use `flutter_screenutil` consistently. Verify on small (360dp), normal (≈392dp), and large (tablet) widths, and with large system font scale.
- Split screens into small widgets with clear responsibility. Use `const` where possible. No heavy objects or controllers created inside `build()`. Dispose controllers, focus nodes, streams, and audio resources correctly.
- Place `BlocBuilder` / `BlocSelector` at the smallest scope that needs the update.
- If a screenshot is ambiguous or a detail cannot be inferred, **ask the owner**; do not invent a design decision.
- Anything visible in the screenshots that needs backend/data support not yet verified must be reported at GATE 1, not guessed.
- Deviations from the screenshots must be listed in the final report with reasons.

---

## 6. Quran-Specific Rules

- Quranic text correctness is critical: **never alter, normalize, or "fix"** Quran text, verse numbering, page mapping, or tashkeel without an explicit task and owner approval.
- Keep the 604-page mushaf layout working through `qcf_quran_plus`. Follow font-loading guidance (startup initialization + page preloading); measure startup time and memory.
- Audio: handle buffering, errors, interruptions (calls, headphones unplugged), background playback, and resource disposal.
- Any religious content source (tafsir, translation) must be **attributed correctly** in the UI/About area and verified for licensing/terms before use.

---

## 7. Code Quality & Change Discipline

- Write clear, direct, maintainable Dart. Meaningful names, no `dynamic`, no `!` just to silence the analyzer.
- Convert external errors to a feature-appropriate `Failure`/result. Never show `Exception.toString()` to users. No empty `catch`. Consistent result contract within a feature.
- Tests cover business logic, repositories, and Cubits: success, failure, empty, and important edge cases. Tests must not depend on the real network or real time.
- Make the **smallest correct change** that satisfies the task. Do not refactor files unrelated to the task.
- Run `git status` and `git diff` before broad changes. Never discard the owner's uncommitted work.
- Do not run `flutter clean` or delete build output unless evidence supports it (not a routine step).
- No `dependency_overrides` without a documented reason. No manual edits to `pubspec.lock`.

---

## 8. Reference Screenshots

Location: `docs/design/reference/` (39 images + 1 video).

| File | Screen |
| --- | --- |
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
| `38_select_ayah_picker` | "اختيار الآية" picker (surah header, 'surah: n' rows with faded ayah text, green check on selected) |
| `39_select_ayah_picker_scrolled` | Same picker scrolled; selection on ayah 7 |
| `40_recitation_settings_sheet` | "إعدادات التلاوة": range from/to (opens the picker) and repeat range / repeat ayah with counters |
| `37_playback_follow_along_highlight` (video) | Playback: expanded player card, loading state, and the ayah highlight following the audio line by line |

**Bottom navigation** (5 tabs, RTL order): السور · الختمة · الفواصل · مميزة بنجمة · الملاحظات.

---

## 9. Delivery Checklist

- [ ] Follows the approved architecture (Clean, Feature-First) and mandatory technologies.
- [ ] No unauthorized dependencies, backends, endpoints, or unverified assumptions.
- [ ] No business logic in UI; no duplicated services/helpers.
- [ ] Loading / success / empty / failure states handled where applicable.
- [ ] No hardcoded colors or strings; RTL verified; output matches the reference screenshots.
- [ ] `flutter analyze` and `flutter test` run from repository root; real results reported.
- [ ] Final diff reviewed; deviations from screenshots listed with reasons.

Follow the implementation handoff and review contract formats in `workflow.md`.

---

## 10. Owner Decisions Log (binding)

| Date | Decision |
| --- | --- |
| 2026-11-01 | Full rebuild on Clean Architecture; Quran only; Arabic RTL only. |
| 2026-11-01 | `qcf_quran_plus 0.1.1` replaces `quran-1.2.2` and fonts `QCF_P001`…`QCF_P604` (+ `assets/fonts/v2woff`), executed only in task 1.07. |
| 2026-11-01 | Cancelled features: word meanings, audio tafsir ("المختصر الصوتي"). Remove from reciter picker and library sheet. |
| 2026-11-01 | Release identity: Android `applicationId = com.quran.ayaatquranmajeed` (Google Play listing id; owner changed it locally but had not pushed — verify before touching). iOS bundle ID still to be confirmed by the owner. A signing key already exists; never commit keystores or `key.properties`. |
| 2026-11-01 | Al-Mukhtasar replaced by Al-Tafsir Al-Muyassar (bundled). The reciter info icon opens a per-reciter page listing surahs grouped by juz with a download button per surah (screenshot 36). Playback highlights the playing ayah line by line (video 37). |
| 2026-11-01 | Player: the '...' button opens "إعدادات التلاوة" (screenshot 40). The return arrow with a number appears after the user drags the page slider and jumps back; the number is that page. A downloaded surah shows a green check mark instead of the cloud icon. Keyword highlighting in tafsir (red words) is NOT required. |
| 2026-11-01 | Security: the legacy `AudioPlayerRemoteDataSource` contains a hardcoded Google Custom Search API key (reciter photos — not in scope). The photo feature is removed; the key must not be copied anywhere; the owner should revoke/rotate it in Google Cloud. |
| 2026-11-01 | Approved defaults (task 0.03): bookmarks edit mode = delete with X (no reorder); "another bookmark…" = small dialog for name and extra color; plus-circle in note editor = add another note on same ayah (confirm at GATE 1); relative label ("بعد يومين") = difference between wird scheduled date and today; single active khatma only; settings = mushaf text size (if supported by package), keep screen awake, sources and licenses; Hijri = Umm al-Qura ±1 day manual adjustment; share = text + image card. |

### Khatma 29-day table (from screenshots 24, 33, 35 — verify every row against the images)

1: Al-Fatihah → Al-Baqarah 141 · 2: Al-Baqarah 142 → 252 · 3: Al-Baqarah 253 → Aal-Imran 92 · 4: Aal-Imran 93 → An-Nisa 35 · 5: An-Nisa 36 → end of An-Nisa · 6: Al-Ma'idah · 7: Al-An'am · 8: Al-A'raf · 9: Al-Anfal → At-Tawbah 72 · 10: At-Tawbah 73 → end of Yunus · 11: Hud → Yusuf 57 · 12: Yusuf 58 → end of Ibrahim · 13: Al-Hijr & An-Nahl · 14: Al-Isra & Al-Kahf · 15: Maryam & Ta-Ha · 16: Al-Anbiya & Al-Hajj · 17: Al-Mu'minun & An-Nur · 18: Al-Furqan & Ash-Shu'ara · 19: An-Naml & Al-Qasas · 20: Al-Ankabut, Ar-Rum, Luqman & As-Sajdah · 21: Al-Ahzab, Saba & Fatir · 22: Ya-Sin, As-Saffat & Sad · 23: Az-Zumar & Ghafir · 24: Fussilat, Ash-Shura, Az-Zukhruf & Ad-Dukhan · 25: Al-Jathiyah, Al-Ahqaf, Muhammad, Al-Fath & Al-Hujurat · 26: Qaf → Al-Hadid · 27: Al-Mujadila → At-Tahrim · 28: Al-Mulk → Al-Mursalat · 29: An-Naba → An-Nas.
