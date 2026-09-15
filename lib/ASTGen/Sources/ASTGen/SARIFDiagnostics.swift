//===--- SARIFDiagnostics.swift -------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// Serialization of queued compiler diagnostics to the Static Analysis Results
// Interchange Format (SARIF) v2.1.0.
//
//===----------------------------------------------------------------------===//

import BasicBridging
import Foundation
import SARIF
import SwiftDiagnostics
import SwiftSyntax

extension DiagnosticSeverity {
  /// The SARIF result kind and level for this severity.
  ///
  /// SARIF requires 'level' to be "none" whenever 'kind' is not "fail", so a
  /// remark maps to an informational result rather than carrying a level.
  fileprivate var sarifKind: Result.Kind {
    switch self {
    case .error: return .fail(level: .error)
    case .warning: return .fail(level: .warning)
    case .remark: return .informational
    case .note: return .fail(level: .note)
    }
  }
}

extension ExportedSourceFile {
  /// The 1-based UTF-16 code unit column of \c position within its line.
  ///
  /// 'SourceLocationConverter' reports a column as a UTF-8 byte offset, while
  /// SARIF measures it in the unit named by the run's 'columnKind'. The two
  /// agree only for lines that are entirely ASCII, so the bytes preceding the
  /// position on its line have to be re-counted.
  fileprivate func utf16Column(
    of position: AbsolutePosition, utf8Column: Int
  ) -> Int {
    // 'utf8Column' is 1-based, so the line begins that many bytes back.
    let lineStart = position.utf8Offset - (utf8Column - 1)
    guard lineStart >= 0, position.utf8Offset <= buffer.count else {
      return utf8Column
    }

    let linePrefix = buffer[lineStart..<position.utf8Offset]
    return String(decoding: linePrefix, as: UTF8.self).utf16.count + 1
  }
}

/// Builds a SARIF log from a set of queued diagnostics.
private struct SARIFLogBuilder {
  let log: SARIFLog
  let driver: ToolComponent
  let run: Run

  /// Artifacts created so far, keyed by index into
  /// 'QueuedDiagnostics.sourceFiles'.
  private var artifacts: [Int: Artifact] = [:]

  /// Rules created so far, keyed by diagnostic identifier. Rules must be
  /// registered with the tool component rather than constructed directly, so
  /// that the run's 'rules' array and each result's rule index stay consistent.
  private var rules: [String: Rule] = [:]

  init(compilerVersion: String) {
    self.driver = ToolComponent(named: "Swift Compiler")
    self.driver.version = compilerVersion
    self.driver.informationUri = URL(string: "https://swift.org")
    self.driver.organization = "Swift Project"

    self.log = SARIFLog(version: .v2_1_0)
    self.run = log.addRun(tool: Tool(driver: driver))

    // SARIF measures columns in the unit named here. Consumers disagree on what
    // the default is when it is absent, so state it rather than imply it.
    self.run.columnKind = .utf16CodeUnits
  }

  /// The artifact for a source file, creating it on first use so that files
  /// without diagnostics do not appear in the log.
  private mutating func artifact(
    forSourceFileAt index: Int, in sourceFiles: [ExportedSourceFile]
  ) -> Artifact {
    if let existing = artifacts[index] {
      return existing
    }

    let artifact = run.addArtifact()
    artifact.location = ArtifactLocation(
      uri: URL(fileURLWithPath: sourceFiles[index].fileName), uriBaseId: nil)
    artifact.sourceLanguage = "swift"
    artifacts[index] = artifact

    return artifact
  }

  private mutating func rule(id: String) -> Rule {
    if let existing = rules[id] {
      return existing
    }

    let rule = driver.addRule(id: id)
    rules[id] = rule

    return rule
  }

  /// The SARIF location for a diagnostic at \c position in the source file at
  /// \c sourceFileIndex.
  private mutating func location(
    at position: AbsolutePosition, inSourceFileAt sourceFileIndex: Int,
    in sourceFiles: [ExportedSourceFile], message: Message? = nil
  ) -> Location {
    let sourceFile = sourceFiles[sourceFileIndex]
    let converted = sourceFile.sourceLocationConverter.location(for: position)
    let column = sourceFile.utf16Column(
      of: position, utf8Column: converted.column)

    let artifact = self.artifact(
      forSourceFileAt: sourceFileIndex, in: sourceFiles)

    let region = Region(
      text: TextRegion(line: Int32(converted.line), column: Int32(column)))

    return Location(
      at: PhysicalLocation(
        artifactLocation: ArtifactLocationReference(to: artifact),
        region: region),
      message: message)
  }

  /// Add a result for a diagnostic in a source file.
  ///
  /// Notes currently become results of their own. Attaching them to the
  /// diagnostic they belong to, as SARIF related locations, needs the bridge to
  /// carry that relationship and is left to a later change.
  mutating func addResult(
    for diagnostic: Diagnostic, inSourceFileAt sourceFileIndex: Int,
    in sourceFiles: [ExportedSourceFile]
  ) {
    let result = makeResult(for: diagnostic.diagMessage)
    result.locations = [
      location(
        at: diagnostic.position, inSourceFileAt: sourceFileIndex,
        in: sourceFiles)
    ]
  }

  /// Add a result for a diagnostic raised without a source location, such as a
  /// failure to open an input file.
  ///
  /// The result has no locations. Dropping these would let a failed compilation
  /// produce a log that looks clean.
  mutating func addResult(forUnlocated message: SimpleDiagnostic) {
    makeResult(for: message).locations = []
  }

  /// The result for a diagnostic message, before any location is attached.
  private mutating func makeResult(for message: any DiagnosticMessage) -> Result {
    // 'MessageID' does not let its parts be read back out, so the rule
    // identifier comes from 'SimpleDiagnostic', which is the only message the
    // bridge builds. Anything else would be a bug here, not a reason to fail
    // the compilation.
    let ruleID = (message as? SimpleDiagnostic)?.id ?? "unknown"

    let result = run.addResult(
      rule: rule(id: ruleID), messageText: message.message)
    result.kind = message.severity.sarifKind

    return result
  }
}

/// Render the queued diagnostics as a SARIF log.
///
/// Returns true on success, writing the log into 'renderedString'. On failure,
/// writes a message into 'errorMessageOut' and returns false. The caller writes
/// the log out, so that failures to do so are reported the same way as for the
/// compiler's other outputs.
@_cdecl("swift_ASTGen_renderQueuedDiagnosticsAsSARIF")
public func renderQueuedDiagnosticsAsSARIF(
  queuedDiagnosticsPtr: UnsafeMutableRawPointer?,
  compilerVersion: BridgedStringRef,
  renderedString: UnsafeMutablePointer<BridgedStringRef>,
  errorMessageOut: UnsafeMutablePointer<BridgedStringRef>
) -> Bool {
  // A compilation that produced no diagnostics never created a queue; emit a
  // log with no results rather than no log at all.
  let queuedDiagnostics = queuedDiagnosticsPtr?.assumingMemoryBound(
    to: QueuedDiagnostics.self
  )

  var builder = SARIFLogBuilder(
    compilerVersion: String(bridged: compilerVersion))

  if let queued = queuedDiagnostics?.pointee {
    // 'sourceFileIDs' is in the order the source files were added, and
    // 'addQueuedSourceFile' appends to 'sourceFiles' in that same order, so the
    // two line up by position.
    for (sourceFileIndex, sourceFileID) in queued.grouped.sourceFileIDs.enumerated() {
      for diagnostic in queued.grouped.diagnostics(in: sourceFileID) {
        builder.addResult(
          for: diagnostic, inSourceFileAt: sourceFileIndex,
          in: queued.sourceFiles)
      }
    }

    for message in queued.unlocatedDiagnostics {
      builder.addResult(forUnlocated: message)
    }
  }

  do {
    // Terminate the last line, as for any other text file the compiler writes.
    let json = try builder.log.toJSONString(formatting: .pretty) + "\n"
    renderedString.pointee = allocateBridgedString(json)
  } catch {
    errorMessageOut.pointee = allocateBridgedString(
      "could not serialize SARIF diagnostics: \(error)")
    return false
  }

  return true
}
