# claude-skills

## Versioning

- Semver (MAJOR.MINOR.PATCH) on trunk-based dev
- All work merges to `main` via PR
- Releases are tagged via GitHub Actions workflow dispatch (`Actions > Release > Run workflow`)
- Release notes are auto-generated from PR titles since the last tag

## Structure

```
skills/         Skill definitions (*.md)
.github/        GitHub Actions workflows
```

## Git Workflow

- Branch from `main`, PR back to `main`
- Keep PRs focused — one logical change per PR
- Squash merge preferred for clean history
