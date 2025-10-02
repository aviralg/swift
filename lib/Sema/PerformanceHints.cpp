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
#include "swift/AST/TypeRepr.h"

using namespace swift;

bool swift::performanceHintDiagnosticsEnabled(ASTContext &ctx) {
  return !ctx.Diags.isIgnoredDiagnostic(diag::perf_hint_closure_returns_array.ID) ||
         !ctx.Diags.isIgnoredDiagnostic(diag::perf_hint_function_returns_array.ID);
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

class HasExistentialAnyType : public TypeVisitor<HasExistentialAnyType, bool> {
public:
  static bool check(Type type) {
    return HasExistentialAnyType().visit(type->getCanonicalType());
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

StringRef getFunctionKind(const FuncDecl *FD) {
  // Check for specific declaration types
  if (isa<ConstructorDecl>(FD)) {
    return "Constructor";
  }

  if (auto *accessor = dyn_cast<AccessorDecl>(FD)) {
    return accessor->isObservingAccessor() ? "Observer" : "Accessor";
  }

  if (FD->hasImplicitSelfDecl()) {
    if (FD->isStatic()) {
      return "Static method";
    }
    return "Method";
  }

  return "Function";
}

void checkFunctionParameterForExistentialAny(const ParamDecl *PD,
                                             DiagnosticEngine& Diags,
                                             StringRef Kind) {

  // TODO - handle autoclosure type

  Type ParamType =
      PD->getDeclContext()->mapTypeIntoContext(PD->getInterfaceType());

  if (PD->isVariadic()) {
    // Extract underlying type from VariadicSequenceType
    const VariadicSequenceType *variadicSeqType =
        dyn_cast<VariadicSequenceType>(ParamType);
    assert(variadicSeqType &&
           "Variadic parameter should have a VariadicSequenceType");
    ParamType = variadicSeqType->getBaseType();
  }

  // assert(T);

  const bool isExistential = HasExistentialAnyType::check(ParamType);

  if (!isExistential)
    return;

  SourceLoc SL = PD->getLoc();
  if (const TypeRepr *TR = PD->getTypeRepr()) {
    SL = TR->getLoc();
  }

  Diags.diagnose(SL, diag::perf_hint_func_param_has_existential, Kind);
}

// TODO - autoclosure errors point to ->
// TODO - (any Person)? error points to ?
// Closure return type is nullptr, leads to crashes, so we don't check it for
// existential any

void checkExistentialAnyType(FuncDecl *FD, DiagnosticEngine &Diags) {
  StringRef Kind = getFunctionKind(FD);

  for (const ParamDecl *PD : *(FD->getParameters())) {
      checkFunctionParameterForExistentialAny(PD, Diags, Kind);
  }

  Type ResultType = FD->mapTypeIntoContext(FD->getResultInterfaceType());
  if(HasExistentialAnyType::check(ResultType))
    Diags.diagnose(FD, diag::perf_hint_func_returns_existential, FD);
}

void checkExistentialAnyType(ClosureExpr *CE, DiagnosticEngine &Diags) {
  StringRef Kind = "Closure";

  for (const ParamDecl *PD : *(CE->getParameters())) {
      checkFunctionParameterForExistentialAny(PD, Diags, Kind);
  }

  Type ResultType = CE->mapTypeIntoContext(CE->getResultType());
  if(HasExistentialAnyType::check(ResultType))
    Diags.diagnose(CE, diag::perf_hint_closure_returns_existential);
}

void checkExistentialAnyType(VarDecl *VD, DiagnosticEngine &Diags) {
  Type type = VD->getInterfaceType();

  if (!HasExistentialAnyType::check(type))
    return;

  const DeclContext *DC = VD->getDeclContext();

  const bool isProperty = (DC->getSelfClassDecl() != nullptr) ||
                          (DC->getSelfEnumDecl() != nullptr) ||
                          (DC->getSelfStructDecl() != nullptr) ||
                          (DC->getSelfProtocolDecl() != nullptr) ||
                          (DC->getExtendedProtocolDecl() != nullptr);

  const StringRef kind = isProperty ? "Property" : "Variable";

  SourceLoc SL = VD->getLoc();

  if (const TypeRepr *TR = VD->getTypeReprOrParentPatternTypeRepr()) {
    SL = TR->getLoc();
  }

  Diags.diagnose(SL, diag::perf_hint_var_has_existential, kind, VD);
}

void checkExistentialAnyType(EnumElementDecl *EED, DiagnosticEngine &Diags) {
  const EnumDecl *ED = EED->getParentEnum();

  if (const ParameterList *PL = EED->getParameterList()) {
    for (const int index : indices(*PL)) {
      const ParamDecl *PD = PL->get(index);
      const Type type = PD->getInterfaceType()->getCanonicalType();

      if (HasExistentialAnyType::check(type)) {

        // If there is no label name, report the index
        //        if (PD->getArgumentName().empty()) {
        //        Diags.diagnose(PD->getTypeRepr()->getLoc(),
        // diag::perf_hint_indexed_enum_case_has_existential, index,
        //               EED, ED);
        //} else {
        Diags.diagnose(PD, diag::perf_hint_param_has_existential, PD);
      }
    }
  }
}

/// Produce performance hint diagnostics for a SourceFile.
class PerformanceHintDiagnosticWalker final : public ASTWalker {
  ASTContext &Ctx;

public:
  PerformanceHintDiagnosticWalker(ASTContext &Ctx) : Ctx(Ctx) {}

  static void check(SourceFile *SF) {
    auto Walker = PerformanceHintDiagnosticWalker(SF->getASTContext());
    SF->walk(Walker);
  }

  PreWalkResult<Expr *> walkToExprPre(Expr *E) override {
    if (auto Closure = dyn_cast<ClosureExpr>(E)) {
      checkImplicitCopyReturnType(Closure, Ctx.Diags);
      checkExistentialAnyType(Closure, Ctx.Diags);
    }

    return Action::Continue(E);
  }

  PreWalkAction walkToDeclPre(Decl *D) override {
    if (auto *FD = dyn_cast<FuncDecl>(D)) {
      checkImplicitCopyReturnType(FD, Ctx.Diags);
      checkExistentialAnyType(FD, Ctx.Diags);
    } else if (auto *VD = dyn_cast<VarDecl>(D)) {
      checkExistentialAnyType(VD, Ctx.Diags);
    } else if (auto *EED = dyn_cast<EnumElementDecl>(D)) {
      checkExistentialAnyType(EED, Ctx.Diags);
    }

    return Action::Continue();
  }
};
} // namespace
