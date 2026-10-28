public class FiveMinuteJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Your logic here
        System.debug('Running job at: ' + Datetime.now());

        // Schedule next run 5 minutes from now
        Datetime nextRun = Datetime.now().addMinutes(5);
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

        System.schedule('FiveMinuteJob_' + nextRun.getTime(), cronExp, new FiveMinuteJob());
    }
}