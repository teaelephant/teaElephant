# Mobile bug fixes

The nine findings below were approved for repair after the audit of commit
`6f709c8cadf4c367a77e9fe2f092d7c420776f2f`. The implementation starts from
`d12de046dec5009539021e9409a9f62e7a79d61e`, which includes the warning fixes.

| ID | Trigger | Required behavior |
| --- | --- | --- |
| 1 | Short, foreign, or malformed NFC data, including `A1 78` | Report a read error without a trap; keep valid legacy MessagePack streams readable. |
| 2 | QR expiration with fractional seconds, a time-zone offset, or an invalid value | Parse backend RFC 3339/RFC 3339 Nano dates and reject invalid clock, calendar, offset, or trailing values without force-unwrapping. |
| 3 | Background search finds tea but the user never presses Use This | Create the user's new tea. Only an explicitly selected ID may be reused. |
| 4 | NFC is unavailable, writing is pending, cancelled, or fails | Await the real write result; keep the form on failure and reset it only after confirmed success. |
| 5 | A successful public tea or QR response reaches the auth interceptor | Preserve the existing auth state. Explicit login/session verification confirms authentication. |
| 6 | Another QR/NFC read follows a successful or failed read | Clear the previous result/error and prevent an earlier operation from overwriting the current one. |
| 7 | A QR response contains tea tags | Preserve each tag's ID, name, color, and category for the card. |
| 8 | The read screen/session finishes | Release Reader, NFCReader, callbacks, and the communicator delegate; invalidation must not restart scanning. |
| 9 | The tea name contains only whitespace | Reject Continue and saving; validate and store a trimmed name. |

The existing legacy NFC format is three consecutive MessagePack values:
String ID, Float64 Unix expiration time, and an integer brewing temperature.
The repair must accept their valid variable-width representations while
rejecting truncated values, invalid markers/UTF-8, non-finite dates, integer
overflow, and trailing data. Existing tags use the legacy well-known
`application/json` record type; the reader must retain compatibility while
rejecting unrelated record types.

NFC write tests use session/tag doubles at the hardware boundary, and QR/auth
tests use synthetic Apollo responses. Physical tag writing and full Apple ID
login require device testing in addition to these local checks.

## Verification

On 2026-10-11 the integrated repair passed all 81 unit tests and 3 UI tests on
an iPhone 18 Pro simulator. Debug builds and a device Release archive of the
app and App Clip reported zero compiler warnings or errors. A fresh review
found no remaining issues in these nine repairs.

The regression suite was first run against the original code to confirm the
failures. It also checks cancellation before a late NFC status/completion,
invalid Gregorian dates and trailing text, and overlapping QR/NFC reads.
The whitespace UI test sets onboarding defaults through launch arguments so
it also reaches the form on a clean installation without changing app code.
The simulator read screen was checked for visible unavailable-NFC feedback.

Calendar and clock validation follow the backend wire profile and
[RFC 3339 sections 5.6–5.7](https://www.rfc-editor.org/rfc/rfc3339#section-5.6).
The repair covers the active Menu creation/read paths. Legacy preview-only
forms were adapted to await the writer; broader search ordering, auth/token
lifecycle, and server transaction sequencing were outside these findings.
Physical tag writing and full Apple ID sign-in were not exercised locally.

To reproduce the tests on an available simulator:

```sh
xcodebuild test -workspace TeaElephant.xcworkspace -scheme TeaElephantTests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
xcodebuild test -workspace TeaElephant.xcworkspace -scheme TeaElephantUITests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
xcodebuild archive -workspace TeaElephant.xcworkspace -scheme TeaElephantTests \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath /tmp/TeaElephant.xcarchive CODE_SIGNING_ALLOWED=NO
```
