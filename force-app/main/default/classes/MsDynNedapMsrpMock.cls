/**
 * @description   : MsDynNedapMsrp Mock Class
 * @author (s)    : BRITE
 **/
@isTest 
global class MsDynNedapMsrpMock implements WebServiceMock {

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
    
    private Integer requestType = 0;

    public MsDynNedapMsrpMock(Integer requestType) {
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
            //responseIsUpdated(response);
        } else if (requestType == READBYRECID) {
            //responseReadByRecId(response);
        } else if (requestType == UPDATEX) {
            //responseUpdateX(request, response);
        } else if (requestType == READ) {
            //responseRead(request, response);
        } else if (requestType == CREATEMULTIPLE) {
            //responseCreateMultiple(request, response);
        } else if (requestType == DELETEX) {
            //responseDelete(response);
        } else if (requestType == GETRECIDFROMKEY) {
            //responseGetRecIdFromKey(response);
        } else if (requestType == CREATE) {
            //responseCreate(request, response);
        } else if (requestType == UPDATEMULTIPLE) {
            //responseUpdateMultiple(request, response);
	    }
	}   

	private void responseReadMultiple(Map<String, Object> response) {
        MsDynNedapMsrp.ReadMultiple_Result_element respElement = new MsDynNedapMsrp.ReadMultiple_Result_element();
        respElement.ReadMultiple_Result = new MsDynNedapMsrp.NedapMSRP_List();
        respElement.ReadMultiple_Result.NedapMSRP = new List<MsDynNedapMsrp.NedapMSRP>();
                       
        respElement.ReadMultiple_Result.NedapMSRP.add(createNedapMSRP('lic000001'));               
        response.put('response_x', respElement); 
	} 
	/*  
    private void responseIsUpdated(Map<String, Object> response) {
        MsDynNedapMsrp.IsUpdated_Result_element respElement = new MsDynNedapMsrp.IsUpdated_Result_element();
        respElement.IsUpdated_Result = true;
        
        response.put('response_x', respElement);
    }
    
    private void responseReadByRecId(Map<String, Object> response) {
        MsDynNedapMsrp.ReadByRecId_Result_element respElement = new MsDynNedapMsrp.ReadByRecId_Result_element();
        respElement.NedapMSRP = createNedapMSRP('lic000001');
        
        response.put('response_x', respElement);
    }
    
    private void responseUpdateX(Object request, Map<String, Object> response) {
        MsDynNedapMsrp.Update_Result_element respElement = new MsDynNedapMsrp.Update_Result_element();
        respElement.NedapMSRP = ((MsDynNedapMsrp.Update_element) request).NedapMSRP;
        
        response.put('response_x', respElement);
    }
    
    private void responseRead(Object request, Map<String, Object> response) {
        MsDynNedapMsrp.Read_element request_x = (MsDynNedapMsrp.Read_element) request;
        
        MsDynNedapMsrp.Read_Result_element respElement = new MsDynNedapMsrp.Read_Result_element();
        respElement.NedapMSRP = createNedapMSRP(request_x.Item_No);
        
        response.put('response_x', respElement);
    }
    
    private void responseCreateMultiple(Object request, Map<String, Object> response) {
        MsDynNedapMsrp.CreateMultiple_element request_x = (MsDynNedapMsrp.CreateMultiple_element) request;
        
        MsDynNedapMsrp.CreateMultiple_Result_element respElement = new MsDynNedapMsrp.CreateMultiple_Result_element();
        respElement.NedapMSRP_List = request_x.NedapMSRP_List;
        
        response.put('response_x', respElement);
    }
    
    private void responseDelete(Map<String, Object> response) {
        MsDynNedapMsrp.Delete_Result_element respElement = new MsDynNedapMsrp.Delete_Result_element();
        respElement.Delete_Result = true;
        
        response.put('response_x', respElement);
    }
    
    private void responseGetRecIdFromKey(Map<String, Object> response) {
        MsDynNedapMsrp.GetRecIdFromKey_Result_element respElement = new MsDynNedapMsrp.GetRecIdFromKey_Result_element();
        respElement.GetRecIdFromKey_Result = 'rec1001';
        
        response.put('response_x', respElement);
    }
    
    private void responseCreate(Object request, Map<String, Object> response) {
        MsDynNedapMsrp.Create_element request_x = (MsDynNedapMsrp.Create_element) request;
        
        MsDynNedapMsrp.Create_Result_element respElement = new MsDynNedapMsrp.Create_Result_element();
        respElement.NedapMSRP = request_x.NedapMSRP;
        
        response.put('response_x', respElement);
    }
    
    private void responseUpdateMultiple(Object request, Map<String, Object> response) {
        MsDynNedapMsrp.UpdateMultiple_element request_x = (MsDynNedapMsrp.UpdateMultiple_element) request;
        
        MsDynNedapMsrp.UpdateMultiple_Result_element respElement = new MsDynNedapMsrp.UpdateMultiple_Result_element();
        respElement.NedapMSRP_List = request_x.NedapMSRP_List;
        
        response.put('response_x', respElement);
    }
    */
    private MsDynNedapMsrp.NedapMSRP createNedapMSRP(String Item_No) {
    	
        MsDynNedapMsrp.NedapMSRP nedapMsrp = new MsDynNedapMsrp.NedapMSRP();
        
        nedapMsrp.Key = '00000001';
        nedapMsrp.SQLTimeStamp = 10000001;
        nedapMsrp.Item_No = Item_No;
                        
        nedapMsrp.Starting_Date = Date.newInstance(2000, 11, 17);
	    nedapMsrp.Ending_Date = null;
        nedapMsrp.Minimum_Quantity = 10;
        nedapMsrp.Description = 'Mock Msrp Article';
        nedapMsrp.Description_2 = 'Description 2';
        nedapMsrp.Unit_Price = 10.95;
	    nedapMsrp.Currency_Code = 'EUR';				
    
        return nedapMsrp;
    }
}