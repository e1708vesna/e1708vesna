/**
 * @description   : Account DAO test class
 * @author (s)    : Brite
 */
@isTest
private class ExportFactorDaoTest {

	@isTest
	private static void ExportFactorDaoByNameTest() {
		List<ExportFactor__c> ExportFactorList = new List<ExportFactor__c>();

        ExportFactorList.add( new ExportFactor__c(
                                Name = '8009600', 
                                Description__c = 'AEWARE LICENSE FOR 50 BADGES', 
                                ExportCode__c = 'LICENSEQTY',
                                ExportFactor__c = 50));
        insert ExportFactorList;
		Set<String> artNoSet = new Set<String>();
        artNoSet.add('8009600');

        //Case 1
        ExportFactorList = ExportFactorDao.getByName(artNoSet);
        System.assertEquals(50, ExportFactorList[0].ExportFactor__c, 'Case 1: ExportFactor__c should be filled');

        ExportFactorList = ExportFactorDao.getAll();
        System.assertEquals(50, ExportFactorList[0].ExportFactor__c, 'Case 1: ExportFactor__c should be filled');

    }
}