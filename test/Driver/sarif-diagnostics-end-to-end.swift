// The driver and the frontend together produce the SARIF logs the driver
// plans, including when paths travel in a supplementary output file map and
// for a PCH job.
//
// Each file also gets only its own diagnostics when compiled separately.
// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: echo "{\"%/t/a.swift\": {\"sarif-diagnostics\": \"%/t/a.sarif\"}, \"%/t/b.swift\": {\"sarif-diagnostics\": \"%/t/b.sarif\"}}" > %t/separate.json
// RUN: %swiftc_driver -disallow-use-new-driver -typecheck -module-name Separate -serialize-diagnostics=sarif -output-file-map %t/separate.json %t/a.swift %t/b.swift
// RUN: %FileCheck --input-file=%t/a.sarif %s -check-prefix=A
// RUN: %FileCheck --input-file=%t/b.sarif %s -check-prefix=B

// A-NOT: inB
// A: "text" : "initialization of immutable value 'inA' was never used
// A-NOT: inB

// B-NOT: inA
// B: "text" : "initialization of immutable value 'inB' was never used
// B-NOT: inA

// In whole-module mode one frontend job compiles both files into one log.
// Forcing filelists puts its path in a supplementary output file map, which
// does not carry the format, so the format has to be passed alongside it.
// RUN: echo "{\"\": {\"sarif-diagnostics\": \"%/t/module.sarif\"}}" > %t/wmo.json
// RUN: %swiftc_driver -disallow-use-new-driver -typecheck -wmo -module-name WMO -driver-filelist-threshold=0 -serialize-diagnostics=sarif -output-file-map %t/wmo.json %t/a.swift %t/b.swift -v 2>&1 | %FileCheck %s -check-prefix=WMO-JOB
// RUN: %FileCheck --input-file=%t/module.sarif %s -check-prefix=WMO

// WMO-JOB: -supplementary-output-file-map {{[^ ]+}}
// WMO-JOB-SAME: -serialize-diagnostics=sarif

// WMO: "text" : "initialization of immutable value 'inA' was never used
// WMO: "text" : "initialization of immutable value 'inB' was never used

// A warning in a bridging header is reported only by the job that builds the
// PCH, so that is the log that has to hold it. The PCH's log is named after the
// header and the module path, inside the PCH output directory.
// RUN: echo "{\"%/t/c.swift\": {\"sarif-diagnostics\": \"%/t/c.sarif\"}}" > %t/pch.json
// RUN: %swiftc_driver -disallow-use-new-driver -emit-module -module-name PCH -emit-module-path %t/PCH.swiftmodule -serialize-diagnostics=sarif -output-file-map %t/pch.json -import-objc-header %t/header.h -pch-output-dir %t/pch %t/c.swift
// RUN: cat %t/pch/header-*.sarif | %FileCheck %s -check-prefix=HEADER
// RUN: %FileCheck --input-file=%t/c.sarif %s -check-prefix=COMPILE

// HEADER: "uri" : "file://{{.*}}header.h"
// HEADER: "text" : "\"warning from the bridging header\""
// HEADER: "ruleId" : "warning_from_clang"

// COMPILE-NOT: warning from the bridging header
// COMPILE: "text" : "initialization of immutable value 'inC' was never used
// COMPILE-NOT: warning from the bridging header

// REQUIRES: cplusplus_driver
// REQUIRES: swift_sarif
// REQUIRES: objc_interop

//--- a.swift
func a() { let inA = 1 }

//--- b.swift
func b() { let inB = 1 }

//--- c.swift
func c() { let inC = 1 }

//--- header.h
#warning "warning from the bridging header"
