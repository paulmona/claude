# claude-skills

## Versioning

- Semver (MAJOR.MINOR.PATCH) on trunk-based dev
- All work merges to `main` via PR
- Tag a release locally with `git tag v1.2.3 && git push origin v1.2.3`
- Pushing a `v*` tag triggers GitHub Actions to create a Release with auto-generated notes

## Structure

```
skills/         Skill definitions (*.md)
.github/        GitHub Actions workflows
```

## Git Workflow

- Branch from `main`, PR back to `main`
- Keep PRs focused — one logical change per PR
- Squash merge preferred for clean history
