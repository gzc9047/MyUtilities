import java.io.*;
import java.util.*;
import java.util.jar.*;

public class JavaClassNameGenerator {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("need jar file name.");
            System.exit(1);
        }
        ProcessJarFile(args[0]);
    }

    /**
     * Process all class in a jarFile.
     * @param parameter: has the file name of jar and the prefix of class name which should process.
     */
    private static void ProcessJarFile(String jarFile) throws IOException {
        try (JarFile file = new JarFile(jarFile)) {
            Enumeration<JarEntry> enumerator = file.entries();
            while (enumerator.hasMoreElements()) {
                System.out.println(enumerator.nextElement().getName());
            }
        } 
    }
}
