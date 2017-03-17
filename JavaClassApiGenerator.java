import java.io.*;
import java.lang.reflect.*;

public class JavaClassApiGenerator {
    public static void main(String[] args) throws Exception {
        String className;
        BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));
        while ((className = stdIn.readLine()) != null) {
            ProcessOneClass(className);
        }
    }

    /**
     * Process one class.
     * @param className: class name.
     */
    private static void ProcessOneClass(String className) {
        try {
            Class klass = Class.forName(className);
            if (klass == null) {
                return;
            }
            for (Method method : klass.getDeclaredMethods()) {
                System.out.println(klass.getName()
                    + " " + method);
            }
        } catch (ClassNotFoundException e) {
            System.out.println("meet ClassNotFoundException: " + e);
        } catch (Exception e) {
            System.out.println("meet Exception: " + e);
        } catch (Error e) {
            System.out.println("meet Error: " + e);
        }
    }
}
