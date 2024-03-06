/**
 * @description   : MsDynNedapLicenseHeader test class
 * @author (s)    : BRITE
 */
@isTest
private class MsDynNedapLicenseHeaderTest {
    
    @isTest
    public static void testIsUpdated() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.ISUPDATED));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        Boolean result = port.IsUpdated('someKey');
        Test.stopTest();
        
        system.assertEquals(true, result, 'isUpdated');
    }
    
    @isTest
    public static void testReadByRecId() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READBYRECID));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        MsDynNedapLicenseHeader.NedapLicenseHeader resultNlh = port.ReadByRecId('ID1');
        Test.stopTest();
        
        system.assertNotEquals(null, resultNlh, 'ReadByRecId');
    }

    @isTest
    public static void testUpdate_x() {
        MsDynNedapLicenseHeader.NedapLicenseHeader nlh = new MsDynNedapLicenseHeader.NedapLicenseHeader();
        nlh.SQLTimeStamp = 10000001;
        nlh.Key = '00000001';
        nlh.No = 'no123';
        nlh.Enduser_code = '90000001';  //End User
        nlh.Enduser_name = 'EndUser Mock';
        nlh.Extra_License_Key = 'extraLicenseKey';
        nlh.Customer_No = '00000001';
        nlh.Customer_Name = 'Channel Partner';  //Channel Partner
        nlh.License_Type = 'Demo';
        nlh.Status = 'Archived';
        
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.UPDATEX));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        MsDynNedapLicenseHeader.NedapLicenseHeader resultNlh = port.Update_x(nlh);
        Test.stopTest();
        
        system.assertNotEquals(null, resultNlh, 'Update_x');
    }

    @isTest
    public static void testRead() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.READ));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        MsDynNedapLicenseHeader.NedapLicenseHeader resultNlh = port.Read('no102');
        Test.stopTest();
        
        system.assertNotEquals(null, resultNlh, 'Read');
        system.assertEquals('no102', resultNlh.No, 'Line_No');
    }
    
    @isTest
    public static void testCreateMultiple() {
        MsDynNedapLicenseHeader.NedapLicenseHeader nlh = new MsDynNedapLicenseHeader.NedapLicenseHeader();
        nlh.SQLTimeStamp = 10000001;
        nlh.Key = '00000001';
        nlh.No = 'no123';
        nlh.Enduser_code = '90000001';  //End User
        nlh.Enduser_name = 'EndUser Mock';
        nlh.Extra_License_Key = 'extraLicenseKey';
        nlh.Customer_No = '00000001';
        nlh.Customer_Name = 'Channel Partner';  //Channel Partner
        nlh.License_Type = 'Demo';
        nlh.Status = 'Archived';
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_List nlhList = new MsDynNedapLicenseHeader.NedapLicenseHeader_List ();
        nlhList.NedapLicenseHeader = new List<MsDynNedapLicenseHeader.NedapLicenseHeader>();
        nlhList.NedapLicenseHeader.add(nlh);
        
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.CREATEMULTIPLE));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        MsDynNedapLicenseHeader.NedapLicenseHeader_List resultNlhList = port.CreateMultiple(nlhList);
        Test.stopTest();
        
        system.assertNotEquals(null, resultNlhList, 'CreateMultiple');
    }
    
    @isTest
    public static void testDeleteX() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.DELETEX));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        Boolean isDeleted = port.Delete_x('key1');
        Test.stopTest();
        
        system.assertEquals(true, isDeleted, 'Delete_x');
    }

    @isTest
    public static void testGetRecIdFromKey() {
        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.GETRECIDFROMKEY));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        String recId = port.GetRecIdFromKey('key1');
        Test.stopTest();
        
        system.assertEquals('rec1001', recId, 'GetRecIdFromKey');
    }
    
    @isTest
    public static void testCreate() {
        MsDynNedapLicenseHeader.NedapLicenseHeader nlh = new MsDynNedapLicenseHeader.NedapLicenseHeader();
        nlh.SQLTimeStamp = 10000001;
        nlh.Key = '00000001';
        nlh.No = 'no123';
        nlh.Enduser_code = '90000001';  //End User
        nlh.Enduser_name = 'EndUser Mock';
        nlh.Extra_License_Key = 'extraLicenseKey';
        nlh.Customer_No = '00000001';
        nlh.Customer_Name = 'Channel Partner';  //Channel Partner
        nlh.License_Type = 'Demo';
        nlh.Status = 'Archived';

        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.CREATE));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        MsDynNedapLicenseHeader.NedapLicenseHeader resultNlh = port.Create(nlh);
        Test.stopTest();
        
        system.assertNotEquals(null, resultNlh, 'Create');
    }
    
    @isTest
    public static void testUpdateMultiple() {
        MsDynNedapLicenseHeader.NedapLicenseHeader nlh = new MsDynNedapLicenseHeader.NedapLicenseHeader();
        nlh.SQLTimeStamp = 10000001;
        nlh.Key = '00000001';
        nlh.No = 'no123';
        nlh.Enduser_code = '90000001';  //End User
        nlh.Enduser_name = 'EndUser Mock';
        nlh.Extra_License_Key = 'extraLicenseKey';
        nlh.Customer_No = '00000001';
        nlh.Customer_Name = 'Channel Partner';  //Channel Partner
        nlh.License_Type = 'Demo';
        nlh.Status = 'Archived';
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_List nlhList = new MsDynNedapLicenseHeader.NedapLicenseHeader_List ();
        nlhList.NedapLicenseHeader = new List<MsDynNedapLicenseHeader.NedapLicenseHeader>();
        nlhList.NedapLicenseHeader.add(nlh);

        Test.setMock(WebServiceMock.class, new MsDynNedapLicenseHeaderMock (MsDynNedapLicenseHeaderMock.UPDATEMULTIPLE));
        
        MsDynNedapLicenseHeader.NedapLicenseHeader_Port port = new MsDynNedapLicenseHeader.NedapLicenseHeader_Port();
        Test.startTest();
        MsDynNedapLicenseHeader.NedapLicenseHeader_List resultNlhList = port.UpdateMultiple(nlhList);
        Test.stopTest();
        
        system.assertNotEquals(null, resultNlhList, 'UpdateMultiple');
    }
}