global class scheduledArticleExpNotification implements Schedulable{
   global void execute(SchedulableContext SC) {
      batchArticleExpNotify artExp = new batchArticleExpNotify(); 
       Database.executeBatch(artExp, 100);
   }
}