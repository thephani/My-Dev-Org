global class scheduledBatchable implements Schedulable{
   global void execute(SchedulableContext sc) {
      KnowledgeArticlesEnumeration b = new KnowledgeArticlesEnumeration(); 
      database.executebatch(b);
   }
}