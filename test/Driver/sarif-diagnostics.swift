// Each input gets its own SARIF log, and the format travels with the path.

// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=sarif -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s

// Without a format, diagnostics stay in the binary format and no format flag is
// passed to any job. Naming the binary format is the same.
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=BITCODE --implicit-check-not=-serialize-diagnostics=
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=dia -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=BITCODE --implicit-check-not=-serialize-diagnostics=

// An unknown format is an error, reported before any job is planned. Only the
// format that takes effect, the last one given, is checked.
// RUN: not %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=bogus -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=UNKNOWN --implicit-check-not=-frontend
// RUN: not %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=sarif -serialize-diagnostics=bogus -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=UNKNOWN --implicit-check-not=-frontend
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=bogus -serialize-diagnostics=sarif -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s
// UNKNOWN: error: invalid value 'bogus' in '-serialize-diagnostics='

// The last format wins, and the bare flag does not override a format given
// alongside it.
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=sarif -serialize-diagnostics=dia -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=BITCODE --implicit-check-not=-serialize-diagnostics=
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=dia -serialize-diagnostics=sarif -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics -serialize-diagnostics=sarif -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=sarif -serialize-diagnostics -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s

// Paths passed in a supplementary output file map still come with the format,
// which the map does not carry. (sarif-diagnostics-end-to-end.swift checks the
// frontend writes the log from such a map.)
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=sarif -disallow-use-new-driver -driver-filelist-threshold=0 %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=FILEMAP

// swiftc chooses the log paths itself, so it rejects an explicit one whatever
// the format.
// RUN: not %swiftc_driver -typecheck -serialize-diagnostics=sarif -serialize-diagnostics-path %t.sarif -disallow-use-new-driver %s 2>&1 | %FileCheck %s -check-prefix=EXPLICIT-PATH
// RUN: not %swiftc_driver -typecheck -serialize-diagnostics -serialize-diagnostics-path %t.dia -disallow-use-new-driver %s 2>&1 | %FileCheck %s -check-prefix=EXPLICIT-PATH
// EXPLICIT-PATH: error: option '-serialize-diagnostics-path' is not supported by 'swiftc'

// Legacy C++ driver only; the same behavior is tested for swift-driver in
// Tests/SwiftDriverTests.
// REQUIRES: cplusplus_driver

// CHECK: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics.sarif
// CHECK-SAME: -serialize-diagnostics=sarif
// CHECK: -serialize-diagnostics-path {{[^ ]*}}main.sarif
// CHECK-SAME: -serialize-diagnostics=sarif

// BITCODE: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics.dia
// BITCODE: -serialize-diagnostics-path {{[^ ]*}}main.dia

// FILEMAP: -supplementary-output-file-map {{[^ ]+}}
// FILEMAP-SAME: -serialize-diagnostics=sarif
// FILEMAP: -supplementary-output-file-map {{[^ ]+}}
// FILEMAP-SAME: -serialize-diagnostics=sarif
