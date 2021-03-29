package org.example;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Stream;


/**
 * A pre-processor utility class that formats
 * and merges Fortran's multi-line statements,
 * recognized by ampersand into
 * single-line statements
 *
 * @author  Team: Language Parser
 * @version 1.0
 */
public class PreProcessor
{
    //Just a temporary local main method to test both methods
    // mergeLinesByString() and mergeLinesByFile()
    public static void main(String[] args) throws Exception
    {
        String user_file = "input.txt";
        mergeLinesByFile(user_file);

        String a = "data month /\n"
                + "     &  'January  ', 'February ', 'March    ', 'April    ',\n"
                + "     &  'May      ', 'June     ', 'July     ', 'August   ',\n"
                + "     &  'September', 'October  ', 'November ', 'December ' /";

        String b = "DATA TTL /'Arbitrary Titles'/, /	\n&            M /9/, N /0/, \n&            PAIR(1) /9.0/, \n&            VEC /3*9.0, 0.1, 0.9/ ";

        String c = "REAL R(3,2), S(4,4) \n"
                + "       DATA ( S(I,I), I=1,4)/4*1.0/, \n"
                + "&           ( R(I,J), J=1,3), I=1,2)/6*1.0/ ";

        String d = "end if\n"
                + "\n"
                + "      write ( *,\n"
                + "     &  '(i2,1x,a,1x,i4,2x,i2,a1,i2.2,a1,i2.2,a1,i3.3,1x,a)' )\n"
                + "     &  d, month(m), y, h, ':', n, ':', s, '.', mm, ampm\n"
                + "\n"
                + "      return\n"
                + "      end";

        System.out.println(d);

        System.out.println();
        System.out.println(mergeLinesByString(d));
    }

    /**
     * mergeLinesByString()
     * @param String input takes in as input Fortran code that needs to be processed
     * @return String output returns the formatted/processed code as a String object
     */
    public static String mergeLinesByString(String input)
    {
        StringBuilder stringBuilder = new StringBuilder("");
        Stream<String> linesFromString = input.lines();
        linesFromString.forEach(l -> {

            if(l.trim().startsWith("&"))
            {
                l = l.trim().substring(1);
                stringBuilder.append(l).append(" ");
            }
            else if(l.trim().endsWith("&"))
            {
                l = l.trim().substring(0, l.length() - 2);
                stringBuilder.append(l).append(" ");
            }
            else
            {
                stringBuilder.append(System.getProperty("line.separator")).append(l);
            }

        });

        String output = stringBuilder.toString();

        return output;

    }

    /**
     * mergeLinesByFile() processes a file (containing Fortran code) and merges lines
     * whenever an ampersand appears (to indicate continuation of lines) and
     * modifies the file specified in the param
     *
     * @param String path takes in as input the file path that contains the code
     * @return None
     * @SuppressWarnings("resource")
     */

    public static void mergeLinesByFile(String path) throws IOException
    {
        StringBuilder stringBuilder = new StringBuilder("");
        Stream<String> lines = Files.lines(Path.of(path));
        lines.forEach(l -> {

            if(l.trim().startsWith("&"))
            {
                l = l.trim().substring(1);
                stringBuilder.append(l).append(" ");
            }
            else if(l.trim().endsWith("&"))
            {
                l = l.trim().substring(0, l.length() - 2);
                stringBuilder.append(l).append(" ");
            }
            else
            {
                stringBuilder.append(System.getProperty("line.separator")).append(l);
            }

        });

        FileWriter writer = new FileWriter(new File(path));

        writer.write(stringBuilder.toString());
        writer.close();
        lines.close();


    }
}