import org.eclipse.jdt.internal.compiler.batch.*;

import java.io.*;
import java.text.*;
import java.util.*;

import org.eclipse.jdt.core.compiler.*;
import org.eclipse.jdt.core.compiler.batch.*;
import org.eclipse.jdt.internal.compiler.*;
import org.eclipse.jdt.internal.compiler.Compiler;
import org.eclipse.jdt.internal.compiler.env.*;
import org.eclipse.jdt.internal.compiler.impl.*;
import org.eclipse.jdt.internal.compiler.ast.*;
import org.eclipse.jdt.internal.compiler.lookup.*;
import org.eclipse.jdt.internal.compiler.parser.*;
import org.eclipse.jdt.internal.compiler.problem.*;
import org.eclipse.jdt.internal.compiler.util.*;

// DQ (10/30/2010): Added support for reflection to get methods in implicitly included objects.
// import java.lang.reflect.*;


// DQ (10/12/2010): Make more like the OFP implementation (using Callable<Boolean> abstract base class). 
// class JavaTraversal {
import java.util.concurrent.Callable;
class JavaParser  implements Callable<Boolean> {
    // DQ (11/17/2010): This is the main class for the connection of the ECJ front-end to ROSE.
    // The design is that we use ECJ mostly unmodified, and use the visitor
    // traversal (ASTVisitor) of the ECJ AST.  Specifically we derive a class 
    // (ecjASTVisitory) from the abstract class (ASTVisitor in ECJ) and define
    // all of it's members so that we can support traversing the ECJ defined 
    // AST and construct the ROSE AST.  Most of the IR nodes used to support this
    // or borrowed from the existing C and C++ support in ROSE.  We will however
    // add any required IR nodes as needed.

    public static int verboseLevel = 0;

    // -------------------------------------------------------------------------------------------
    public static native void cactionTest();
    public static native void cactionCompilationUnitList(int argc, String[] argv);
    public static native void cactionProcessObject();

    // These are used in the ecjASTVisitor (which is derived from the ECJ ASTVisitor class).
    public static native void cactionCompilationUnitDeclaration(String filename, JavaToken jToken);
    public static native void cactionCompilationUnitDeclarationEnd(int java_numberOfStatements, JavaToken jToken);
    public static native void cactionTypeDeclaration(String filename, boolean is_interface, boolean is_abstract, boolean is_final, boolean is_private, boolean is_public, boolean is_protected, boolean is_static, boolean is_strictfp, JavaToken jToken);
    public static native void cactionTypeDeclarationHeader(boolean java_has_super_class, int java_numberOfinterfaces, int java_numberofTypeParameters, JavaToken jToken);
    public static native void cactionTypeDeclarationEnd(JavaToken jToken);

    // Need to change the names of the function parameters (should not all be "filename").
    public static native void cactionConstructorDeclaration(String filename, JavaToken jToken);
    public static native void cactionConstructorDeclarationHeader(String filename, boolean java_is_native, boolean java_is_private, int numberOfTypeParameters, int numberOfArguments, int numberOfThrows, JavaToken jToken);
    public static native void cactionConstructorDeclarationEnd(int java_numberOfStatements, JavaToken jToken);
    public static native void cactionExplicitConstructorCall(JavaToken jToken);
    public static native void cactionExplicitConstructorCallEnd(boolean is_implicit_super, boolean is_super, boolean has_qualification , int numberOfTypeArguments, int numberOfArguments, JavaToken jToken);
    public static native void cactionMethodDeclaration(String name, JavaToken jToken);
    public static native void cactionMethodDeclarationHeader(String name, boolean java_is_abstract, boolean java_is_native, boolean java_is_static, boolean java_is_final, boolean java_is_synchronized, boolean java_is_public, boolean java_is_protected, boolean java_is_private, boolean java_is_strictfp, int numberOfTypeParameters, int numArguments, int numThrows, JavaToken jToken);
    public static native void cactionMethodDeclarationEnd(int numberOfStatements, JavaToken jToken);
    public static native void cactionTypeReference(String filename, JavaToken jToken);
    public static native void cactionArgument(String argumentName, boolean is_catch_argument, JavaToken jToken);
    public static native void cactionArgumentEnd(String argumentName, boolean is_catch_argument, JavaToken jToken);
    public static native void cactionArrayTypeReference(String filename, int numberOfDimensions, JavaToken jToken);
    public static native void cactionArrayTypeReferenceEnd(String filename, int numberOfDimensions, JavaToken jToken);
    public static native void cactionMessageSend(String functionName, String associatedClassName, JavaToken jToken);

    public static native void cactionMessageSendEnd(int numTypeArguments, int numArguments, boolean is_static, JavaToken jToken);

    public static native void cactionQualifiedNameReference(String package_name, String type_prefix, String type_name, String name, JavaToken jToken);
    public static native void cactionStringLiteral(String value, JavaToken jToken);

    public static native void cactionAllocationExpression(JavaToken jToken);
    public static native void cactionAllocationExpressionEnd(String nameOfType, int numArguments, JavaToken jToken);
    public static native void cactionANDANDExpression(JavaToken jToken);
    public static native void cactionANDANDExpressionEnd(JavaToken jToken);
    public static native void cactionAnnotationMethodDeclaration(JavaToken jToken);
    public static native void cactionArgumentClassScope(String variableName, JavaToken jToken);
    public static native void cactionArrayAllocationExpression(JavaToken jToken);
    public static native void cactionArrayAllocationExpressionEnd(String nameOfType, int numberOfDimensions, boolean hasInitializers, JavaToken jToken);
    public static native void cactionArrayInitializer(JavaToken jToken);
    public static native void cactionArrayInitializerEnd(int numInitializers, JavaToken jToken);
    public static native void cactionArrayQualifiedTypeReference(JavaToken jToken);
    public static native void cactionArrayQualifiedTypeReferenceClassScope(JavaToken jToken);
    public static native void cactionArrayReference(JavaToken jToken);
    public static native void cactionArrayReferenceEnd(JavaToken jToken);
    public static native void cactionArrayTypeReferenceClassScope(String filename, JavaToken jToken);
     
    public static native void cactionAssertStatement(JavaToken jToken);
    public static native void cactionAssertStatementEnd(boolean hasExceptionArgument, JavaToken jToken);
     
    public static native void cactionAssignment(JavaToken jToken);
    public static native void cactionAssignmentEnd(JavaToken jToken);
    public static native void cactionBinaryExpression(JavaToken jToken);
    public static native void cactionBinaryExpressionEnd(int java_operator_kind, JavaToken jToken);
    public static native void cactionBlock(JavaToken jToken);
    public static native void cactionBlockEnd(int java_numberOfStatement, JavaToken jTokens);
    public static native void cactionBreakStatement(String labelName, JavaToken jToken);
    public static native void cactionCaseStatement(boolean hasCaseExpression, JavaToken jToken);
    public static native void cactionCaseStatementEnd(boolean hasCaseExpression, JavaToken jToken);

    public static native void cactionCastExpression(JavaToken jToken);
    public static native void cactionCastExpressionEnd(JavaToken jToken);
    public static native void cactionCharLiteral(char value, JavaToken jToken);
    public static native void cactionClassLiteralAccess(JavaToken jToken);
    public static native void cactionClinit(JavaToken jToken);
    public static native void cactionConditionalExpression(JavaToken jToken);
    public static native void cactionConditionalExpressionEnd(JavaToken jToken);
    public static native void cactionContinueStatement(String labelName, JavaToken jToken);
    public static native void cactionCompoundAssignment(JavaToken jToken);
    public static native void cactionCompoundAssignmentEnd(int java_operator_kind, JavaToken jToken);
    public static native void cactionDoStatement(JavaToken jToken);
    public static native void cactionDoStatementEnd(JavaToken jToken);
    public static native void cactionDoubleLiteral(double value, String source, JavaToken jToken);

    public static native void cactionEmptyStatement(JavaToken jToken);
    public static native void cactionEmptyStatementEnd(JavaToken jToken);

    public static native void cactionEqualExpression(JavaToken jToken);
    public static native void cactionEqualExpressionEnd(int java_operator_kind, JavaToken jToken);
    public static native void cactionExtendedStringLiteral(String value, JavaToken jToken);
    public static native void cactionFalseLiteral(JavaToken jToken);

    // public static native void cactionFieldDeclaration(String variableName, boolean java_hasInitializer, boolean java_is_final, boolean java_is_private, boolean java_is_protected, boolean java_is_public, boolean java_is_volatile, boolean java_is_synthetic, boolean java_is_static, boolean java_is_transient, JavaToken jToken);
    // public static native void cactionFieldDeclarationEnd(String variableName, boolean java_hasInitializer, JavaToken jToken);
    public static native void cactionFieldDeclarationEnd(String variableName, boolean java_hasInitializer, boolean java_is_final, boolean java_is_private, boolean java_is_protected, boolean java_is_public, boolean java_is_volatile, boolean java_is_synthetic, boolean java_is_static, boolean java_is_transient, JavaToken jToken);

    public static native void cactionFieldReference(String field_name, JavaToken jToken);
    public static native void cactionFieldReferenceEnd(String field_name, JavaToken jToken);

    public static native void cactionFieldReferenceClassScope(String field_name, JavaToken jToken);
    public static native void cactionFieldReferenceClassScopeEnd(String firld_name, JavaToken jToken);

    public static native void cactionFloatLiteral(float value, String source, JavaToken jToken);
     
    public static native void cactionForeachStatement(JavaToken jToken);
    public static native void cactionForeachStatementEnd(JavaToken jToken);
     
    public static native void cactionForStatement(JavaToken jToken);
    public static native void cactionForStatementEnd(int num_initializations, boolean has_condition, int num_increments, JavaToken jToken);
    public static native void cactionIfStatement(JavaToken jToken);
    public static native void cactionIfStatementEnd(boolean has_false_body, JavaToken jToken);

    // DQ (4/16/2011): I can't seem to get Boolean values to pass through the JNI C++ interface (so I will use an integer since that works fine).
    // public static native void cactionImportReference(String path);
    // public static native void cactionImportReference(String path , Boolean inputContainsWildcard );
    // public static native void cactionImportReference(String path , int java_ContainsWildcard );
    public static native void cactionImportReference(String path , boolean java_ContainsWildcard, JavaToken jToken);

    public static native void cactionInitializer(JavaToken jToken);
    public static native void cactionInstanceOfExpression(JavaToken jToken);
    public static native void cactionInstanceOfExpressionEnd(JavaToken jToken);
    public static native void cactionIntLiteral(int value, String source, JavaToken jToken);
    public static native void cactionJavadoc(JavaToken jToken);
    public static native void cactionJavadocClassScope(JavaToken jToken);
    public static native void cactionJavadocAllocationExpression(JavaToken jToken);
    public static native void cactionJavadocAllocationExpressionClassScope(JavaToken jToken);
    public static native void cactionJavadocArgumentExpression(JavaToken jToken);
    public static native void cactionJavadocArgumentExpressionClassScope(JavaToken jToken);
    public static native void cactionJavadocArrayQualifiedTypeReference(JavaToken jToken);
    public static native void cactionJavadocArrayQualifiedTypeReferenceClassScope(JavaToken jToken);
    public static native void cactionJavadocArraySingleTypeReference(JavaToken jToken);
    public static native void cactionJavadocArraySingleTypeReferenceClassScope(JavaToken jToken);
    public static native void cactionJavadocFieldReference(JavaToken jToken);
    public static native void cactionJavadocFieldReferenceClassScope(JavaToken jToken);
    public static native void cactionJavadocImplicitTypeReference(JavaToken jToken);
    public static native void cactionJavadocImplicitTypeReferenceClassScope(JavaToken jToken);
    public static native void cactionJavadocMessageSend(JavaToken jToken);
    public static native void cactionJavadocMessageSendClassScope(JavaToken jToken);
    public static native void cactionJavadocQualifiedTypeReference(JavaToken jToken);
    public static native void cactionJavadocQualifiedTypeReferenceClassScope(JavaToken jToken);

    public static native void cactionJavadocReturnStatement(JavaToken jToken);
    public static native void cactionJavadocReturnStatementClassScope(JavaToken jToken);
    public static native void cactionJavadocSingleNameReference(JavaToken jToken);
    public static native void cactionJavadocSingleNameReferenceClassScope(JavaToken jToken);
    public static native void cactionJavadocSingleTypeReference(JavaToken jToken);
    public static native void cactionJavadocSingleTypeReferenceClassScope(JavaToken jToken);
     
    public static native void cactionLabeledStatement(String labelName, JavaToken jToken);
    public static native void cactionLabeledStatementEnd(JavaToken jToken);

    public static native void cactionLocalDeclaration(String variableName, boolean java_is_final, JavaToken jToken);
    public static native void cactionLocalDeclarationEnd(String variableName, boolean is_initialized, boolean java_is_final, JavaToken jToken);
    //     public static native void cactionLocalDeclarationInitialization(JavaToken jToken);

    public static native void cactionLongLiteral(long value, String source, JavaToken jToken);
    public static native void cactionMarkerAnnotation(JavaToken jToken);
    public static native void cactionMemberValuePair(JavaToken jToken);
    public static native void cactionStringLiteralConcatenation(JavaToken jToken);
    public static native void cactionNormalAnnotation(JavaToken jToken);
    public static native void cactionNullLiteral(JavaToken jToken);
    public static native void cactionORORExpression(JavaToken jToken);
    public static native void cactionORORExpressionEnd(JavaToken jToken);
    public static native void cactionParameterizedQualifiedTypeReference(JavaToken jToken);
    public static native void cactionParameterizedQualifiedTypeReferenceClassScope(JavaToken jToken);
    public static native void cactionParameterizedSingleTypeReference(JavaToken jToken);
    public static native void cactionParameterizedSingleTypeReferenceEnd(String name, int java_numberOfTypeArguments, JavaToken jToken);
    public static native void cactionParameterizedSingleTypeReferenceClassScope(JavaToken jToken);
    public static native void cactionPostfixExpression(JavaToken jToken);
    public static native void cactionPostfixExpressionEnd(int java_operator_kind, JavaToken jToken);
    public static native void cactionPrefixExpression(JavaToken jToken);
    public static native void cactionPrefixExpressionEnd(int java_operator_kind, JavaToken jToken);
    public static native void cactionQualifiedAllocationExpression(JavaToken jToken);
    public static native void cactionQualifiedSuperReference(JavaToken jToken);
    public static native void cactionQualifiedSuperReferenceClassScope(JavaToken jToken);
    public static native void cactionQualifiedThisReference(JavaToken jToken);
    public static native void cactionQualifiedThisReferenceClassScope(JavaToken jToken);
    public static native void cactionQualifiedTypeReference(JavaToken jToken);
    public static native void cactionQualifiedTypeReferenceClassScope(JavaToken jToken);

    public static native void cactionReturnStatement(JavaToken jToken);
    public static native void cactionReturnStatementEnd(boolean hasExpression, JavaToken jToken);

    public static native void cactionSingleMemberAnnotation(JavaToken jToken);
    public static native void cactionSingleNameReference(String variableName, JavaToken jToken);
    public static native void cactionSingleNameReferenceClassScope(JavaToken jToken);
    public static native void cactionSuperReference(JavaToken jToken);

    public static native void cactionSwitchStatement(JavaToken jToken);
    public static native void cactionSwitchStatementEnd(int numCases, boolean hasDefault, JavaToken jToken);

    public static native void cactionSynchronizedStatement(JavaToken jToken);
    public static native void cactionSynchronizedStatementEnd(JavaToken jToken);

    public static native void cactionThisReference(JavaToken jToken);
    public static native void cactionThisReferenceClassScope(JavaToken jToken);

    public static native void cactionThrowStatement(JavaToken jToken);
    public static native void cactionThrowStatementEnd(JavaToken jToken);

    public static native void cactionTrueLiteral(JavaToken jToken);

    public static native void cactionTryStatement(int numCatchBlocks, boolean hasFinallyBlock, JavaToken jToken);
    public static native void cactionTryStatementEnd(int numCatchBlocks, boolean hasFinallyBlock, JavaToken jToken);

    public static native void cactionCatchBlockEnd(JavaToken jToken);

    public static native void cactionTypeParameter(JavaToken jToken);
    public static native void cactionTypeParameterClassScope(JavaToken jToken);
    public static native void cactionUnaryExpression(JavaToken jToken);
    public static native void cactionUnaryExpressionEnd(int java_operator_kind, JavaToken jToken);
    public static native void cactionWhileStatement(JavaToken jToken);
    public static native void cactionWhileStatementEnd(JavaToken jToken);
    public static native void cactionWildcard(JavaToken jToken);
    public static native void cactionWildcardClassScope(JavaToken jToken);

    // These are static because they are called from the JavaParserSupport class which 
    // does not have a reference of the JavaParser object..  Not clear if it should.
    // Also it might be that all of the JNI functions should be static.
    public static native void cactionBuildImplicitClassSupportStart(String className);
    public static native void cactionBuildImplicitClassSupportEnd(int java_numberOfStatements, String className);
    public static native void cactionBuildImplicitMethodSupport(String methodName, int num_arguments);
    public static native void cactionBuildImplicitFieldSupport(String fieldName);

    // Added new support functions for Argument IR nodes.
    public static native void cactionArgumentName(String name);
    public static native void cactionArgumentModifiers(int modifiers);

    // Type support
    public static native void cactionGenerateType(String typeName, int num_dimensions);
    //     public static native void cactionGenerateClassType(String className, int num_dimensions);

    // Build an array type using the base type that will be found on the astJavaTypeStack.
    //     public static native void cactionGenerateArrayType();

    // Support for primative types.
    public static native void generateBooleanType();
    public static native void generateByteType();
    public static native void generateCharType();
    public static native void generateIntType();
    public static native void generateShortType();
    public static native void generateFloatType();
    public static native void generateLongType();
    public static native void generateDoubleType();
    public static native void generateNullType();

    public static native void cactionGenerateToken(JavaToken t);
    public static native void cactionSetSourcePosition(JavaSourcePositionInformation sp);

    // Save the compilationResult as we process the CompilationUnitDeclaration class.
    // public CompilationResult rose_compilationResult;

    // DQ (10/12/2010): Added boolean value to report error to C++ calling program (similar to OFP).
    // public static boolean hasErrorOccurred = false;

    // DQ: This is the name of the C++ *.so file which has the implementations of the JNI functions.
    // The library with the C++ implementation of these function must be loaded in order to call the 
    // JNI functions.
    static { System.loadLibrary("JavaTraversal"); }

    // -------------------------------------------------------------------------------------------

    static public void startParsingAST(CompilationUnitDeclaration unit, int input_verbose_level) {
        // Set the verbose level for ROSE specific processing on the Java specific ECJ/ROSE translation.
        verboseLevel = input_verbose_level;

        // Debugging support...
        if (verboseLevel > 0)
            System.out.println("Start parsing");

        // Example of how to call the 
        // traverseAST(unit);

        try {
            // Make a copy of the compiation unit so that we can compute source code positions.
            // rose_compilationResult = unit.compilationResult;
            JavaParserSupport.initialize(unit.compilationResult,verboseLevel);

            // Example of how to call the traversal using a better design that isolates out the traversal of the ECJ AST from the parser.
            // "final" is required because the traverse function requires the visitor to be final.
            // final ecjASTVisitor visitor = new ecjASTVisitor(this);
            ecjASTVisitor visitor = new ecjASTVisitor(unit);

            unit.traverse(visitor,unit.scope);

            // Experiment with error on Java side...catch on C++ side...
            // System.out.println("Exiting in JavaParser::startParsingAST()");
            // System.exit(1);
        }
        catch (Throwable e) {
            System.out.println("Caught error in JavaParser (Parser failed)");
            System.err.println(e);

            // Make sure we exit as quickly as possible to simplify debugging.
            System.exit(1);

            // Make sure we exit on any error so it is caught quickly.
            // System.exit(1);

            // throw e;
            return;
        }

        // Debugging support...
        if (verboseLevel > 0)
            System.out.println("Done parsing");
    }

    // DQ (10/12/2010): Implemented abstract baseclass "call()" member function (similar to OFP).
    // This provides the support to detect errors and communicate them back to ROSE (C++ code).
    public Boolean call() throws Exception {
        // boolean error = false;
        // boolean error = true;

        if (verboseLevel > 0)
            System.out.println("Parser exiting normally");

        // return new Boolean(error);
        // return Boolean.valueOf(error);
        return Boolean.TRUE;
    } // end call()

    // REMOVE THIS!!!
    /*
    // DQ (10/30/2010): Added boolean value to report error to C++ calling program (similar to OFP).
    public static boolean getError() {
        return JavaTraversal.hasErrorOccurred;
    }
    */
    // End of JavaParser class
}
