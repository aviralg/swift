//===--- WarningTreatmentRule.h -----------------------------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_BASIC_WARNINGTREATMENTRULE_H
#define SWIFT_BASIC_WARNINGTREATMENTRULE_H

#include "llvm/Support/ErrorHandling.h"
#include <string>
#include <variant>
#include <vector>

namespace swift {

/// Describes a rule how to treat a warning or all warnings.
class WarningTreatmentRule {
public:
  enum class Action { AsWarning, AsError, Suppress };
  struct TargetAll {};
  struct TargetGroup {
    std::string name;
  };
  using Target = std::variant<TargetAll, TargetGroup>;

  /// Init as a rule targeting all diagnostic groups
  WarningTreatmentRule(Action action) : action(action), target(TargetAll()) {}
  /// Init as a rule targeting a specific diagnostic group
  WarningTreatmentRule(Action action, const std::string &group)
      : action(action), target(TargetGroup{group}) {}

  Action getAction() const { return action; }

  Target getTarget() const { return target; }

  static bool hasConflictsWithSuppressWarnings(
      const std::vector<WarningTreatmentRule> &rules) {
    bool warningsAsErrorsAllEnabled = false;
    for (const auto &rule : rules) {
      const auto target = rule.getTarget();
      if (std::holds_alternative<TargetAll>(target)) {
        // Only `-warnings-as-errors` conflicts with `-suppress-warnings`
        switch (rule.getAction()) {
        case Action::AsError:
          warningsAsErrorsAllEnabled = true;
          break;
        case Action::AsWarning:
          warningsAsErrorsAllEnabled = false;
          break;
        case Action::Suppress:
          llvm_unreachable("cannot suppress all warnings");
          break;
        }
      } else if (std::holds_alternative<TargetGroup>(target)) {
        // Both `-Wwarning` and `-Werror` conflict with `-suppress-warnings`
        if (rule.getAction() == Action::AsError || rule.getAction() == Action::AsWarning)
          return true;
      } else {
        llvm_unreachable("unhandled WarningTreatmentRule::Target");
      }
    }
    return warningsAsErrorsAllEnabled;
  }

private:
  Action action;
  Target target;
};

} // end namespace swift

#endif // SWIFT_BASIC_WARNINGTREATMENTRULE_H
