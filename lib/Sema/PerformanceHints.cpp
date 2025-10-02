//===--------------------- PerformanceHints.cpp ---------------------------===//
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

#include "MiscDiagnostics.h"
#include "swift/AST/ASTContext.h"
#include "swift/AST/ASTWalker.h"
#include "swift/AST/Decl.h"
#include "swift/AST/DiagnosticsFrontend.h"
#include "swift/AST/DiagnosticsSema.h"
#include "swift/AST/Evaluator.h"
#include "swift/AST/Expr.h"
#include "swift/AST/TypeCheckRequests.h"
#include "swift/AST/TypeVisitor.h"

using namespace swift;

bool swift::performanceHintDiagnosticsEnabled(ASTContext &ctx) {
  return !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_closure_returns_array.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_function_returns_array.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_param_expects_existential_any.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_func_returns_existential_any.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_closure_returns_existential_any.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_var_uses_existential_any.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_any_pattern_uses_existential_any.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(
             diag::perf_hint_typealias_uses_existential_any.ID);
}

namespace {

void checkImplicitCopyReturnType(const FuncDecl *FD, DiagnosticEngine &Diags) {
  auto ReturnType = FD->getResultInterfaceType();
  if (ReturnType->isArray() || ReturnType->isDictionary()) {
    Diags.diagnose(FD->getLoc(), diag::perf_hint_function_returns_array, FD,
                   ReturnType->isArray());
  }
}

void checkImplicitCopyReturnType(const ClosureExpr *Closure,
                                 DiagnosticEngine &Diags) {
  auto ReturnType = Closure->getResultType();
  if (ReturnType->isArray() || ReturnType->isDictionary()) {
    Diags.diagnose(Closure->getLoc(), diag::perf_hint_closure_returns_array,
                   ReturnType->isArray());
  }
}

class CheckExistentialAny : public TypeVisitor<CheckExistentialAny, bool> {
public:
  static bool inType(Type type) {
    return CheckExistentialAny().visit(type->getCanonicalType());
  }

  static void inFunctionReturnType(FuncDecl *FD, DiagnosticEngine &Diags) {
    Type T = FD->getResultInterfaceType();

    if (inType(T))
      Diags.diagnose(FD, diag::perf_hint_func_returns_existential_any, FD);
  }

  static void inClosureReturnType(ClosureExpr *CE, DiagnosticEngine &Diags) {
    Type T = CE->getResultType();

    if (inType(T))
      Diags.diagnose(CE->getLoc(),
                     diag::perf_hint_closure_returns_existential_any);
  }

  static void inVariableType(const VarDecl *VD, DiagnosticEngine &Diags) {
    Type T = VD->getInterfaceType();

    if (inType(T))
      Diags.diagnose(VD, diag::perf_hint_var_uses_existential_any, VD);
  }

  static void inPatternType(const AnyPattern *AP, DiagnosticEngine &Diags) {
    Type T = AP->getType();

    if (inType(T))
      Diags.diagnose(AP->getLoc(),
                     diag::perf_hint_any_pattern_uses_existential_any);
  }

  static void inTypeAlias(const TypeAliasDecl *TAD, DiagnosticEngine &Diags) {
    Type T = TAD->getUnderlyingType();

    if (inType(T))
      Diags.diagnose(TAD->getLoc(),
                     diag::perf_hint_typealias_uses_existential_any, TAD);
  }

  bool visitExistentialType(ExistentialType *ET) {
    return true;
  }

  bool visitTupleType(TupleType *TT) {
    for (const auto &element : TT->getElements()) {
      if (visit(element.getType())) {
        return true;
      }
    }
    return false;
  }

  bool visitBoundGenericType(BoundGenericType *BGT) {
    // Check generic arguments (e.g., Array<any Protocol>)
    for (Type arg : BGT->getGenericArgs()) {
      if (visit(arg)) {
        return true;
      }
    }
    return false;
  }

  bool visitFunctionType(FunctionType *FT) {
    for (const auto &param : FT->getParams()) {
      if (visit(param.getPlainType()->getCanonicalType())) {
        return true;
      }
    }

    return visit(FT->getResult()->getCanonicalType());
  }

  bool visitType(TypeBase *T) {
    return false;
  }
};

/// Produce performance hint diagnostics for a SourceFile.
class PerformanceHintDiagnosticWalker final : public ASTWalker {
  ASTContext &Ctx;

public:
  PerformanceHintDiagnosticWalker(ASTContext &Ctx) : Ctx(Ctx) {}

  static void check(SourceFile *SF) {
    auto Walker = PerformanceHintDiagnosticWalker(SF->getASTContext());
    SF->walk(Walker);
  }

  PreWalkResult<Pattern *> walkToPatternPre(Pattern *P) override {
    if (P->isImplicit())
      return Action::SkipNode(P);

    if (const AnyPattern *AP = dyn_cast<AnyPattern>(P)) {
      CheckExistentialAny::inPatternType(AP, Ctx.Diags);
    }

    return Action::Continue(P);
  }

  PreWalkResult<Expr *> walkToExprPre(Expr *E) override {
    if (E->isImplicit())
      return Action::SkipNode(E);

    if (const ClosureExpr* Closure = dyn_cast<ClosureExpr>(E)) {
      checkImplicitCopyReturnType(Closure, Ctx.Diags);
    }

    return Action::Continue(E);
  }

  PostWalkResult<Expr *> walkToExprPost(Expr *E) override {
    assert(
        !E->isImplicit() &&
        "Traversing implicit expressions is disabled in the pre-walk visitor");

    if (auto Closure = dyn_cast<ClosureExpr>(E)) {
      CheckExistentialAny::inClosureReturnType(Closure, Ctx.Diags);
    }

    return Action::Continue(E);
  }

  PreWalkAction walkToDeclPre(Decl *D) override {
    if (D->isImplicit())
      return Action::SkipNode();

    if (const FuncDecl *FD = dyn_cast<FuncDecl>(D)) {
      checkImplicitCopyReturnType(FD, Ctx.Diags);
    } else if (const VarDecl *VD = dyn_cast<VarDecl>(D)) {
      CheckExistentialAny::inVariableType(VD, Ctx.Diags);
    } else if (const TypeAliasDecl *TAD = dyn_cast<TypeAliasDecl>(D)) {
      CheckExistentialAny::inTypeAlias(TAD, Ctx.Diags);
    }

    return Action::Continue();
  }

  PostWalkAction walkToDeclPost(Decl *D) override {
    assert(
        !D->isImplicit() &&
        "Traversing implicit declarations is disabled in the pre-walk visitor");

    if (auto *FD = dyn_cast<FuncDecl>(D)) {
      CheckExistentialAny::inFunctionReturnType(FD, Ctx.Diags);
    }

    return Action::Continue();
  }
};
} // namespace

evaluator::SideEffect EmitPerformanceHints::evaluate(Evaluator &evaluator,
                                                     SourceFile *SF) const {
  PerformanceHintDiagnosticWalker::check(SF);
  return {};
}
