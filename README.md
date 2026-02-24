# ci-cd-python-multi-environment

Repository pattern for branch-based environments:

- `development` branch: active development environment
- `qa` branch: QA/staging validation environment
- `main` branch: production environment

Each branch can pin and run a different Python version.

## Suggested Python versions by branch

- `development`: Python `3.11`
- `qa`: Python `3.12`
- `main`: Python `3.13`

Use branch-specific `.python-version` files (or branch-specific CI config) to enforce the interpreter per environment branch.

Version mapping files in this repo:

- `environments/development.python-version`
- `environments/qa.python-version`
- `environments/main.python-version`

## Development app and tests

This repository includes a simple Hello World Python app and tests intended for the `development` branch:

- App: `src/hello_world.py`
- Tests: `tests/test_hello_world.py`

## Container build

A multi-stage `Dockerfile` is included using Chainguard Python images and supports multi-platform builds (`linux/amd64`, `linux/arm64`) when built with Buildx.

Example:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t hello-world:latest \
  .
```

## Promotion workflows

- `.github/workflows/promote-development-to-qa.yml`
- `.github/workflows/promote-qa-to-production.yml`

Each promotion workflow creates a PR from source environment branch to target branch.

## CI workflow

- `.github/workflows/ci-test.yml`

This workflow runs `pytest` on pushes and pull requests for `development`, `qa`, and `main` using branch-appropriate Python versions.

## Refresh workflow

- `.github/workflows/refresh-development-from-production.yml`

This workflow is manually triggered and force-updates `development` from `main`, overlaying all existing code in `development`.

## Recommended branch protection

Apply these settings in GitHub for stronger promotion controls:

### `main` (production)

- Require a pull request before merging
- Require at least `1` approving review
- Dismiss stale pull request approvals when new commits are pushed
- Require conversation resolution before merging
- Require status checks to pass before merging (`tests`)
- Restrict direct pushes to `main`
- (Optional) Restrict who can push/merge to release maintainers

### `qa` (staging)

- Require a pull request before merging
- Require at least `1` approving review
- Require conversation resolution before merging
- Require status checks to pass before merging (`tests`)
- Restrict direct pushes to `qa`

### Notes

- Promotion workflows in this repo open PRs (`development -> qa`, `qa -> main`) and are compatible with protected branches.
- The refresh workflow force-pushes `development`; keep `development` less restrictive than `qa` and `main` to allow reset/refresh operations.
