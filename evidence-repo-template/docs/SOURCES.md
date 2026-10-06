# External basis

This template intentionally separates **source requirements** from **repository adapters**.

## OpenSSF OSPS Baseline

- Current baseline used by this template: v2026.08.28
- https://baseline.openssf.org/versions/2026-08-28
- https://baseline.openssf.org/

Used for: maturity levels; contribution guidance; license location; dependency transparency; automated testing; release-conditioned documentation; SBOM/SCA/SAST controls; and distinction between levels.

## OpenSSF Scorecard

- https://github.com/ossf/scorecard
- https://github.com/ossf/scorecard-action

Used for: recurring automated repository security-health assessment. The provided workflow is an example and must be pinned/configured before enabling.

## NIST SSDF

- https://csrc.nist.gov/projects/ssdf

Used for: secure software-development practices organized around preparation, protection, producing well-secured software, and vulnerability response. This template does not claim NIST conformance.

## DORA

- https://dora.dev/capabilities/version-control/
- https://dora.dev/capabilities/continuous-integration/
- https://dora.dev/capabilities/continuous-delivery/

Used for: empirical support for comprehensive version control, automated build/test feedback, CI, continuous testing, and versioning of automation/configuration/AI artifacts.

## GitHub

- https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository
- https://docs.github.com/en/copilot/reference/custom-instructions-support

Used for: template-repository mechanics and recognized locations for Copilot/agent instructions.

## Repository-specific adapters (not external requirements)

The following are implementation choices made solely to operationalize the external material:

- `policy/project-state.json`
- `scripts/harness.py`
- result labels `PASS`, `GAP`, `UNKNOWN_EXTERNAL`, `NOT_APPLICABLE`
- `MATURITY_REASSESSMENT_REQUIRED`
- use of `AGENTS.md` to tell agents to run the harness
- the `evidence-reviewer` custom-agent profile

These adapters must not be cited as if OpenSSF, NIST, DORA, or GitHub mandated their exact names or formats.
