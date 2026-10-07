// An output file map's 'sarif-diagnostics' entry names the SARIF log, and its
// 'diagnostics' entry names the binary one; each is used only for its own
// format.
//
// A persistent PCH's log is named by the driver whatever the map says; the
// header's entry is not consulted. (swift-driver does consult it, in either
// format; that difference predates SARIF support.)

// RUN: %empty-directory(%t)
// RUN: echo "{\"%/s\": {\"sarif-diagnostics\": \"%/t/main-from-map.sarif\", \"diagnostics\": \"%/t/main-from-map.dia\"}, \"%/S/Inputs/bridging-header.h\": {\"sarif-diagnostics\": \"%/t/header-from-map.sarif\", \"diagnostics\": \"%/t/header-from-map.dia\"}}" > %t/ofm.json

// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics=sarif -output-file-map %t/ofm.json -pch-output-dir %t/pch -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s -check-prefix=SARIF --implicit-check-not=-from-map.dia --implicit-check-not=header-from-map

// SARIF: -serialize-diagnostics-path {{[^ ]*}}bridging-header-{{[^ ]*}}.sarif
// SARIF-SAME: -serialize-diagnostics=sarif
// SARIF-SAME: -emit-pch
// SARIF: -primary-file {{[^ ]*}}sarif-diagnostics-output-file-map.swift
// SARIF-SAME: -serialize-diagnostics-path {{[^ ]*}}main-from-map.sarif
// SARIF-SAME: -serialize-diagnostics=sarif

// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics -output-file-map %t/ofm.json -pch-output-dir %t/pch -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s -check-prefix=BITCODE --implicit-check-not=-serialize-diagnostics= --implicit-check-not=.sarif --implicit-check-not=header-from-map

// BITCODE: -serialize-diagnostics-path {{[^ ]*}}bridging-header-{{[^ ]*}}.dia
// BITCODE-SAME: -emit-pch
// BITCODE: -primary-file {{[^ ]*}}sarif-diagnostics-output-file-map.swift
// BITCODE-SAME: -serialize-diagnostics-path {{[^ ]*}}main-from-map.dia

// REQUIRES: cplusplus_driver

let y = x
