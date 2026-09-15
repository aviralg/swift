// Check where a SARIF log is written: the derived path, and a path that cannot
// be opened.

// RUN: %empty-directory(%t)

// The format flag derives a '.sarif' path, and no bitcode log is written.
// RUN: cp %s %t/derived.swift
// RUN: cd %t && %target-swift-frontend -typecheck -serialize-diagnostics=sarif derived.swift
// RUN: test -f %t/derived.sarif
// RUN: test ! -f %t/derived.dia

// A log that cannot be written is reported rather than ignored.
// RUN: not %target-swift-frontend -typecheck -serialize-diagnostics=sarif -serialize-diagnostics-path %t/nonexistent/some.sarif %s 2>%t.err.txt
// RUN: %FileCheck --input-file=%t.err.txt %s -check-prefix=OPEN-FAIL
// OPEN-FAIL: cannot open file '{{.*}}/nonexistent/some.sarif' for diagnostics emission

// REQUIRES: swift_sarif

let x = 1
