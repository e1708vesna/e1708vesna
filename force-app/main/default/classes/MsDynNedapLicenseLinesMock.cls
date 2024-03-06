/**
 * @description   : MsDynNedapLicenseLines Mock Class
 * @author (s)    : BRITE
 **/
@isTest 
global class MsDynNedapLicenseLinesMock implements WebServiceMock {
    
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
    public static final Integer NULLQUANTITY = 11;
    public static final Integer VERSIONNOTSUPPORTED = 12;
    
    private Integer requestType = 0;
    
    public MsDynNedapLicenseLinesMock(Integer requestType) {
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
        } else if (requestType == NULLQUANTITY) {
            responseNullQuantity(response);
        } else if (requestType == VERSIONNOTSUPPORTED) {
            responseVersionNotSupported(response);
        }
    }
    
    private void responseReadMultiple(Map<String, Object> response) {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 101;
        nll.Item_No = 'item001';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = '1';
        
        MsDynNedapLicenseLines.ReadMultiple_Result_element respElement = new MsDynNedapLicenseLines.ReadMultiple_Result_element();
        respElement.ReadMultiple_Result = new MsDynNedapLicenseLines.NedapLicenseLines_List ();
        respElement.ReadMultiple_Result.NedapLicenseLines = new List<MsDynNedapLicenseLines.NedapLicenseLines> {nll};
        
        response.put('response_x', respElement);
    }
    
    private void responseIsUpdated(Map<String, Object> response) {
        MsDynNedapLicenseLines.IsUpdated_Result_element respElement = new MsDynNedapLicenseLines.IsUpdated_Result_element();
        respElement.Isupdated_Result = true;
        
        response.put('response_x', respElement);
    }
    
    private void responseReadByRecId(Map<String, Object> response) {
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

        MsDynNedapLicenseLines.ReadByRecId_Result_element respElement = new MsDynNedapLicenseLines.ReadByRecId_Result_element();
        respElement.NedapLicenseLines = nll;
        
        response.put('response_x', respElement);
    }
    
    private void responseUpdateX(Object request, Map<String, Object> response) {
        MsDynNedapLicenseLines.Update_Result_element respElement = new MsDynNedapLicenseLines.Update_Result_element();
        respElement.NedapLicenseLines = ((MsDynNedapLicenseLines.Update_element) request).NedapLicenseLines;
        
        response.put('response_x', respElement);
    }
    
    private void responseRead(Object request, Map<String, Object> response) {
        MsDynNedapLicenseLines.Read_element request_x = (MsDynNedapLicenseLines.Read_element) request;
        
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = request_x.License_No;
        nll.Line_No = request_x.Line_No;
        nll.Item_No = 'item001';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = 'licTypeV1.0';
        
        MsDynNedapLicenseLines.Read_Result_element respElement = new MsDynNedapLicenseLines.Read_Result_element();
        respElement.NedapLicenseLines = nll;
        
        response.put('response_x', respElement);
    }
    
    private void responseCreateMultiple(Object request, Map<String, Object> response) {
        MsDynNedapLicenseLines.CreateMultiple_element request_x = (MsDynNedapLicenseLines.CreateMultiple_element) request;
        
        MsDynNedapLicenseLines.CreateMultiple_Result_element respElement = new MsDynNedapLicenseLines.CreateMultiple_Result_element();
        respElement.NedapLicenseLines_List = request_x.NedapLicenseLines_List;
        
        response.put('response_x', respElement);
    }
    
    private void responseDelete(Map<String, Object> response) {
        MsDynNedapLicenseLines.Delete_Result_element respElement = new MsDynNedapLicenseLines.Delete_Result_element();
        respElement.Delete_Result = true;
        
        response.put('response_x', respElement);
    }
    
    private void responseGetRecIdFromKey(Map<String, Object> response) {
        MsDynNedapLicenseLines.GetRecIdFromKey_Result_element respElement = new MsDynNedapLicenseLines.GetRecIdFromKey_Result_element();
        respElement.GetRecIdFromKey_Result = 'lic1001';
        
        response.put('response_x', respElement);
    }
    
    private void responseCreate(Object request, Map<String, Object> response) {
        MsDynNedapLicenseLines.Create_element request_x = (MsDynNedapLicenseLines.Create_element) request;
        
        MsDynNedapLicenseLines.Create_Result_element respElement = new MsDynNedapLicenseLines.Create_Result_element();
        respElement.NedapLicenseLines = request_x.NedapLicenseLines;
        
        response.put('response_x', respElement);
    }
    
    private void responseUpdateMultiple(Object request, Map<String, Object> response) {
        MsDynNedapLicenseLines.UpdateMultiple_element request_x = (MsDynNedapLicenseLines.UpdateMultiple_element) request;
        
        MsDynNedapLicenseLines.UpdateMultiple_Result_element respElement = new MsDynNedapLicenseLines.UpdateMultiple_Result_element();
        respElement.NedapLicenseLines_List = request_x.NedapLicenseLines_List;
        
        response.put('response_x', respElement);
    }

    private void responseNullQuantity(Map<String, Object> response) {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 9999;
        nll.Item_No = 'art1077';
        nll.Quantity = 0;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = '1';
        
        MsDynNedapLicenseLines.ReadMultiple_Result_element respElement = new MsDynNedapLicenseLines.ReadMultiple_Result_element();
        respElement.ReadMultiple_Result = new MsDynNedapLicenseLines.NedapLicenseLines_List ();
        respElement.ReadMultiple_Result.NedapLicenseLines = new List<MsDynNedapLicenseLines.NedapLicenseLines> {nll};
        
        response.put('response_x', respElement);
    }

    private void responseVersionNotSupported(Map<String, Object> response) {
        MsDynNedapLicenseLines.NedapLicenseLines nll = new MsDynNedapLicenseLines.NedapLicenseLines();
        nll.Key = '00000001';
        nll.SQLTimeStamp = 10000001;
        nll.License_No = 'lic000001';
        nll.Line_No = 9999;
        nll.Item_No = 'art1077';
        nll.Quantity = 2;
        nll.Item_Description = 'some description';
        nll.Version_Code = 'v1';
        nll.License_type_version = '1';
        nll.Version_Supported = false;
        
        MsDynNedapLicenseLines.ReadMultiple_Result_element respElement = new MsDynNedapLicenseLines.ReadMultiple_Result_element();
        respElement.ReadMultiple_Result = new MsDynNedapLicenseLines.NedapLicenseLines_List ();
        respElement.ReadMultiple_Result.NedapLicenseLines = new List<MsDynNedapLicenseLines.NedapLicenseLines> {nll};
        
        response.put('response_x', respElement);
    }
}