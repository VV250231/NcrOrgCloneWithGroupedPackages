global class salesforceLogsGeneratorforAWSS3Schedule implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext SC) {
      salesforceLogsGeneratorforAWSS3.uploadToAmazonS3();
   }
}