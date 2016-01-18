//
//  SwiftLangSupport.swift
//  SwiftSourceKit
//
//  Source kit UIDS for the Swift programming language.

import sourcekitd

public let SourceSwiftDeclFunctionFree = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.free")
public let SourceSwiftRefFunctionFree = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.free")
public let SourceSwiftDeclMethodInstance = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.method.instance")
public let SourceSwiftRefMethodInstance = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.method.instance")
public let SourceSwiftDeclMethodStatic = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.method.static")
public let SourceSwiftRefMethodStatic = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.method.static")
public let SourceSwiftDeclMethodClass = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.method.class")
public let SourceSwiftRefMethodClass = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.method.class")
public let SourceSwiftDeclAccessorGetter = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.accessor.getter")
public let SourceSwiftRefAccessorGetter = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.accessor.getter")
public let SourceSwiftDeclAccessorSetter = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.accessor.setter")
public let SourceSwiftRefAccessorSetter = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.accessor.setter")
public let SourceSwiftDeclAccessorWillSet = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.accessor.willset")
public let SourceSwiftRefAccessorWillSet = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.accessor.willset")
public let SourceSwiftDeclAccessorDidSet = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.accessor.didset")
public let SourceSwiftRefAccessorDidSet = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.accessor.didset")
public let SourceSwiftDeclAccessorAddress = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.accessor.address")
public let SourceSwiftRefAccessorAddress = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.accessor.address")
public let SourceSwiftDeclAccessorMutableAddress = sourcekitd_uid_get_from_cstr(
"source.lang.swift.decl.function.accessor.mutableaddress")
public let SourceSwiftRefAccessorMutableAddress = sourcekitd_uid_get_from_cstr(
"source.lang.swift.ref.function.accessor.mutableaddress")
public let SourceSwiftDeclConstructor = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.constructor")
public let SourceSwiftRefConstructor = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.constructor")
public let SourceSwiftDeclDestructor = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.destructor")
public let SourceSwiftRefDestructor = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.destructor")
public let SourceSwiftDeclFunctionPrefixOperator = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.operator.prefix")
public let SourceSwiftDeclFunctionPostfixOperator = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.operator.postfix")
public let SourceSwiftDeclFunctionInfixOperator = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.operator.infix")
public let SourceSwiftRefFunctionPrefixOperator = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.operator.prefix")
public let SourceSwiftRefFunctionPostfixOperator = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.operator.postfix")
public let SourceSwiftRefFunctionInfixOperator = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.operator.infix")
public let SourceSwiftDeclSubscript = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.function.subscript")
public let SourceSwiftRefSubscript = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.function.subscript")
public let SourceSwiftDeclVarGlobal = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.var.global")
public let SourceSwiftRefVarGlobal = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.var.global")
public let SourceSwiftDeclVarInstance = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.var.instance")
public let SourceSwiftRefVarInstance = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.var.instance")
public let SourceSwiftDeclVarStatic = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.var.static")
public let SourceSwiftRefVarStatic = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.var.static")
public let SourceSwiftDeclVarClass = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.var.class")
public let SourceSwiftRefVarClass = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.var.class")
public let SourceSwiftDeclVarLocal = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.var.local")
public let SourceSwiftRefVarLocal = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.var.local")
public let SourceSwiftDeclVarParam = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.var.parameter")
public let SourceSwiftDeclModule = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.module")
public let SourceSwiftDeclClass = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.class")
public let SourceSwiftRefClass = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.class")
public let SourceSwiftDeclStruct = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.struct")
public let SourceSwiftRefStruct = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.struct")
public let SourceSwiftDeclEnum = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.enum")
public let SourceSwiftRefEnum = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.enum")
public let SourceSwiftDeclEnumCase = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.enumcase")
public let SourceSwiftDeclEnumElement = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.enumelement")
public let SourceSwiftRefEnumElement = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.enumelement")
public let SourceSwiftDeclProtocol = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.protocol")
public let SourceSwiftRefProtocol = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.protocol")
public let SourceSwiftDeclExtension = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.extension")
public let SourceSwiftDeclExtensionStruct = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.extension.struct")
public let SourceSwiftDeclExtensionClass = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.extension.class")
public let SourceSwiftDeclExtensionEnum = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.extension.enum")
public let SourceSwiftDeclExtensionProtocol = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.extension.protocol")
public let SourceSwiftDeclTypeAlias = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.typealias")
public let SourceSwiftRefTypeAlias = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.typealias")
public let SourceSwiftDeclGenericTypeParam = sourcekitd_uid_get_from_cstr("source.lang.swift.decl.generic_type_param")
public let SourceSwiftRefGenericTypeParam = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.generic_type_param")
public let SourceSwiftRefModule = sourcekitd_uid_get_from_cstr("source.lang.swift.ref.module")
public let SourceSwiftStmtForEach = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.foreach")
public let SourceSwiftStmtFor = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.for")
public let SourceSwiftStmtWhile = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.while")
public let SourceSwiftStmtRepeatWhile = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.repeatwhile")
public let SourceSwiftStmtIf = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.if")
public let SourceSwiftStmtGuard = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.guard")
public let SourceSwiftStmtSwitch = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.switch")
public let SourceSwiftStmtCase = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.case")
public let SourceSwiftStmtBrace = sourcekitd_uid_get_from_cstr("source.lang.swift.stmt.brace")
public let SourceSwiftExprCall = sourcekitd_uid_get_from_cstr("source.lang.swift.expr.call")
public let SourceSwiftExprArray = sourcekitd_uid_get_from_cstr("source.lang.swift.expr.array")
public let SourceSwiftExprDictionary = sourcekitd_uid_get_from_cstr("source.lang.swift.expr.dictionary")
public let SourceSwiftExprObjectLiteral = sourcekitd_uid_get_from_cstr("source.lang.swift.expr.object_literal")

public let SourceSwiftStructureElemId = sourcekitd_uid_get_from_cstr("source.lang.swift.structure.elem.id")
public let SourceSwiftStructureElemExpr = sourcekitd_uid_get_from_cstr("source.lang.swift.structure.elem.expr")
public let SourceSwiftStructureElemInitExpr = sourcekitd_uid_get_from_cstr("source.lang.swift.structure.elem.init_expr")
public let SourceSwiftStructureElemCondExpr = sourcekitd_uid_get_from_cstr("source.lang.swift.structure.elem.condition_expr")
public let SourceSwiftStructureElemPattern = sourcekitd_uid_get_from_cstr("source.lang.swift.structure.elem.pattern")
public let SourceSwiftStructureElemTypeRef = sourcekitd_uid_get_from_cstr("source.lang.swift.structure.elem.typeref")
