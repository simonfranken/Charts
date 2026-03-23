# Contributing

Thanks for your interest in improving this Helm chart collection.

## Ways To Contribute

- report bugs,
- improve chart defaults,
- add tests or CI checks,
- improve docs and examples.

## Development Workflow

1. Fork the repository and create a feature branch.
2. Make focused changes in one or more charts.
3. Validate charts locally:

```bash
for chart in */Chart.yaml; do
  dir="${chart%/Chart.yaml}"
  helm dependency build "$dir"
  helm lint "$dir"
  helm template test "$dir" >/dev/null
done
```

4. Open a pull request with a clear description.

## Chart Change Guidelines

- Keep chart metadata in `Chart.yaml` complete and consistent.
- Prefer pinned image tags in `values.yaml`.
- Avoid breaking changes unless versioned and documented.
- Do not commit plaintext production credentials.

## Versioning

- Bump chart `version` for every chart change.
- Update `appVersion` when the application version changes.

## Pull Request Checklist

- [ ] Helm lint passes.
- [ ] Helm template render succeeds.
- [ ] Docs are updated (README/values comments) if behavior changed.
- [ ] Chart versions are bumped where required.
