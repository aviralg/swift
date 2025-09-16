//===--------------------- PerformanceAssistance.cpp ----------------------===//
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
//
// This files implements the various checks/lints intended to provide
// opt-in guidance for hidden costs in performance-critical Swift code.
//
//===----------------------------------------------------------------------===//

#include "swift/AST/ASTContext.h"
#include "swift/AST/DiagnosticsFrontend.h"
#include "swift/AST/DiagnosticsSema.h"
#include "swift/AST/Evaluator.h"
#include "swift/AST/TypeCheckRequests.h"

using namespace swift;

evaluator::SideEffect SPACheckFunctionReturnType::evaluate(Evaluator &evaluator,
                                                           FuncDecl *FD) const {
  // ACTODO: Check if this function has an override for this check

  auto returnType = FD->getResultInterfaceType();
  if (returnType->isArray() || returnType->isDictionary()) {
    FD->getASTContext()
        .Diags
        .diagnose(FD->getLoc(), diag::spa_function_returns_array, FD,
                  returnType->isArray())
        .limitBehaviorIf(false, DiagnosticBehavior::Warning);
  }
  return {};
}
