// Do work parallel.
// read command(every line) from stdin.
import java.io.*;
import java.util.concurrent.*;

public class DoWorkParallel {
    public static void main(String[] args) {
        if (args.length < 1) {
            throw new IllegalArgumentException("Need parallel number.");
        }
        WorkManager workManager = new WorkManager(Integer.parseInt(args[0]));
        String command;
        try (BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in))) {
            while ((command = stdIn.readLine()) != null) {
                workManager.AddCommand(command);
            }
        } catch (IOException e) {
            e.printStackTrace(System.err);
        }
        workManager.waitStop();
    }
}

class WorkManager {
    ExecutorService executorService;
    WorkManager(int parallelNumber) {
        executorService = Executors.newFixedThreadPool(parallelNumber);
    }

    void AddCommand(final String command) {
        executorService.submit(new Runnable(){
                    public void run() {
                        try {
                            ProcessBuilder pb = new ProcessBuilder("bash", "-c", command);
                            pb.redirectErrorStream(true);
                            pb.redirectOutput(ProcessBuilder.Redirect.appendTo(new java.io.File("/dev/stdout")));
                            System.out.println("Return code: " + pb.start().waitFor() + " " + command);
                        } catch (Exception e) {
                            e.printStackTrace(System.err);
                        }
                    }
                });
    }

    void waitStop() {
        executorService.shutdown();
        try {
            executorService.awaitTermination(99999999L, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace(System.err);
        }
    }
}
