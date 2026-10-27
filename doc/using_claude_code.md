# Using Claude Code

How to set up [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) for an app made from this starter, so it writes code that follows the starter's conventions, checks its own work and spends few tokens doing it. It follows the practices in [How to Use Claude Code to Build Flutter Apps Faster](https://www.freecodecamp.org/news/how-to-use-claude-code-to-build-flutter-apps-faster-best-practices/) (freeCodeCamp, 2026) and adapts them to this starter.

The article's main point: what you set up around the assistant matters more than how you word a prompt. The setup has five parts, in order of payoff: a consistent architecture, a short `CLAUDE.md`, skills for repeated tasks, subagents for parallel work, and hooks that enforce the rules. The starter already has the first; steps 1 to 5 below add the rest, and loops on top.

## What the starter already gives an assistant

- **One shape for every feature.** Each module in `lib/modules/` has the same layers and barrels ([project structure](project_structure.md)), so "do it like `lib/modules/device_info/`" is a complete instruction.
- **Written rules.** [Conventions](conventions.md) covers names, imports, screens, cubits, loading states and copy. The assistant follows rules it can read; it can't follow rules that live only in your head.
- **A worked recipe.** [Adding a module](adding_a_module.md) walks one feature from entity to screen.
- **One topic per page.** The [index](README.md) lets the assistant open only the page a task needs instead of reading everything. That is where most of the token saving comes from.
- **Commands that judge the work**: `flutter analyze` (kept clean) and `flutter test`.

## Step 1: Add `CLAUDE.md`, the rules loaded every session

Claude Code reads `CLAUDE.md` at the project root at the start of every session, and its text counts against every turn. Keep it short: what to read, the commands, the rules, the don'ts. Details belong in `doc/`, which it opens when needed. A starting point (replace the first line with your app):

```markdown
# my_app

Flutter 3.47 / Dart 3.13 app from flutter_starter. BLoC (SafeCubit), get_it + injectable, go_router, Dio (`RemoteService`), Hive, flutter_scale_kit, Material 3. Feature modules in `lib/modules/`, each removable.

## Read before you change code

The docs are one topic per file; open only what the task needs. Index: `doc/README.md`.
- Any feature work: `doc/conventions.md` (names, imports, screens, cubits, loading UI) and `doc/adding_a_module.md`.
- Network or auth: `doc/core/network.md`, `doc/modules/auth.md`.
- A module: `doc/modules/<module>.md`.
Then read the neighbouring feature and mirror it.

## Commands

- `flutter pub get`
- `dart run build_runner build` after adding/renaming/removing an `@injectable` / `@LazySingleton` class
- `flutter analyze` (must be clean before you finish)
- `dart format lib test`
- `flutter test`

## Rules

- Import barrels only (`core/core.dart`, `common/common.dart`, `modules/<x>/<x>.dart`; inside a module, the nearest layer barrel).
- `<Name>Screen` (stateless, provides blocs + listeners) + `<Name>View` in `presentation/views/<name>_screen.dart`; one widget per file; no `_buildX()` helpers.
- Cubits extend `SafeCubit`; `load()` / `refresh()` / `loadMore()`; state = `loadingState` + data + `error`.
- No spinners for loading: skeletons, `ErrorView`, popup loader for submits. Toasts via `CustomSnackbar.show`, errors via `AppErrorHandler.getErrorMessage`.
- Copy in `utils/constants/<feature>_strings.dart` / `_error.dart`. Colors from `context.colorScheme`.
- `core/` never imports a module (the router is the only exception).

## Do not

- Edit generated files: `lib/core/di/injection.config.dart`, `*.g.dart`.
- Add a package without asking.
- Run `flutter build`, `flutter run`, `pod install` or `xcodebuild`: the owner builds.
```

## Step 2: Add skills for the tasks you repeat

A skill is `.claude/skills/<name>/SKILL.md`: front matter with a `name` and a `description`, then the steps. Claude Code picks a skill when your request matches its description, and you can call one directly with `/<name>`. Four that fit the starter:

`.claude/skills/new-module/SKILL.md`

```markdown
---
name: new-module
description: Create, add, scaffold or build a new feature module (entity, model, mapper, repository, use cases, cubit, screen) in lib/modules following the project conventions.
---

# New module

1. Read `doc/conventions.md` and `doc/adding_a_module.md`. Ask for the API contract (endpoints, JSON) if it isn't given; don't invent fields.
2. Create `lib/modules/<feature>/` with only the folders you need, each with its barrel.
3. Write, in order: entity → model (five JSON members + copyWith) → mapper (ten functions) → `utils/constants/<feature>_api_route.dart`, `_strings.dart`, `_error.dart` → abstract repository → `Remote<Feature>RepositoryImpl` (`@Injectable(as: ...)`, `RemoteService`, `ApiResponseEnvelope`, pagination via `PaginationHelper`/`PaginationMapper`) → use cases with `<UseCase>Params` → `SafeCubit` with `load`/`refresh`/`loadMore` → `<Name>Screen` + `<Name>View` + widgets + skeleton with `k<Subject>SkeletonDummy`.
4. Add the route in `lib/core/router/routes.dart` and `app_router.dart`; a Hive box in `lib/app/hive_bootstrap.dart` if the module stores data.
5. `dart run build_runner build`, then `flutter analyze` until clean.
6. Write `doc/modules/<feature>.md` (What it provides, Depends on, Setup, Use, Remove, Hidden details) and add a row to `doc/modules/README.md`.
```

`.claude/skills/remove-module/SKILL.md`

```markdown
---
name: remove-module
description: Remove, delete or drop an optional module (ads, fcm, notifications, auth, qr, onboarding, ...) from the app cleanly.
---

# Remove a module

1. Open `doc/modules/<module>.md` and follow its **Remove** section exactly.
2. Check the module catalog (`doc/modules/README.md`) for modules that depend on this one; remove or rewire them first.
3. `grep -rn "modules/<module>/" lib` must return nothing.
4. Remove the packages only that module used from `pubspec.yaml`, its native keys, its `.env` keys.
5. `flutter pub get`, `dart run build_runner build`, `flutter analyze` until clean.
6. Remove the module's doc page and its catalog row.
```

`.claude/skills/check/SKILL.md`

```markdown
---
name: check
description: Check, verify, lint, analyze or fix the project until flutter analyze and tests are clean.
---

# Check

Loop until both are clean, at most 5 rounds; stop and report if the same error survives two rounds.

1. `flutter pub get` (only if pubspec.yaml changed).
2. `dart run build_runner build` (only if an annotated class changed).
3. `flutter analyze`. Fix errors first, then warnings, then infos. Never silence a lint with an ignore unless the code explains why.
4. `flutter test` (only the affected test files for small changes).
5. Report what was fixed and anything left.
```

`.claude/skills/commit/SKILL.md`

```markdown
---
name: commit
description: Commit the current changes with a conventional commit message after the project passes flutter analyze.
---

# Commit

1. `flutter analyze`. If it reports errors, fix them first or stop and say why.
2. `git status` and `git diff --stat`; never stage `.claude/`, `CLAUDE.md`, `.env` or build output.
3. One commit per logical step. Message: `type(scope): summary` (feat, fix, refactor, chore, docs, test, perf; scope = module), imperative, at most 72 characters, a short body when the why isn't obvious.
4. Commit with the configured git identity. No co-author or tool attribution lines.
```

## Step 3: Add a subagent for parallel work

A subagent is `.claude/agents/<name>.md`: front matter (`name`, `description`, optional `tools`) and its instructions. It runs in a fresh context and returns only a summary, so the main session stays small. Several can run at once on separate screens. Give each one its own files: two agents editing the same barrel or route file at the same time overwrite each other.

`.claude/agents/screen-builder.md`

```markdown
---
name: screen-builder
description: Builds one screen (Screen + View + widgets + skeleton) for an existing module's cubit, following the project's presentation conventions. Use for parallel UI work on separate screens.
tools: Read, Write, Edit, Glob, Grep, Bash
---

You build exactly one screen in this Flutter project.

1. Read `doc/conventions.md` (Presentation section) and one existing screen in the same module, or `lib/modules/auth/` if there is none.
2. `presentation/views/<name>_screen.dart`: `<Name>Screen` (StatelessWidget: BlocProvider + BlocListener for loader / toast / navigation) and `<Name>View` (the UI). One widget per file in `presentation/widgets/`; no `_buildX()` helpers.
3. Loading: skeleton (`<Subject>Skeleton` + `k<Subject>SkeletonDummy`), `ErrorView` on failure with nothing shown, toast on failure with data shown, popup loader for submits.
4. Copy in `utils/constants/<feature>_strings.dart`; colors from `context.colorScheme`; sizes with flutter_scale_kit.
5. Import barrels only; update every barrel you touch.
6. `flutter analyze` on your files until clean. Don't run build_runner, flutter run or builds; don't edit other modules.
7. Reply with the files you created and anything the caller must wire (route, provider).
```

A typical flow from the article: write the entity, repository and cubit yourself (or with one session), then ask for the screens with one `screen-builder` each, then run the `check` skill and the `commit` skill.

## Step 4: Add hooks, rules that don't depend on the model

Hooks are shell commands Claude Code runs at fixed points, configured in `.claude/settings.json` (shared) or `.claude/settings.local.json` (yours only). A command that exits with code 2 blocks the action, and what it prints to stderr goes back to Claude. Two hooks fit the starter: refuse edits to generated files, and refuse to finish while `flutter analyze` reports problems. They need `jq`.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r \".tool_input.file_path // empty\"); case \"$f\" in *.g.dart|*injection.config.dart|*.freezed.dart) echo \"Generated file: change the source and run dart run build_runner build\" >&2; exit 2;; esac; exit 0"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if jq -e \".stop_hook_active == true\" >/dev/null; then exit 0; fi; if ! flutter analyze --no-pub >/dev/null 2>&1; then echo \"flutter analyze is not clean: fix it before finishing\" >&2; exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

The `stop_hook_active` check stops the second hook from looping: once Claude is already continuing because of it, the hook lets it finish. The article's own hook JSON has broken escaping; test any hook by piping sample input into its command before relying on it, for example `echo '{"tool_input":{"file_path":"lib/core/di/injection.config.dart"}}' | sh -c '<command>'; echo $?` should print the message and `2`.

## Step 5: Use loops so it corrects itself

`/loop` repeats a prompt until a stop condition, which suits work with an objective check. From the article:

- "Run `flutter analyze`, fix what it reports, repeat until there are no issues."
- "Run `flutter test test/modules/notes/`, fix the failing test, repeat until it passes."
- "Build the next screen of the notes module, analyze it, stop after three screens."

Always give the stop condition; without one a loop runs on.

## Spending fewer tokens

- Name the files: "the cubit in `lib/modules/notes/presentation/bloc/notes/`" costs less than "find where notes are loaded".
- Point at a neighbour to mirror instead of explaining the pattern.
- One module per session; start a new session (or `/compact`) when you switch.
- Keep `CLAUDE.md` short. It is read on every turn, so a long one costs you on every turn.
- Let analyze and tests judge the work rather than asking for explanations of it.
- Use subagents for broad reading ("which modules use `UrlHelper`?") so the file contents stay out of the main session.

## Keep these files to yourself, or share them

The starter's `.gitignore` keeps them out of git, in its "Claude Code (local-only)" section: `.claude/`, `*.claude` and `CLAUDE.md`. To share them with your team, remove those lines, and put personal settings in `.claude/settings.local.json`, which Claude Code doesn't expect you to commit. Never put secrets in any of these files.

## What the starter doesn't take from the article

- **Riverpod and Freezed**: the starter uses BLoC and hand-written models; the conventions describe those.
- **`--delete-conflicting-outputs`**: build_runner 2.7+ always deletes conflicting outputs, so the flag isn't needed.
- **Money as `int`**: a good rule, but the starter has no money to store. Apps made from it should follow it (the BSMM shop app keeps paisa as `int`).
