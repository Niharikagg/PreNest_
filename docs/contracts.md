# PreNest — Shared Contracts

This document defines the shared boundaries between A, B, C and D.

The contracts are designed so that each person can implement their component independently without depending on another person's internal implementation.

---

# 1. Frozen Areas

The following directories are frozen:

```text
lib/core/models/
lib/core/contracts/
```

All four team members must agree before these files are changed.

The models define shared data structures.

The contracts define interfaces between components.

Implementation details remain outside these frozen areas.

---

# 2. Report Processing Flow

```text
Report Image
     ↓
A — Image Processing
     ↓
Flattened Image
     ↓
B — OCR / Extraction
     ↓
ExtractedField
     ↓
A — Verify Screen
     ↓
User Confirmation / Correction
     ↓
VerifiedResult
     ↓
C — Database / Validity / Trends
     ↓
TrendSummary
     ↓
A — Charts
```

---

# 3. `ExtractedField`

Produced by B and consumed by the verification flow.

Required information:

```text
id
testNameRaw
testNameStd
value
unit
date
printedRange
confidence
status
bbox
```

Rules:

- `id` is unique within a report.
- `testNameRaw` is exactly as printed.
- `testNameStd` comes from the standardized dictionary or is `null`.
- `value` is `null` when unreadable.
- `confidence` is between `0.0` and `1.0`.
- Confidence must be calibrated.
- `status` is either `auto` or `needsReview`.
- B must never set `confirmed` or `corrected`.
- `bbox` uses pixel coordinates from the image received by the extraction module.
- Bounding-box origin is top-left.
- Bad OCR must not crash the extraction service.
- A blank page returns an empty list.

`ExtractedField` is local data and must not be synchronized online.

---

# 4. `VerifiedResult`

Created after the user reviews extracted fields.

Required information:

```text
id
personId
testNameStd
value
unit
date
stage
status
```

Rules:

- `status` must be `confirmed` or `corrected`.
- `value` must not be `null`.
- `date` must not be `null`.
- `testNameStd` must not be `null`.
- Invalid/unverified results must be rejected by C's save operation.
- Verified results are stored locally.
- Verified results are the only report-derived data that may cross the online synchronization boundary.

---

# 5. `ComparisonVerdict`

Produced by the validity engine.

```text
canCompare
reason
```

`canCompare` indicates whether two verified results are eligible for comparison.

The reason must explain why comparison is or is not allowed.

Results may share a comparison group only when:

```text
person + test + unit + stage
```

match.

The validity layer must refuse misleading comparisons.

---

# 6. `TrendSummary`

Produced by C's trend service and consumed by the UI/chart layer.

Required information:

```text
count
firstValue
latestValue
change
changePercent
positionInRange
labelKey
canCompare
reason
```

`positionInRange`:

```text
0 = lower configured limit
1 = upper configured limit
```

`labelKey` may contain only the defined machine-readable keys:

```text
first_result
change_two
moving_up_so_far
moving_down_so_far
steady
not_enough
cannot_compare
```

The service returns `labelKey`.

The UI is responsible for converting it into user-visible wording.

The service must not return diagnosis language.

---

# 7. Extraction Contract

```text
ExtractionService

Input:
File

Output:
List<ExtractedField>
```

The input is a flattened image when A's image-processing pipeline is available.

During early development, B may accept any image so that extraction can be developed independently.

The service must not throw merely because OCR cannot read a report.

---

# 8. Database Contract

C owns the database implementation.

### Save

```text
saveVerified(List<VerifiedResult>)
```

The operation must reject any result where:

- status is not `confirmed` or `corrected`
- value is null
- date is null
- testNameStd is null

### Retrieval

```text
getByPerson(personId)
```

Results are returned oldest first.

---

# 9. Validity Contract

```text
ValidityEngine.check(
    VerifiedResult a,
    VerifiedResult b
)
    → ComparisonVerdict
```

Comparison must consider:

- person
- standardized test
- unit
- stage
- other configured compatibility requirements

The engine must provide a plain-English reason when comparison is refused.

---

# 10. Trend Contract

```text
TrendService
    List<VerifiedResult>
        → TrendSummary
```

Input results must belong to one comparison group and be sorted before trend evaluation.

Rules:

- 1 result → first result
- 2 results → show change
- 3–4 results → moving up/down so far
- 5+ results → trend evaluation
- incompatible groups → cannot compare / refusal

The exact user-visible wording belongs to the screen layer.

---

# 11. Security Contract

```text
SecurityService

authenticate()
    → true / false

getDatabaseKey()
    → 32 random bytes

lock()
    → locks application state

isUnlocked()
    → current lock state
```

Rules:

- Database key is created once.
- The key is stored securely.
- The same key is returned on subsequent calls.
- The key must never be logged.
- The key must never be displayed.
- The key is provided to C's encrypted database.
- Authentication uses the phone's supported authentication mechanisms.

---

# 12. Synchronization Contract

PreNest is offline-first.

Only `VerifiedResult` objects may be synchronized.

```text
VerifiedResult
      ↓
SyncService
      ↓
Authenticated HTTPS request
      ↓
Backend
```

The synchronization layer must never receive:

- Original report images
- Flattened report images
- OCR text
- Bounding boxes
- OCR confidence
- Unverified `ExtractedField` objects

The local database remains the source of the user's offline records.

If the network is unavailable, verified results remain locally stored and can be synchronized later.

---

# 13. Online Backend Boundary

The backend stores verified structured results only.

It may contain:

```text
personId
testNameStd
value
unit
date
stage
status
```

The backend must not be used as report-image storage.

Trend calculations do not need to be uploaded as permanent medical-result data. They can be calculated from verified results.

---

# 14. Shared Data Rules

All implementations must follow these rules:

- Standardized test names use lowercase `snake_case`.
- Printed units are preserved.
- Dates use local `DateTime` at midnight.
- Unknown values are `null`.
- Never represent unknown as `0` or `""`.
- Bounding boxes use top-left origin.
- Values must not be silently invented when unreadable.
- B does not create verification status.
- A creates confirmation/correction through the verification flow.
- C accepts only verified results.
- UI text must not use `normal`, `abnormal`, or diagnosis language.

---

# 15. Contract Change Procedure

Because these files are frozen:

1. Identify the required change.
2. Explain why the current contract cannot support it.
3. Discuss the change with A, B, C and D.
4. Agree on the new contract.
5. Update the frozen model/contract.
6. Update affected implementations and tests.
7. Review the Pull Request carefully.
8. Merge only after all affected owners agree.

No individual team member may silently change the shared contract.