// Check that each primary input in a batch gets its own log, holding only its
// own diagnostics.

// RUN: %empty-directory(%t)

// One -serialize-diagnostics-path per primary, in primary order, which is how
// the driver passes them in batch mode below the filelist threshold.
// RUN: %target-swift-frontend -typecheck -serialize-diagnostics=sarif \
// RUN:   -primary-file %s -serialize-diagnostics-path %t/main.sarif \
// RUN:   -primary-file %S/Inputs/sarif-diagnostics-batch-mode-helper.swift \
// RUN:     -serialize-diagnostics-path %t/helper.sarif \
// RUN:   %S/Inputs/sarif-diagnostics-batch-mode-other.swift

// Each log holds the warning from its own primary and nothing else. The batch
// also contains a file that is not a primary, whose warning names
// 'shouldNotShowUpInOutput' and belongs to neither log.
// RUN: %normalize_sarif %t/main.sarif | %diff -U1 -b %S/Inputs/expected-sarif/sarif-diagnostics-batch-mode.sarif -
// RUN: %normalize_sarif %t/helper.sarif | %diff -U1 -b %S/Inputs/expected-sarif/sarif-diagnostics-batch-mode-helper.sarif -

// If any primary errors, no primary can be compiled. The primaries that were
// cut short still get a log, empty, matching the file the binary format writes
// in that case: the driver uses its presence to tell a clean compile from a job
// that never ran.
// RUN: echo 'let bad: Int = "oops"' > %t/bad.swift
// RUN: not %target-swift-frontend -typecheck -serialize-diagnostics=sarif \
// RUN:   -primary-file %t/bad.swift -serialize-diagnostics-path %t/bad.sarif \
// RUN:   -primary-file %S/Inputs/sarif-diagnostics-batch-mode-helper.swift \
// RUN:     -serialize-diagnostics-path %t/cutshort.sarif

// The log for the cut-short primary exists and holds no results.
// RUN: %normalize_sarif %t/cutshort.sarif | %diff -U1 -b %S/Inputs/expected-sarif/sarif-diagnostics-empty.sarif -

// REQUIRES: swift_sarif

func mainFunction() {
  let mainUnused = 1
}
