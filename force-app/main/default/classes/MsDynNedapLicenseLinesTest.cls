/**
 * @description   : Dummy test class for generated class MsDynNedapLicenseLines
 * @author (s)    : BRITE
 **/
@isTest 
private class MsDynNedapLicenseLinesTest {
    
    @isTest
    public static void testIsUpdated() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.ISUPDATED));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        Boolean result = port.IsUpdated('someKey');
        Test.stopTest();
        
        system.assertEquals(true, result, 'isUpdated');
    }
    
    @isTest
    public static void testReadByRecId() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.READBYRECID));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        MsDynNedapLicenseLines.NedapLicenseLines resultLicLines = port.ReadByRecId('ID1');
        Test.stopTest();
        
        system.assertNotEquals(null, resultLicLines, 'ReadByRecId');
    }

    @isTest
    public static void testUpdate_x() {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 101;
        nll.Item_No = 'item001';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = 'licTypeV1.0';
        
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.UPDATEX));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        MsDynNedapLicenseLines.NedapLicenseLines resultLicLines = port.Update_x(nll);
        Test.stopTest();
        
        system.assertNotEquals(null, resultLicLines, 'Update_x');
    }

    @isTest
    public static void testRead() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.READ));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        MsDynNedapLicenseLines.NedapLicenseLines resultLicLines = port.Read('lic663311', 202);
        Test.stopTest();
        
        system.assertNotEquals(null, resultLicLines, 'Read');
        system.assertEquals('lic663311', resultLicLines.License_No, 'License_No');
        system.assertEquals(202, resultLicLines.Line_No, 'Line_No');
    }
    
    @isTest
    public static void testCreateMultiple() {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 101;
        nll.Item_No = 'item001';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = 'licTypeV1.0';
        
        MsDynNedapLicenseLines.NedapLicenseLines_List nllList = new MsDynNedapLicenseLines.NedapLicenseLines_List ();
        nllList.NedapLicenseLines = new List<MsDynNedapLicenseLines.NedapLicenseLines>();
        nllList.NedapLicenseLines.add(nll);
        
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.CREATEMULTIPLE));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        MsDynNedapLicenseLines.NedapLicenseLines_List resultLicLinesList = port.CreateMultiple(nllList);
        Test.stopTest();
        
        system.assertNotEquals(null, resultLicLinesList, 'CreateMultiple');
    }
    
    @isTest
    public static void testDeleteX() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.DELETEX));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        Boolean isDeleted = port.Delete_x('key1');
        Test.stopTest();
        
        system.assertEquals(true, isDeleted, 'Delete_x');
    }

    @isTest
    public static void testGetRecIdFromKey() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.GETRECIDFROMKEY));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        String recId = port.GetRecIdFromKey('key1');
        Test.stopTest();
        
        system.assertEquals('lic1001', recId, 'GetRecIdFromKey');
    }
    
    @isTest
    public static void testCreate() {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 101;
        nll.Item_No = 'item001';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = 'licTypeV1.0';

        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.CREATE));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        MsDynNedapLicenseLines.NedapLicenseLines resultNll = port.Create(nll);
        Test.stopTest();
        
        system.assertNotEquals(null, resultNll, 'Create');
    }
    
    @isTest
    public static void testUpdateMultiple() {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 101;
        nll.Item_No = 'item001';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = 'licTypeV1.0';
        
        MsDynNedapLicenseLines.NedapLicenseLines_List nllList = new MsDynNedapLicenseLines.NedapLicenseLines_List ();
        nllList.NedapLicenseLines = new List<MsDynNedapLicenseLines.NedapLicenseLines>();
        nllList.NedapLicenseLines.add(nll);

        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseLinesMock (MsDynNedapLicenseLinesMock.UPDATEMULTIPLE));
        
        MsDynNedapLicenseLines.NedapLicenseLines_Port port = new MsDynNedapLicenseLines.NedapLicenseLines_Port();
        Test.startTest();
        MsDynNedapLicenseLines.NedapLicenseLines_List resultLicLinesList = port.UpdateMultiple(nllList);
        Test.stopTest();
        
        system.assertNotEquals(null, resultLicLinesList, 'UpdateMultiple');
    }

}