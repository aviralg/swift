// A PCH job serializes its diagnostics in the requested format, like every
// other job. Diagnostics raised inside the bridging header are reported only by
// the job that builds the PCH, so a binary PCH log would hide them from a
// client reading SARIF.

// RUN: %empty-directory(%t)

// A persistent PCH writes its log inside the PCH output directory.
// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics=sarif -emit-module-path %t/main.swiftmodule -pch-output-dir %t/pch -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s -check-prefix=PERSISTENT

// PERSISTENT: -serialize-diagnostics-path {{[^ ]*}}pch{{/|\\\\}}bridging-header-{{[^ ]*}}.sarif
// PERSISTENT-SAME: -serialize-diagnostics=sarif
// PERSISTENT-SAME: -emit-pch -pch-output-dir

// The compile job serializes to SARIF too.
// PERSISTENT: -primary-file {{[^ ]*}}sarif-diagnostics-pch.swift
// PERSISTENT-SAME: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics-pch.sarif
// PERSISTENT-SAME: -serialize-diagnostics=sarif

// No later job serializes diagnostics: the format is never forwarded wholesale,
// so the emit-module job gets neither a path nor the format.
// PERSISTENT-NOT: -serialize-diagnostics

// A temporary PCH does the same.
// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics=sarif -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s -check-prefix=TEMPORARY

// TEMPORARY: -serialize-diagnostics-path {{[^ ]*}}.sarif
// TEMPORARY-SAME: -serialize-diagnostics=sarif
// TEMPORARY-SAME: -emit-pch -o {{[^ ]*}}bridging-header-{{[^ ]*}}.pch

// TEMPORARY: -primary-file {{[^ ]*}}sarif-diagnostics-pch.swift
// TEMPORARY-SAME: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics-pch.sarif
// TEMPORARY-SAME: -serialize-diagnostics=sarif

// Without a module path to derive a name from, a persistent PCH's log is a
// temporary file, still in the requested format.
// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics=sarif -pch-output-dir %t/pch -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s -check-prefix=NO-MODULE-PATH

// NO-MODULE-PATH: -serialize-diagnostics-path {{[^ ]*}}bridging-header-{{[^ ]*}}.sarif
// NO-MODULE-PATH-SAME: -serialize-diagnostics=sarif
// NO-MODULE-PATH-SAME: -emit-pch -pch-output-dir

// Without a format, the PCH job keeps the binary format and no job is given a
// format flag.
// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics -emit-module-path %t/main.swiftmodule -pch-output-dir %t/pch -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s -check-prefix=BITCODE --implicit-check-not=-serialize-diagnostics=

// BITCODE: -serialize-diagnostics-path {{[^ ]*}}pch{{/|\\\\}}bridging-header-{{[^ ]*}}.dia
// BITCODE-SAME: -emit-pch -pch-output-dir
// BITCODE: -primary-file {{[^ ]*}}sarif-diagnostics-pch.swift
// BITCODE-SAME: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics-pch.dia

// REQUIRES: cplusplus_driver

let y = x
