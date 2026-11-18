# PreNest — Team Rules & Ownership

## 1. Project Structure

PreNest is an offline-first Flutter Android application for couples preparing for pregnancy.

Main flow:

**Report Image → Image Processing → OCR / Extraction → User Verification → Verified Data → Safe Comparison & Trends → Charts / Summary**

The application is informational only. It does not diagnose conditions or prescribe treatment or dosage.

---

## 2. Team Roles

### Person A — Image Processing, Verification & Charts

**Responsibilities:**
- Report capture
- Image quality checks
- Document/page detection
- Perspective correction and flattening
- Image cleanup
- Verify screen
- Charts and visual trend display

**Folders:**
- `lib/features/reports/capture`
- `lib/features/reports/graphics`
- `lib/features/charts`
- `test/graphics`

**Later, after the initial architecture is merged:**
- `lib/main.dart`
- `lib/app`
- `lib/features/home`
- `lib/features/profile`
- `lib/features/verify`
- `lib/features/records`
- `lib/features/timeline`
- `lib/features/demo`
- `pubspec.yaml`
- `.github`

**Branches:**
- `lane-a/straighten`
- `lane-a/trend-chart`
- `lane-a/verify-screen`

---

### Person B — Extraction & Evaluation

**Responsibilities:**
- Synthetic report generator
- OCR using Google ML Kit
- Parsing
- Test-name and unit dictionaries
- Confidence scoring and calibration
- Extraction evaluation
- OCR playground

**Folders:**
- `lib/features/reports/extraction`
- `assets/dictionaries`
- `eval`
- `test/extraction`

**Branches:**
- `lane-b/report-generator`
- `lane-b/ocr`
- `lane-b/parsing`
- `lane-b/evaluation`

**Input:**

`File → ExtractionService`

**Output:**

`List<ExtractedField>`

B never sets `confirmed` or `corrected`. Those states are created by the verification process.

---

### Person C — Data, Safety & Output

**Responsibilities:**
- Encrypted database
- Verified-result storage
- Comparison validity
- Trend calculations
- Configuration and thresholds
- Doctor summary PDF
- Local reminders
- Online synchronization and online data handling

**Folders:**
- `lib/core/db`
- `lib/features/validity`
- `lib/features/summary`
- `lib/features/reminders`
- `assets/config`
- `test/validity`
- `lib/core/network` for synchronization/data handling

**Branches:**
- `lane-c/database`
- `lane-c/validity`
- `lane-c/trend-service`
- `lane-c/pdf`
- `lane-c/reminders`
- `lane-c/sync`

---

### Person D — Security

**Responsibilities:**
- App lock
- Authentication
- Auto-lock
- Secure database key
- Privacy in the app switcher/recents screen
- Secure online authentication and communication
- Preconception checklist content
- Research documentation
- Limitations documentation
- Review A's pull requests when available

**Folders:**
- `lib/core/security`
- `lib/features/lock`
- `test/security`
- `assets/content`
- `docs/limitations.md`
- `docs/research.md`

**Branches:**
- `lane-d/app-lock`
- `lane-d/key-store`
- `lane-d/privacy-settings`
- Additional authentication/security branch if required

---

## 3. Frozen Shared Areas

The following directories are frozen:

- `lib/core/models`
- `lib/core/contracts`

No team member may independently modify files in these directories.

Any change requires agreement from A, B, C and D.

These directories define the shared language between the team's components.

---

## 4. Shared Data Flow

### Extraction

`Report Image → A → flattened image → B`

### Extraction result

`B → ExtractedField → A`

### Verification

`A → user confirms/corrects → VerifiedResult`

### Storage

`VerifiedResult → C → encrypted local database`

### Analysis

`VerifiedResult → C → ValidityEngine / TrendService`

### Visualization

`TrendSummary → A → charts`

### Synchronization

`VerifiedResult → SyncService → Online Backend`

---

## 5. Online Data Boundary

PreNest is offline-first with selective online synchronization.

### Data that stays on the phone

The following must never be synchronized to the online backend:

- Original report images
- Flattened/processed report images
- OCR text
- OCR bounding boxes
- OCR confidence values
- Unverified extracted fields

### Data allowed online

Only user-verified structured results may be synchronized.

The online backend may receive structured information such as:

- Person identifier
- Standardized test name
- Verified value
- Unit
- Date
- Pregnancy/preparation stage
- Verification status

The backend is not a report-image or document-storage system.

---

## 6. Offline-First Rule

The application must remain usable without an internet connection.

A verified result is saved locally first.

If the network is unavailable, synchronization waits until connectivity is available.

Example:

`Verify → Local DB → Pending Sync → Online Sync`

The online backend must never be required for the core scanning, extraction, verification or local-record workflow.

---

## 7. Shared Data Rules

- Test names use lowercase `snake_case` standardized keys.
- `testNameRaw` preserves the test name as printed.
- Units are stored as printed.
- Dates use `DateTime` at local midnight.
- Unknown values are represented as `null`.
- Unknown values must never be represented as `0` or `""`.
- Bounding boxes use pixel coordinates from the image received by the image-processing/extraction module.
- The bounding-box origin is top-left.
- B never creates `confirmed` or `corrected` status.
- Only the verification process can create `confirmed` or `corrected` status.
- C rejects unverified results from `saveVerified`.
- User-visible screens must never use the words `normal`, `abnormal`, or diagnosis language.

---

## 8. Ownership Rule

Everyone works only inside their assigned folders.

If a change is required in another person's folder:

1. Do not edit it directly.
2. Open a GitHub Issue.
3. Tag the owner.
4. Agree on the change.
5. Let the owner implement it.

---

## 9. `di.dart`

`lib/core/di.dart` is shared.

Each person edits only their assigned registration line.

- A — A's services
- B — extraction
- C — records and validity
- D — security

Do not rewrite another person's registration.

---

## 10. Dependency Rule

Only Person A adds packages to `pubspec.yaml`.

If another person needs a package:

1. Ask in the team chat.
2. Explain why it is required.
3. A adds it after agreement.

Do not independently modify dependencies.

---

## 11. Git Rules

Nobody works directly on `main`.

Never:

- `git push main`
- force-push
- rewrite shared history

Daily workflow:

1. Update from `main`.
2. Create a short task branch.
3. Make small commits.
4. Push the branch.
5. Open a Pull Request into `main`.
6. A different team member reviews it.
7. Tests must pass.
8. Review must confirm that only the expected folders changed.
9. Squash and merge.
10. Delete the branch.
11. Start the next task from updated `main`.

Branches should normally represent one short task and be merged within approximately three days.

---

## 12. Cross-Team Contract Rule

Before implementation begins, the shared models and contracts must be finalized.

After they are frozen:

- Do not silently change field names.
- Do not change field types without team approval.
- Do not change method signatures without team approval.
- Do not add required fields without team approval.

The frozen contracts are the boundary that allows A, B, C and D to work independently.

---

## 13. Product Safety

PreNest provides informational support only.

It must not:

- Diagnose medical conditions.
- Prescribe treatment.
- Recommend medication or dosage.
- Present app calculations as medical conclusions.

Clinical/configuration information must have a source and review status.

Configuration without a verified source must be explicitly treated as demo content.