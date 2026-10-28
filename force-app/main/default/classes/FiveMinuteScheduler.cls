public class FiveMinuteScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        // --- Your actual logic goes here ---
        runBusinessLogic();
        
        // --- Schedule next run ---
        scheduleNextRun(5); // reschedule after 5 minutes
    }

    private void runBusinessLogic() {
        // TODO: Replace with your real code
        System.debug('Running job at: ' + Datetime.now());
    }

    private static void scheduleNextRun(Integer minutesFromNow) {
        Datetime nextRun = Datetime.now().addMinutes(minutesFromNow);
        String jobName = 'FiveMinuteScheduler_' + nextRun.getTime();

        // Build cron expression dynamically
        String cronExp = String.format(
            '{0} {1} {2} {3} {4} ?',
            new List<String>{
                String.valueOf(nextRun.second()),
                String.valueOf(nextRun.minute()),
                String.valueOf(nextRun.hour()),
                String.valueOf(nextRun.day()),
                String.valueOf(nextRun.month())
            }
        );

        System.schedule(jobName, cronExp, new FiveMinuteScheduler());
        System.debug('Next job scheduled for: ' + nextRun);
    }

    // One-time bootstrap method
    public static void startScheduler() {
        scheduleNextRun(2); // first run after 2 minutes
    }
}