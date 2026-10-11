# TeaElephant documentation

The [repository README](../README.md) is the starting point for the current app,
its architecture, requirements and local workflow.

## Maintenance and implementation references

| Document | Purpose |
| --- | --- |
| [Dependency maintenance](DEPENDENCIES.md) | Pinned SDK/CLI versions, code generation, test schemes and TestFlight commands |
| [Mobile bug audit](MOBILE_BUGS.md) | Reproduction evidence for the audit that led to the mobile fixes; findings describe the audited revision |
| [Tea of the Day](TEA_OF_THE_DAY_FEATURE.md) | Feature design and implementation context for daily recommendations |
| [Agent guidance](../AGENTS.md) | Repository layout, code conventions and contribution expectations |

## Design documents and historical reviews

These documents retain their original context and may include proposals or
behaviour that differs from the current app. Check the current source before
treating a recommendation as implemented.

- [Wellness feature design](WELLNESS.md): HealthKit context and longer-term ideas.
- [App Store copy draft](APP_STORE_SUBMISSION.md): submission copy and review notes;
  check every feature and privacy claim against the shipping build before use.
- [Swift 6 migration review](SWIFT_6_MIGRATION_REVIEW.md).
- [Project review and recommendations](PROJECT_REVIEW_AND_RECOMMENDATIONS.md).
- [WWDC 2025 recommendations](WWDC2025_RECOMMENDATIONS.md).
- [Earlier Claude guidance](CLAUDE.md) and [Gemini review](GEMINI.md).

The current implementation sends the recommendation form's feelings text to
the backend, including an optional user-approved wellness summary. A design
document's statement about local HealthKit processing does not mean that the
submitted summary stays on the device.
