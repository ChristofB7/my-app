package org.example;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RuleContext;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void testByFile(String path){
        CharStream codePointCharStream = null;
        try {
            //get the character stream from the example fortran file
            //IMPORTANT the fortran file must be renamed to filename.FinalGrammar!
            PreProcessor.mergeLinesByFile(path);
            codePointCharStream = CharStreams.fromPath(Paths.get(path));
        } catch (IOException e) {
            e.printStackTrace();
        }
        //Create a Final Grammar Lexer - this only occurs after mvn compile
        //when you run mvn compile it generates the lexer and parser for us

        FinalGrammarLexer lex = new FinalGrammarLexer(codePointCharStream);
        //the lexer creates tokens which are given to the parser
        FinalGrammarParser parser = new FinalGrammarParser(new CommonTokenStream(lex));

        //we add a base listener - this is a default listener - we can create a listener custom if we wanted to
        parser.addParseListener(new FinalGrammarBaseListener());
        //this means that when parser.gram(); is run the tree will be built
        parser.setBuildParseTree(true);

        //parser.gram(); !!! gram is the name of the topmost grammar rule !!!
        RuleContext tree = parser.gram();


        //Output to console using https://github.com/grosenberg/SnippetsTest
        //System.out.println(tree.toStringTree(parser));
        List<String> ruleNamesList = Arrays.asList(parser.getRuleNames());
        String prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
        System.out.println(prettyTree);
    }

    public static void testByString(String input){
        CharStream codePointCharStream = CharStreams.fromString(PreProcessor.mergeLinesByString(input));

        //get the character stream from the example fortran file
        //IMPORTANT the fortran file must be renamed to filename.FinalGrammar!


        //Create a Final Grammar Lexer - this only occurs after mvn compile
        //when you run mvn compile it generates the lexer and parser for us
        FinalGrammarLexer lexer = new FinalGrammarLexer(codePointCharStream);


        //the lexer creates tokens which are given to the parser
        FinalGrammarParser parser = new FinalGrammarParser(new CommonTokenStream(lexer));

        //we add a base listener - this is a default listener - we can create a listener custom if we wanted to
        parser.addParseListener(new FinalGrammarBaseListener());
        //this means that when parser.gram(); is run the tree will be built
        parser.setBuildParseTree(true);


        //parser.gram(); !!! gram is the name of the topmost grammar rule !!!
        RuleContext tree = parser.gram();


        //Output to console using https://github.com/grosenberg/SnippetsTest
        //System.out.println(tree.toStringTree(parser));
        List<String> ruleNamesList = Arrays.asList(parser.getRuleNames());
        String prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
        System.out.println(prettyTree);


    }

    public static void main(String[] args) {

        System.out.println("HelloWorld!");


        /*
        String path = "src/main/resources/example.FinalGrammar";
        testByFile(path);*/

        /*String input = "data month /\n"
                + "     &  'January  ', 'February ', 'March    ', 'April    ',\n"
                + "     &  'May      ', 'June     ', 'July     ', 'August   ',\n"
                + "     &  'September', 'October  ', 'November ', 'December ' /";
        testByString(input);*/

    }
}
