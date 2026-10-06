# Testing

## Canonical local verification

```bash
python scripts/harness.py
python -m unittest discover -s tests -v
```

## Current test scope

The template tests only the harness itself. Project-specific tests must be added as implementation appears.

## Maturity trigger

- OSPS Level 2: automated tests must be run by CI before a change is accepted where the applicable control requires it.
- OSPS Level 3: documentation must explain when/how tests run, and major changes should add or update tests according to documented policy.

The harness does not claim that a repository is Level 2/3 merely because this file exists.
