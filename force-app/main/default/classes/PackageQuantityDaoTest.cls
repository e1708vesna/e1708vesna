/**
 * @description   : Package Quantity Dao test class
 * @author (s)    : Brite
 */
@isTest
private class PackageQuantityDaoTest {

	@isTest
	private static void packageQuantityDaoNameTest() {
		List<PackageQuantity__c> packageQuantityList = new List<PackageQuantity__c>();

        packageQuantityList.add( new PackageQuantity__c(
                                Name = '8009600', 
                                SetQuantity__c = 50));
        insert packageQuantityList;
		Set<String> artNoSet = new Set<String>();
        artNoSet.add('8009600');

        //Case 1
        packageQuantityList = PackageQuantityDao.getByName(artNoSet);
        System.assertEquals(50, packageQuantityList[0].SetQuantity__c, 'Case 1: PackageQuantity__c should be filled');

        packageQuantityList = PackageQuantityDao.getAll();
        System.assertEquals(50, packageQuantityList[0].SetQuantity__c, 'Case 1: PackageQuantity__c should be filled');

    }
}