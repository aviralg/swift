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
#include "swift/AST/TypeVisitor.h"
#include "swift/AST/TypeRepr.h"

using namespace swift;

evaluator::SideEffect SPACheckFunctionReturnType::evaluate(Evaluator &evaluator,
                                                           FuncDecl *FD) const {
  if (auto *attr = FD->getAttrs().getAttribute<SPAOverrideAttr>())
    return {};

  auto returnType = FD->getResultInterfaceType();
  if (returnType->isArray() || returnType->isDictionary()) {
    FD->getASTContext()
        .Diags
        .diagnose(FD->getLoc(), diag::spa_function_returns_array, FD,
                  returnType->isArray());
  }
  return {};
}

evaluator::SideEffect SPACheckClassDefinition::evaluate(Evaluator &evaluator,
                                                        ClassDecl *CD) const {
  if (auto *attr = CD->getAttrs().getAttribute<SPAOverrideAttr>())
    return {};

  CD->getASTContext()
    .Diags
    .diagnose(CD->getLoc(), diag::spa_module_defines_class, CD);

  return {};
}

/*
  class ExistentialTypeChecker : public TypeVisitor<ExistentialTypeChecker, bool> {
  public:
    // Visit ExistentialType nodes - this is the key method
    bool visitExistentialType(ExistentialType *ET) {
      return true; // Found existential type
    }

    // Visit ArraySliceType - handles [any Person] syntax
    bool visitArraySliceType(ArraySliceType *AST) {
      return visit(AST->getBaseType()); // Check the element type
    }

    // Visit other composite types to recurse into them
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
      // Check parameters
      for (const auto &param : FT->getParams()) {
        if (visit(param.getPlainType())) {
          return true;
        }
      }
      // Check return type
      return visit(FT->getResult());
    }

    bool visitOptionalType(OptionalType *OT) {
      return visit(OT->getBaseType());
    }

    bool visitImplicitlyUnwrappedOptionalType(ImplicitlyUnwrappedOptionalType *IOT) {
      return visit(IOT->getBaseType());
    }

    bool visitMetatypeType(MetatypeType *MT) {
      return visit(MT->getInstanceType());
    }

    bool visitExistentialMetatypeType(ExistentialMetatypeType *EMT) {
      return visit(EMT->getInstanceType());
    }

    bool visitVariadicSequenceType(VariadicSequenceType *VST) {
      return visit(VST->getBaseType());
    }

    // Default case for leaf types
    bool visitType(TypeBase *T) {
      return false;
    }
  };
*/
class FindAnyExistentialType : public TypeVisitor<FindAnyExistentialType, bool> {
  public:
  // Visit ExistentialType nodes
  bool visitExistentialType(ExistentialType *ET) {
    return true;
  }

  // Visit other composite types to recurse into them
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
    // Check parameters
    for (const auto &param : FT->getParams()) {
      if (visit(param.getPlainType()->getCanonicalType())) {
        return true;
      }
    }
    // Check return type
    return visit(FT->getResult()->getCanonicalType());
  }

  // Default case for other types - do nothing
  bool visitType(TypeBase *T) {
    return false;
  }
};

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/types/#app-top
static bool hasAnyExistentialType(Type type) {
  return FindAnyExistentialType().visit(type->getCanonicalType());
  // if (type->isAnyExistentialType())
  //   return true;

  // if (type->isArray())
  //   return hasAnyExistentialType(type->getGenericArgs()[0]);
}


evaluator::SideEffect SPACheckFunctionExistentialAny::evaluate(Evaluator &evaluator,
                                                               FuncDecl *FD) const {
  if (auto *attr = FD->getAttrs().getAttribute<SPAOverrideAttr>())
    return {};

  const ParameterList* params = FD->getParameterList();
  for (const ParamDecl* PD: *params) {

    // Check if parameter is variadic first
    if (PD->isVariadic()) {
      // Get the parameter type
      Type paramType = PD->getInterfaceType();

      // Extract underlying type from VariadicSequenceType
      if (auto *variadicType = dyn_cast<VariadicSequenceType>(paramType)) {
	Type underlyingType = variadicType->getBaseType();
	if (hasAnyExistentialType(underlyingType) /*underlyingType->isAnyExistentialType()*/) {
	  FD->getASTContext()
	    .Diags
	    .diagnose(FD->getLoc(), diag::spa_function_param_is_existential, FD, PD);
	}	
      }
    }
    else {
      const Type paramType = PD->getInterfaceType();
      const bool isExistential = hasAnyExistentialType(paramType); //paramType->isAnyExistentialType();
      if (isExistential) {
	FD->getASTContext()
	  .Diags
	  .diagnose(FD->getLoc(), diag::spa_function_param_is_existential, FD, PD);
      }
    }
  }

  const Type resultType = FD->getResultInterfaceType();
  if (hasAnyExistentialType(resultType)) {
    FD->getASTContext()
      .Diags
      .diagnose(FD->getLoc(), diag::spa_function_returns_existential, FD);
  }
    
  return {};
}

evaluator::SideEffect SPACheckVariableExistentialAny::evaluate(Evaluator &evaluator,
							       VarDecl *VD) const {
  if (auto *attr = VD->getAttrs().getAttribute<SPAOverrideAttr>())
    return {};

  Type type = VD->getInterfaceType()->getCanonicalType();
  
  if (hasAnyExistentialType(type) /*underlyingType->isAnyExistentialType()*/) {
    VD->getASTContext()
      .Diags
      .diagnose(VD->getLoc(), diag::spa_var_is_existential, VD);
  }	

  return {};
}

evaluator::SideEffect
SPACheckEnumExistentialAny::evaluate(Evaluator &evaluator,
                                     EnumElementDecl *EED) const {
  // Attributes can be provided for EnumDecl but not for individual EnumElementDecl
  const EnumDecl* ED = EED->getParentEnum();
  if (auto *attr = ED->getAttrs().getAttribute<SPAOverrideAttr>())
    return {};

  if (const ParameterList* PL = EED->getParameterList()) {
    for (const int index : indices(*PL)) {
      const ParamDecl* PD = PL->get(index);
      const Type type = PD->getInterfaceType()->getCanonicalType();
      if (hasAnyExistentialType(type)) {
        DiagnosticEngine &Diags = PD->getASTContext().Diags;
	
	// If there is no label name, report the index
        if (PD->getArgumentName().empty()) {
	  Diags.diagnose(PD->getTypeRepr()->getLoc(), diag::spa_enum_case_indexed_has_existential, index, EED, ED);
        }
        else {
	  Diags.diagnose(PD, diag::spa_enum_case_named_has_existential, PD, EED, ED);
	}
      }
    }
  }

  return {};
}
