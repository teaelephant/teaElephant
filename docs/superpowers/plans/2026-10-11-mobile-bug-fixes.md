# Mobile Bug Fixes Implementation Plan

> **For agentic workers:** Use superpowers:dispatching-parallel-agents for the independent NFC, save, and auth repairs. The coordinator owns read-state integration and verification. Steps use checkbox syntax for tracking.

**Goal:** Repair all nine user-approved mobile findings and retain warning-free builds.

**Architecture:** Preserve the current SwiftUI screens and Apollo operations. Validate incoming NFC/QR data at their boundaries, bind read results to their operation, make explicit tea selection independent of search suggestions, and bridge CoreNFC completion into an awaited write.

**Tech Stack:** Swift 6, SwiftUI, XCTest, Apollo iOS 2.4.0, CoreNFC, MessagePacker 0.4.7.

**Spec:** `docs/MOBILE_BUGS.md`.

## Global Constraints

- Keep the current iOS 26.6 app/App Clip minimums and dependency pins.
- Keep compiler warning diagnostics enabled.
- Tests call `TeaElephant.*` application types, avoiding duplicated types in the unit-test target.
- Mock hardware/network boundaries and protect existing keychain entries during auth tests.
- One coordinator owns project membership, simulator sessions, full verification, and publication.

## Review Focus

- Preserve legacy NFC tags and reject every truncated field, oversized length, and integer overflow.
- Clear each NFC write continuation exactly once, including cancellation and late callbacks.
- An earlier read must never replace the result of a newer read.
- A background search update must never replace an explicitly selected tea ID.
- Whitespace-only names must fail both navigation and the save path; new tea names are trimmed.

### Task 1: Pin the reported failures

**Files:** `TeaElephantTests/{Auth,NFCRead,Reader,Save}RegressionTests.swift`, `TeaElephantUITests/TeaElephantUITests.swift`, project test membership.

- [x] Run the existing shared unit scheme in the clean worktree: 9 passing tests.
- [x] Run safe new regression tests before modifying production and retain expected failures.
- [x] Keep crash reproductions in separate test classes and verify the original source is unchanged from the audited crash sites.
- [x] Reproduce whitespace-only navigation through the real UI before the form repair.

### Task 2: Repair the read pipeline and lifecycle

**Files:** `Shared/Models/TeaMeta.swift`, `Shared/TagManagement/{Reader,NFCreader,NearFieldCommunicator}.swift` and their regression tests.

**Interfaces:** `@MainActor ShortInfoReader` exposes `startReadInfo()`, `setOnRead(_ callback: @escaping @MainActor (TeaMeta) async -> Void)`, and `setOnError(_ callback: @escaping @MainActor (Error) -> Void)`. `NearFieldCommunicator.createSession(invalidateAfterFirstRead: Bool = true)` supports both read and write sessions.

- [x] Replace fixed offsets with a bounded parser for the existing MessagePack stream.
- [x] Validate NDEF type/counts, propagate errors, use a weak delegate, and finish sessions without automatic restart.
- [x] Use weak Reader callbacks and an operation identity; reset old state at read start.
- [x] Accept fractional/non-fractional QR dates, reject invalid dates, and preserve tags.
- [x] Test malformed/truncated/variable-width payloads, legacy round trips, object release, stale state, and overlapping read results.

### Task 3: Await actual NFC writing

**Files:** `Shared/TagManagement/{Writer,NFCwriter}.swift`, necessary form call sites, `SaveRegressionTests.swift`.

**Interfaces:** `ShortInfoWriter.writeData(info: TeaMeta) async throws`. Hardware session/tag adapters deliver connect, status, write, and invalidation events to the actual writer.

- [x] Suspend while NFC writing is pending and complete only on actual write success.
- [x] Handle unavailable hardware, cancellation, tag/status/connect/write errors, capacity, concurrent calls, and duplicate/late callbacks.
- [x] Update every existing caller to await the result and retain form data on failure.
- [x] Test actual bridge outcomes with controlled session/tag doubles.

### Task 4: Require explicit selection and a valid name

**Files:** `Shared/Models/TeaSaveSelection.swift`, `Shared/Views/MultiStepNewCard.swift`, selection/name unit tests and the whitespace UI test.

**Interfaces:** `TeaSaveSelection.selectedID`, `select(id:)`, `reset()`, and `target(name:type:description:) throws -> TeaSaveTarget` distinguish `.existing(id:)` from `.new(TeaData)`; validation normalizes names.

- [x] Snapshot the ID only on Use This; clear it on reset/deselection.
- [x] Derive NFC and QR save targets before suspension from explicit selection and trimmed input.
- [x] Reject whitespace-only names in Continue and saving; store normalized names.
- [x] Test new/existing/reset choices, changed suggestions, name boundaries, and real UI navigation.

### Task 5: Preserve auth state for public responses

**Files:** `Shared/UserArea/Auth/UnauthInterceptor.swift`, `AuthRegressionTests.swift`, the existing server-success test expectation.

- [x] Remove generic successful-response authentication; retain server-only unauth invalidation.
- [x] Verify public Get/Read responses preserve guest or confirmed state, cached errors do not revoke it, and actual server rejection still does.
- [x] Keep explicit AuthMutation and Me confirmation behavior in AuthManager.

### Task 6: Verify and publish the integrated repair

- [x] Run both shared XCTest schemes, including crash regression classes and all new edge cases.
- [x] Build a device Release archive so device-only CoreNFC/AR branches compile.
- [x] Check complete compiler logs for zero warnings/errors; smoke-test read and creation screens.
- [x] Review the complete diff and confirm the original checkout was untouched before integration.
- Commit, fast-forward the clean main checkout, push the previously authorized GitHub main, and read back the exact remote SHA. The publication receipt is reported in the chat after read-back.

**Verification receipt (2026-10-11):** 81 unit tests and 3 UI tests passed, with zero failures or skips. Debug builds and the device Release archive for app and App Clip reported zero compiler warnings/errors. Independent review reported no remaining findings. The simulator read screen displayed the unavailable-NFC error correctly. Physical NFC and full Apple ID login remain device checks.
