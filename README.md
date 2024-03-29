# rails-bin

A collection of scripts for working with Rails

## `bin/`

### `check-changelogs`

Lints CHANGELOG files for common issues:

- missing authors
- trailing whitespace
- incorrect leading whitespace

It's currently running on [Rails PRs][] and daily in this repo

[Rails PRs]: https://github.com/rails/rails/commit/a4770968ef5c2e7bcccb4706f3c809d2a8912638

### `check-config-docs`

Ensures that `config.*` values defined in `Rails::Application::Configuration`
are documented in `configuring.md`

It's currently running daily in this repo

### `check-links`

Ensures that API docs and guides do not link to edge{guides,api}

### `regen-dummy`

Updates Rails' framework dummy apps by regenerating templated files
