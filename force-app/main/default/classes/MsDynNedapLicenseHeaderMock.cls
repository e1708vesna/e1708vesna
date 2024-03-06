/**
 * @description   : MsDynNedapLicenseHeader Mock Class
 * @author (s)    : BRITE
 **/
@isTest 
global class MsDynNedapLicenseHeaderMock implements WebServiceMock {

    public static final Integer READMULTIPLE = 1;
    public static final Integer ISUPDATED = 2;
    public static final Integer READBYRECID = 3;
    public static final Integer UPDATEX = 4;
    public static final Integer READ = 5;
    public static final Integer CREATEMULTIPLE = 6;
    public static final Integer DELETEX = 7;
    public static final Integer GETRECIDFROMKEY = 8;
    public static final Integer CREATE = 9;
    public static final Integer UPDATEMULTIPLE = 10;
    public static final Integer KEYTYPENOTSUPPORTED = 11;
    
    private Integer requestType = 0;

    public MsDynNedapLicenseHeaderMock(Integer requestType) {
        this.requestType = requestType;
    }
    
	public void doInvoke(
	           	Object stub,
	           	Object request,
	           	Map<String, Object> response,
	           	String endpoint,
	           	String soapAction,
	           	String requestName,
	           	String responseNS,
	           	String responseName,
	           	String responseType) {
	           	    
	    if (requestType == READMULTIPLE) {
	        responseReadMultiple(response);
        } else if (requestType == ISUPDATED) {
            responseIsUpdated(response);
        } else if (requestType == READBYRECID) {
            responseReadByRecId(response);
        } else if (requestType == UPDATEX) {
            responseUpdateX(request, response);
        } else if (requestType == READ) {
            responseRead(request, response);
        } else if (requestType == CREATEMULTIPLE) {
            responseCreateMultiple(request, response);
        } else if (requestType == DELETEX) {
            responseDelete(response);
        } else if (requestType == GETRECIDFROMKEY) {
            responseGetRecIdFromKey(response);
        } else if (requestType == CREATE) {
            responseCreate(request, response);
        } else if (requestType == UPDATEMULTIPLE) {
            responseUpdateMultiple(request, response);
        } else if (requestType == KEYTYPENOTSUPPORTED) {
            responseKeyTypeNotsupported(response);
	    }
	}   
	
	private void responseReadMultiple(Map<String, Object> response) {
        MsDynNedapLicenseHeader.ReadMultiple_Result_element respElement = new MsDynNedapLicenseHeader.ReadMultiple_Result_element();
        respElement.ReadMultiple_Result = new MsDynNedapLicenseHeader.NedapLicenseHeader_List();
        respElement.ReadMultiple_Result.NedapLicenseHeader = new List<MsDynNedapLicenseHeader.NedapLicenseHeader>();
                       
        respElement.ReadMultiple_Result.NedapLicenseHeader.add(createNedapLicenseHeader('1lic000001', '_blank_', 'AEOS'));               
        respElement.ReadMultiple_Result.NedapLicenseHeader.add(createNedapLicenseHeader('1lic000002', 'Gearchiveerd', 'AEOS'));               
        response.put('response_x', respElement); 
	} 

	private void responseKeyTypeNotsupported(Map<String, Object> response) {
        MsDynNedapLicenseHeader.ReadMultiple_Result_element respElement = new MsDynNedapLicenseHeader.ReadMultiple_Result_element();
        respElement.ReadMultiple_Result = new MsDynNedapLicenseHeader.NedapLicenseHeader_List();
        respElement.ReadMultiple_Result.NedapLicenseHeader = new List<MsDynNedapLicenseHeader.NedapLicenseHeader>();
                       
        respElement.ReadMultiple_Result.NedapLicenseHeader.add(createNedapLicenseHeader('1lic000002', 'Gearchiveerd', 'VELOS'));               
        response.put('response_x', respElement); 
	} 
    
    private void responseIsUpdated(Map<String, Object> response) {
        MsDynNedapLicenseHeader.IsUpdated_Result_element respElement = new MsDynNedapLicenseHeader.IsUpdated_Result_element();
        respElement.IsUpdated_Result = true;
        
        response.put('response_x', respElement);
    }
    
    private void responseReadByRecId(Map<String, Object> response) {
        MsDynNedapLicenseHeader.ReadByRecId_Result_element respElement = new MsDynNedapLicenseHeader.ReadByRecId_Result_element();
        respElement.NedapLicenseHeader = createNedapLicenseHeader('1lic000001');
        
        response.put('response_x', respElement);
    }
    
    private void responseUpdateX(Object request, Map<String, Object> response) {
        MsDynNedapLicenseHeader.Update_Result_element respElement = new MsDynNedapLicenseHeader.Update_Result_element();
        respElement.NedapLicenseHeader = ((MsDynNedapLicenseHeader.Update_element) request).NedapLicenseHeader;
        
        response.put('response_x', respElement);
    }
    
    private void responseRead(Object request, Map<String, Object> response) {
        MsDynNedapLicenseHeader.Read_element request_x = (MsDynNedapLicenseHeader.Read_element) request;
        
        MsDynNedapLicenseHeader.Read_Result_element respElement = new MsDynNedapLicenseHeader.Read_Result_element();
        respElement.NedapLicenseHeader = createNedapLicenseHeader(request_x.No);
        
        response.put('response_x', respElement);
    }
    
    private void responseCreateMultiple(Object request, Map<String, Object> response) {
        MsDynNedapLicenseHeader.CreateMultiple_element request_x = (MsDynNedapLicenseHeader.CreateMultiple_element) request;
        
        MsDynNedapLicenseHeader.CreateMultiple_Result_element respElement = new MsDynNedapLicenseHeader.CreateMultiple_Result_element();
        respElement.NedapLicenseHeader_List = request_x.NedapLicenseHeader_List;
        
        response.put('response_x', respElement);
    }
    
    private void responseDelete(Map<String, Object> response) {
        MsDynNedapLicenseHeader.Delete_Result_element respElement = new MsDynNedapLicenseHeader.Delete_Result_element();
        respElement.Delete_Result = true;
        
        response.put('response_x', respElement);
    }
    
    private void responseGetRecIdFromKey(Map<String, Object> response) {
        MsDynNedapLicenseHeader.GetRecIdFromKey_Result_element respElement = new MsDynNedapLicenseHeader.GetRecIdFromKey_Result_element();
        respElement.GetRecIdFromKey_Result = 'rec1001';
        
        response.put('response_x', respElement);
    }
    
    private void responseCreate(Object request, Map<String, Object> response) {
        MsDynNedapLicenseHeader.Create_element request_x = (MsDynNedapLicenseHeader.Create_element) request;
        
        MsDynNedapLicenseHeader.Create_Result_element respElement = new MsDynNedapLicenseHeader.Create_Result_element();
        respElement.NedapLicenseHeader = request_x.NedapLicenseHeader;
        
        response.put('response_x', respElement);
    }
    
    private void responseUpdateMultiple(Object request, Map<String, Object> response) {
        MsDynNedapLicenseHeader.UpdateMultiple_element request_x = (MsDynNedapLicenseHeader.UpdateMultiple_element) request;
        
        MsDynNedapLicenseHeader.UpdateMultiple_Result_element respElement = new MsDynNedapLicenseHeader.UpdateMultiple_Result_element();
        respElement.NedapLicenseHeader_List = request_x.NedapLicenseHeader_List;
        
        response.put('response_x', respElement);
    }
    
    private MsDynNedapLicenseHeader.NedapLicenseHeader createNedapLicenseHeader(String no) {
        return createNedapLicenseHeader(no, '_blank_', 'AEOS');
    }

    private MsDynNedapLicenseHeader.NedapLicenseHeader createNedapLicenseHeader(String no, String status, String keytype) {
        MsDynNedapLicenseHeader.NedapLicenseHeader nlh = new MsDynNedapLicenseHeader.NedapLicenseHeader();
        nlh.SQLTimeStamp = 10000001;
        nlh.Key = '00000001';
        nlh.No = no;
            
        nlh.Enduser_code = '90000001';  //End User
        nlh.Enduser_name = 'EndUser Mock';
            
        nlh.Extra_info = 'NotUsed';
        nlh.IP_Address_1 = '192.168.0.1';
        nlh.Extra_License_Key = 'extraLicenseKey';
        //Use External Id
        nlh.Customer_No = '00000001';
        nlh.Customer_Name = 'Channel Partner';  //Channel Partner
        nlh.Validity_start_date = Date.newInstance(2000, 11, 17);
        nlh.Validity_Period_days = 1100; //Integer to Number
        nlh.Validity_end_date = Date.newInstance(2000, 11, 17); //Date
        nlh.Renewal_Period = 300; //Integer to Picklist!
        nlh.Licensee_name = 'MyLicense';
        nlh.Version_Code = '123';
        nlh.Version_Code_Description = 'AEOS';
        nlh.Keytype = keytype;
        nlh.License_type_version = '1';
        nlh.License_Type_Code = 'DEMO 30D';
        nlh.License_Type = 'Demo';
        nlh.Systemkey_Provider = 'IpAddress';
        nlh.Status = status;
        
        return nlh;
    }
            
    private MsDynNedapLicenseHeader.NedapLicenseHeader createNedapLicenseHeaderKeyTypeNotsupported(String no, String status) {
        MsDynNedapLicenseHeader.NedapLicenseHeader nlh = new MsDynNedapLicenseHeader.NedapLicenseHeader();
        nlh.SQLTimeStamp = 10000001;
        nlh.Key = '00000001';
        nlh.No = no;
            
        nlh.Enduser_code = '90000001';  //End User
        nlh.Enduser_name = 'EndUser Mock';
            
        nlh.Extra_info = 'NotUsed';
        nlh.IP_Address_1 = '192.168.0.1';
        nlh.Extra_License_Key = 'extraLicenseKey';
        //Use External Id
        nlh.Customer_No = '00000001';
        nlh.Customer_Name = 'Channel Partner';  //Channel Partner
        nlh.Validity_start_date = Date.newInstance(2000, 11, 17);
        nlh.Validity_Period_days = 1100; //Integer to Number
        nlh.Validity_end_date = Date.newInstance(2000, 11, 17); //Date
        nlh.Renewal_Period = 300; //Integer to Picklist!
        nlh.Licensee_name = 'MyLicense';
        nlh.Version_Code = '123';
        nlh.Version_Code_Description = 'AEOS';
        nlh.Keytype = 'VELOS';
        nlh.License_type_version = '1';
        nlh.License_Type_Code = 'DEMO 30D';
        nlh.License_Type = 'Demo';
        nlh.Systemkey_Provider = 'IpAddress';
        nlh.Status = status;
        
        return nlh;
    }
}