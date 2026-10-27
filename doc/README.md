# Documentation

One topic per file. Read the line, open the file you need.

## Start here

- [Getting started](getting_started.md): rename the starter into your app, set `.env`, run it, the optional Firebase setup, everyday commands.
- [Architecture](architecture.md): layers, who may import whom, composition points, start-up order.
- [Project structure](project_structure.md): every folder, and where a new file goes.
- [Conventions](conventions.md): naming, imports, screens and widgets, cubits, loading UI, copy, theme, commits.
- [Adding a module](adding_a_module.md): one feature from entity to screen, step by step.
- [Upgrading](upgrading.md): moving to newer Flutter and packages; what is held back and why.
- [Using Claude Code](using_claude_code.md): `CLAUDE.md`, skills, subagents, hooks and loops set up for this starter.

## Core (always present)

- [Network](core/network.md): `RemoteService`, token refresh, retries, error messages, the backend shape it expects.
- [Theme](core/theme.md): ColorScheme-first theming, presets, dynamic color, typography.
- [Routing](core/routing.md): routes, arguments, where a route guard goes, asset paths (`AssetRoutes`).
- [Dependency injection](core/dependency_injection.md): get_it + injectable, when to run build_runner.
- [Storage](core/storage.md): Hive boxes, secure storage, the cache-first load flow.
- [Errors and messages](core/errors_and_messages.md): exceptions, toasts, dialogs, popup loader, error views.
- [Permissions](core/permissions.md): asking for permissions and the native keys each needs.
- [Sizing and fonts](core/sizing_and_fonts.md): flutter_scale_kit, text scale, per-locale fonts.
- [Utilities](core/utilities.md): constants, `.env` keys, extensions, helpers, services, shared widgets.

## Modules (optional, each removable)

- [Module catalog](modules/README.md): what each module does, what it depends on, how to remove it.
