@isTest(SeeAllData=true)
public class RHX_TEST_UpgradeAssuranceContract {
  static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
      FROM UpgradeAssuranceContract__c WHERE lock__c = false LIMIT 1];
        //if(sourceList.size() == 0) {
        //    sourceList.add(
        //            new UpgradeAssuranceContract__c()
        //    );
        //}
      rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}