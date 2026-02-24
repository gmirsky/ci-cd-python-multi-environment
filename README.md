# ci-cd-python-multi-environment

Repository pattern for branch-based environments:

- `development` branch: active development environment
- `qa` branch: QA/staging validation environment
- `main` branch: production environment

Each branch can pin and run a different Python version.

## Suggested Python versions by branch

- `development`: Python `3.14.3`
- `qa`: Python `3.14.3`
- `main`: Python `3.14.2`

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

These promotion workflows also use environment approval gates:

- `promote-to-qa` for `development -> qa`
- `promote-to-production` for `qa -> main`

Configure required approvers in GitHub:

1. Go to **Settings -> Environments**
2. Create/update `promote-to-qa` and `promote-to-production`
3. Add at least one **Required reviewer** to each environment

Until approved, promotion jobs remain blocked.

## CI workflow

- `.github/workflows/ci-test.yml`

This workflow runs `pytest` on pushes and pull requests for `development`, `qa`, and `main` using branch-appropriate Python versions.

## Local helper commands

- `make test` to run local tests
- `make docker-buildx` to build multi-platform image (`linux/amd64,linux/arm64`)
- `make docker-buildx-load` to build and load single-platform (`linux/amd64`) image into local Docker

Optional overrides:

- `make docker-buildx IMAGE=myrepo/hello-world:dev`
- `make docker-buildx PLATFORMS=linux/arm64`

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

## Manual promotion commands (outside PR workflows)

Use these commands when you want to promote changes without opening PRs.

### Cherry-pick specific commits

Promote commits `7b74141` and `388c03d` from `development` to `qa`:

```bash
cd /Users/gregorymirsky/code/ci-cd-python-multi-environment
git fetch origin
git checkout qa
git pull --ff-only origin qa
git cherry-pick 7b74141 388c03d
git push origin qa
```

Promote the same commits from `development` to `main`:

```bash
git checkout main
git pull --ff-only origin main
git cherry-pick 7b74141 388c03d
git push origin main
```

### Promote full branches (no PR)

Promote all changes from `development` to `qa`:

```bash
git fetch origin
git checkout qa
git pull --ff-only origin qa
git merge --no-ff origin/development -m "Promote development to qa"
git push origin qa
```

Promote all changes from `qa` to `main`:

```bash
git checkout main
git pull --ff-only origin main
git merge --no-ff origin/qa -m "Promote qa to production"
git push origin main
```

### If conflicts occur

```bash
git status
# resolve files manually, then:
git add <files>
```

Continue or abort as needed:

```bash
git cherry-pick --continue   # or git merge --continue
git cherry-pick --abort      # or git merge --abort
```
