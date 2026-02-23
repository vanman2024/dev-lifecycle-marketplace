# Newman CI Integration Example

## GitHub Actions

```yaml
- name: Run Newman API Tests
  run: |
    bash plugins/testing/skills/newman-runner/scripts/run-newman-ci.sh \
      api-tests.postman_collection.json \
      -e test-environment.json

- name: Upload test results
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: newman-results
    path: test-results/api-contract/

- name: Publish test report
  if: always()
  uses: dorny/test-reporter@v1
  with:
    name: Newman API Tests
    path: test-results/api-contract/newman-junit.xml
    reporter: java-junit
```

## Output Files

After running `run-newman-ci.sh`:

```
test-results/api-contract/
  newman-results.json   # Full JSON report for analysis
  newman-junit.xml      # JUnit XML for CI reporting
```

## Notes

- The CI runner uses GitHub Actions annotation format (`::error::`) for inline errors
- JUnit XML enables test result tabs in GitHub Actions, GitLab CI, and Jenkins
- Non-zero exit code on any failure ensures CI pipeline fails correctly
