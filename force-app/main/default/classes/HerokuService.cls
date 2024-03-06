/**
 * @description   : Heroku service to make use of the Nedap License Generator
 * @author (s)    : BRITE
 **/
public without sharing class HerokuService {
	private final String API_TOKEN_STORE_NAME = 'HerokuLicenseApp';
	private String jarFileName = null;
	private ApiTokenStore__c ats;
	
	public HerokuService() {
		ats = ApiTokenStore__c.getValues(API_TOKEN_STORE_NAME);
	}
   	/**
     * Test GET call1 to Heroku: System.debug( new HerokuService().getTestData1() );
     **/
    public String getTestData1() { 
    	String resultString = '';
    	try {
	    	String accessToken = getTokenRetry();
	    	if (accessToken != null) {   
		        String url = ats.Url__c + '/api/test1?access_token='+accessToken;
		        Http h = new Http();
		        Httprequest req = new Httprequest();
		        req.setEndpoint(url);
		        req.setMethod('GET');
		        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		        req.setTimeout(60000);
		        
		        httpresponse res = new httpresponse();
		        
		        if (Test.isRunningTest()) {   
			        //Rest call is not performed during test, so send back mock data
		        	res.setBody('["Yes It Works!"]');        	
		        } else {
		        	res = h.send(req);
		        }
		       	resultString = res.getBody();
	    	}
    	} finally {
    		CustomLog.commitLog();
    	}
	    system.debug('Result: ' + resultString);
        return resultString;
    }


   /**
    * Test POST call1 to Heroku: System.debug( new HerokuService().getTestData('') );
    **/
    public String getTestData2() { 
    	String resultString = '';
		try {    	
	    	String accessToken = getTokenRetry();
	    	if (accessToken != null) {   
	
		    	String bodyData = '{ "txtFileName": "test.txt", "jarFileName": "test.jar", "data": "test data"}';
		    	   
		        String url = ats.Url__c + '/api/test2?access_token='+accessToken;
		        //we'll call the REST API here
		        Http h = new Http();
		        Httprequest req = new Httprequest();
		        req.setEndpoint(url);
		        req.setMethod('POST');
				req.setBody(bodyData);
		        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		        req.setTimeout(60000);
		        
		        httpresponse res = new httpresponse();
		        
		        if (Test.isRunningTest()) {   
			        //Rest call is not performed during test, so send back mock data
		        	res.setBody('["Yes It Works!"]');        	
		        } else {
		        	res = h.send(req);
		        }
		       	resultString = res.getBody();
	    	}
    	} finally {
    		CustomLog.commitLog();
    	}
        system.debug('Result: ' + resultString);
        return resultString;
    }

    /**
     * Send license data to Heroku and retrieve the License.jar
	 * new HerokuService().getLicenseJar('a011x000000XYLU');
     * @param licenseId id of the License header to generate a licensejar of
     **/
    public void getLicenseJar(Id licenseId) {
    	String fileName = 'license.txt';
		try {    	
	    	String licenseData = createLicenseTxtDataNew(licenseId);
            CustomLog.create(CustomLog.INFO, 'License Text data', licenseData, '');
	    	//system.debug(licenseData);
	    	String result = getLicenseJar(licenseData, licenseId);
    	} finally {
    		CustomLog.commitLog();
    	}
    }

   /**
    * Test call: System.debug( new HerokuService().getTestData('') );
    * @param
    **/
    private String getLicenseJar(String data, Id licenseId) {
    	String accessToken = getTokenRetry();
    	if (accessToken != null) {   
			DateTime myDateTime = DateTime.now();
			String myDate = myDateTime.formatGMT('yyyyMMddHHmmssSSS');
    	 
	    	JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
			gen.writeStringField('txtFileName', 'lic'+ licenseId + myDate + '.txt');
			gen.writeStringField('jarFileName', 'lic'+ licenseId + myDate + '.jar');
			gen.writeStringField('data', data);
			gen.writeEndObject();
	    	
	    	
	        String sUrl = ats.Url__c + '/api/license';
		  	HttpRequest req = new HttpRequest();
		  	req.setMethod('POST');
		  	req.setEndpoint(sUrl);
			req.setBody(gen.getAsString());
	        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		  	req.setHeader('Authorization', 'Bearer '+accessToken);
		  	req.setTimeout(120000);
	
		  	Http http = new Http();
	        httpresponse res = new httpresponse();
		        
	        if (Test.isRunningTest()) {
			  	res.setBodyAsBlob(EncodingUtil.base64Decode('UEsDBBQACAgIACJkfE0AAAAAAAAAAAAAAAAIAAAAdGVzdC50eHSNkl1rgzAUhu/9FQd2Yy+U+NFiC70QdTDoaqmlvRxZczZkmkiSdvjvl7oxXFFZrvOc9+R583BCBltxBT8Cz18FwYqEkGTFAXziRZblfh9wILkoLWqUwGmNLyMH1rDN0ngHafacO0meZr0Jj0LWVMMVpSoFH5/g9ZhNeUauEGrBsBpDRxh+qV9RTuT4QTgf4H5SwH5HjpJqZLPRrJ0U7HLWk1JuTJzlxQA26cJggRv2qD1WSM2CzOzk6HI4sXuY43lOV2Af5vhJK2hQloJByc2YVg1Ekh5UtEpj/YEtNFJcSzao00BPTcyYRKWGWFvNwD6LuqagsKF/jN62Xfqut4hc4np9s0dalazU7d3CYJP1m5BozM06fD7BKE2l7nTdCVr8CooIWYYBMXB8WhLiQ5yY719Akm8P+3xjijvF+6wP+1aKDXKGXP/UGHN2nCgS1tb/LvZTbh+mq/8LUEsHCGyscKBaAQAAogMAAFBLAQIUABQACAgIACJkfE1srHCgWgEAAKIDAAAIAAAAAAAAAAAAAAAAAAAAAAB0ZXN0LnR4dFBLBQYAAAAAAQABADYAAACQAQAAAAA='));
			  	res.setStatusCode(200);
	        } else {
	        	res = http.send(req);
	        }
	        	  	
		  	system.debug('Status: '+ res.getStatusCode());
		  	//system.debug('response: '+ res);
	        //system.debug('Body: '+ res.getBody());
	        //system.debug('BodyBlob: '+ res.getBodyAsBlob());
	        //system.debug('-get headers---'+res.getHeader('Location'));
            //CustomLog.create(CustomLog.INFO, 'HerokuService jar file body', res.getBody(), EncodingUtil.base64Encode(res.getBodyAsBlob()));
	        
	       	if (res.getStatusCode() == 200 ) { 
				saveFile (jarFileName, res.getBodyAsBlob(), licenseId);
				update new License__c (Id = licenseId, DateCreationKey__c = myDateTime.date());
	       	} else {
	            CustomLog.create(CustomLog.WARNING, 'HerokuService retrieve jar failed on:', 'StatusCode: '+res.getStatusCode(), '');
	       	}
    	}       
        return '';        	  	
    }

	/**
	 * Remove old jar files and save the new file
	 **/
	private void saveFile(String fileName, Blob data, Id parentId) {
	       		/*
	       		//in jarFileName -> example filename: 192.168.1.100_AEOS_3.4_license_mplify.jar
		        String filename = jarFileName;
				Attachment a = new Attachment();
		        a.Name = fileName;
		        a.ContentType = 'application/zip';	//'text/plain'
		        a.Body = res.getBodyAsBlob();
		        a.parentId = licenseId;
		        insert a;
		        */
		//Remove files related to the License of the type jar
		//No removal of generated license jar files DvtH20190902 -> reactivated DvtH20200706
		
		try {
			List<ContentDocument> cdDeleteList = new List<ContentDocument>();
			List<ContentDocumentLink> cdlList = ContentDocumentLinkDao.getByLinkedEntityId(ParentId);
			for (ContentDocumentLink cdl : cdlList) {
				cdDeleteList.add(new ContentDocument(Id = cdl.ContentDocumentId));
			}
			if (!cdDeleteList.isEmpty()) {
				delete cdDeleteList;
			}
		} catch(Exception ex) {
    		System.debug('HerokuService delete existing Jar files failed at: ' + ex.getMessage() + ' | ' + ex.getLineNumber());
            CustomLog.create(CustomLog.ERROR, 'HerokuService delete existing Jar files failed at: ' + ex.getCause(), ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
		}
		
		//Create the new file 
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = data;
        cv.Title = fileName;
        cv.PathOnClient = filename;
        insert cv;	

		//Relate the file to the License        
        ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = ContentVersionDao.getById(cv.Id)[0].ContentDocumentId;
		cdl.LinkedEntityId = parentId;
		cdl.ShareType = 'V';
		insert cdl;	
	}
	
	
	/**
	 * GetToken retry on Read timeout
	 **/
    //private static String getTokenRetry(ApiTokenStore__c ats) {
    private String getTokenRetry() {
    	String accessToken = null;
    	for (Integer cnt = 0; cnt < 4; cnt++) {
	    	try {
	    		accessToken = getToken();
	    		break;
	    	} catch(Exception ex) {
	            CustomLog.create(CustomLog.ERROR, 'HerokuService-> getToken failed: ' + ex.getCause(), ex.getMessage() + ' | ' + ex.getLineNumber(), ex.getStackTraceString());
	            if (ex.getMessage().contains('Read timed out')) {
		            CustomLog.create(CustomLog.INFO, 'HerokuService-> getToken retry: ' + cnt, '', '');
	            } else {
	            	break;
	            }
	    	}
    	}
        return accessToken;
    }
    
	/**
	 *
	 **/
    //private static String getToken(ApiTokenStore__c ats) {
    private String getToken() {
    	system.debug('DvtH_001');
    	String accessToken = null;
		HttpRequest req = new HttpRequest();
        Http http = new Http();
	
		//https://nedap-licgen001.herokuapp.com/oauth/token?grant_type=password&client_id=app&client_secret=123456&username=arip&password=passw0rd
	
        String auth_url = ats.Url__c + '/oauth/token';
        auth_url += '?grant_type=password';
        auth_url += '&client_id=' + ats.ClientId__c;	
		auth_url += '&client_secret=' + ats.ClientSecret__c;	
        auth_url += '&username=' + ats.UserName__c;	
        auth_url += '&password=' + ats.Password__c;	
	
        req.setMethod('POST');
        req.setEndpoint(auth_url);
		HTTPResponse res = new HTTPResponse();
		if (Test.isRunningTest()) {
			res.setBody('{"value":"64a0b006-b672-4abd-8b7c-9841bd22d373","expiration":1542318381552,"tokenType":"bearer","refreshToken":{"value":"27417211-3f8d-4619-ab6d-5f29d30512e8","expiration":1544910163024},"scope":[" trust"," write","read"],"additionalInformation":{},"expiresIn":99,"expired":false}');
		} else {
        	res = http.send(req);
		}                        
		//System.debug(res.getStatus());    
		System.debug(res.getStatusCode());    
		String theTokenResponse = res.getBody();
		//System.debug(theTokenResponse);    
			
		JSONParser parser = JSON.createParser(theTokenResponse);
		String fieldName;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
				fieldName = parser.getText();
				parser.nextToken();
				if(fieldName == 'value') {
					accessToken = parser.getText().trim();
					break;
		   		}
			}
		}
		System.debug('accessToken: '+accessToken);    
        return accessToken;
	}

    
    
    /**
     * Create License Txt file with the following format:
     *
	 *	VERSION||3.4
		PRODUCT||AEOS
		LICENSE_MODEL_VERSION||2
		SYSKEYPROVIDERID||IpAddress
		LICENSE KEY||19413440
		LICENSEE NAME||WARSAW CHOPIN AIRPORT
		IP ADDRESS 1||10.205.129.103
		START DATE||21-07-2016
		PERIOD||3650
		RENEWALPERIOD||30
		8030010|AEOS ADDITIONAL USER|11
		8030020|AEOS IDENTIFIERS|15100
		8030100|AEOS ONLINE DOOR|170
		8030150|AEOS INTRUSION DETECT. SENSOR|2190
		8030140|AEOS VIDEO SURVEILL. CAMERA|10
		MaxBadges||0
		MaxRuleEngineRules||0
		MaxOffLineEntrances||0    
     *
     * @param licenseId Id of the License Header to create a license txt file off
     * @return String with license text file content
     **/
    private String createLicenseTxtDataNew(Id licenseId) {
    	String licenseTxtData = '';
    	
    	Set<Id> LicenseIdSet = new Set<Id>();
    	LicenseIdSet.add(licenseId);
    	List<License__c> licenseList = LicenseDao.getById(LicenseIdSet);
    	License__c lic = licenseList[0];

		DateTime myDateTime = DateTime.now();
		String myDate = myDateTime.formatGMT('yyyyMMddHHmmssSSS');

    	Time myTime = Time.newInstance(12, 0, 0, 0); // use mid day to prevent conversions
    	
    	//check clean used fields
    	String version = lic.Version__c;
    	String productName = lic.VersionDescription__c;
    	String licenseModelVersion = lic.LicenseTypeVersion__c; //1 or 2
		string licenseNumber = lic.Name;
    	String systemkeyProvider = lic.SystemkeyProvider__c;
		String licenseKey = lic.Name; 
    	String customerName = lic.EndCustomer__r.Name == null ? '' : lic.EndCustomer__r.Name;
    	String ipAddress1 = lic.IpAddress1__c;
		//if ('SentinelSuperPro'.equals(systemkeyProvider)) {
		//	ipAddress1 = lic.Name;
		//} else {
		//	ipAddress1 = lic.IpAddress1__c;
		//}
    	String startDate = lic.ValidityDateStart__c == null ? '' : Datetime.newInstance(lic.ValidityDateStart__c, myTime).formatGMT('dd-MM-yyyy');
    	String period = String.valueOf(lic.ValidityPeriodDays__c);    	
    	String renewalPeriod = lic.RenewalPeriod__c;
    	
		Decimal maxBadges = 0;		//summary of license items?
		Decimal maxRuleEngineRules = 0;
		Decimal maxOffLineEntrances = 0;    
    	
    	//License Header Data
    	licenseTxtData += 'VERSION||' + version + '\n';
    	licenseTxtData += 'PRODUCT||' + productName + '\n'; 
    	licenseTxtData += 'LICENSE_MODEL_VERSION||' + licenseModelVersion + '\n';
    	licenseTxtData += 'SYSKEYPROVIDERID||' + systemkeyProvider + '\n';
    	licenseTxtData += 'LICENSE KEY||' + licenseKey + '\n'; 
    	licenseTxtData += 'LICENSEE NAME||' + customerName + '\n';
		if (!('SentinelSuperPro'.equals(systemkeyProvider) && ipAddress1 == null)) {
    		licenseTxtData += 'IP ADDRESS 1||' + IpAddress1 + '\n';
		}
    	licenseTxtData += 'START DATE||' + startDate + '\n';
    	licenseTxtData += 'PERIOD||' + period + '\n';
    	licenseTxtData += 'RENEWALPERIOD||' + renewalPeriod + '\n';
    	    	
    	//License Itemr Data
    	String itemDescription;
    	String articleNumber;
		Set<String> artNoSet = new Set<String>();
    	for (LicenseItem__c li : lic.LicenseItems__r) {
    		if (li.ArtNo__c != null) {
				artNoSet.add(li.ArtNo__c);
			}
		}

		Map<String,Decimal> PackageQuantityArtNoMap = new Map<String,Decimal>();
		if (!artNoSet.isEmpty()) {
			List<PackageQuantity__c> PackageQuantityList = PackageQuantityDao.getByName(artNoSet);
			for (PackageQuantity__c pq : PackageQuantityList) {
				PackageQuantityArtNoMap.put(pq.Name, pq.SetQuantity__c);
			}
		}

		Decimal setQuantity;
		for (LicenseItem__c li : lic.LicenseItems__r) {
    		articleNumber = li.ArtNo__c;
    		if (articleNumber == null) {
    			articleNumber = '';
			}
    		//Max length = 7
    		if (articleNumber.length() > 7) {	
    			articleNumber = articleNumber.substring(0,7);
    		} else {
    			for (Integer i = articleNumber.length(); i<7; i++) {
    				articleNumber += '.';
    			}
    		}
    		
    		itemDescription = li.ItemDescription__c; 
    		if (itemDescription == null) {
    			itemDescription = '';
    		}
    		//Max length = 37 -> 80?
    		if (itemDescription.length() > 80) {	
    			itemDescription = itemDescription.substring(0,80);
    		}
			
			//Package/Bundle Quantity
			setQuantity = PackageQuantityArtNoMap.get(li.ArtNo__c);
			if (setQuantity == null || setQuantity < 1) {
				setQuantity = 1;
			}

	    	licenseTxtData += li.ArtNo__c + '|' + itemDescription + '|' + (li.Quantity__c * setQuantity) + '\n';
    	}
    			
		if (!artNoSet.isEmpty()) {
        	List<ExportFactor__c> ExportFactorList = ExportFactorDao.getByName(artNoSet);
			Map<String, ExportFactor__c> ExportFactorMap = new Map<String, ExportFactor__c>();
			for (ExportFactor__c ef : ExportFactorList) {
				ExportFactorMap.put(ef.Name, ef);			}

			ExportFactor__c efTmp;
	    	for (LicenseItem__c li : lic.LicenseItems__r) {
				if (li.Quantity__c == null) {
					li.Quantity__c = 0;
				}
				efTmp = ExportFactorMap.get(li.ArtNo__c);
				if (efTmp!=null) {				
					if (efTmp.ExportCode__c == 'LICENSEQTY') {
						maxBadges += (li.Quantity__c * efTmp.ExportFactor__c);
					} else if (efTmp.ExportCode__c == 'RULE ENG') {
						maxRuleEngineRules += (li.Quantity__c * efTmp.ExportFactor__c);
					} else if (efTmp.ExportCode__c == 'OFFL ENTR') {
						maxOffLineEntrances += (li.Quantity__c * efTmp.ExportFactor__c);
					}				
				}
			}
		}

    	//License footer
    	licenseTxtData += 'MaxBadges||' + String.valueOf(Integer.valueOf(maxBadges)) + '\n';
    	licenseTxtData += 'MaxRuleEngineRules||' + String.valueOf(Integer.valueOf(maxRuleEngineRules)) + '\n';
    	licenseTxtData += 'MaxOffLineEntrances||' + String.valueOf(Integer.valueOf(maxOffLineEntrances)) + '\n';
    	
    	//Jar File name:
    	//example filename: 19396805_AEOS_3.4_license_mplify-20200512065209160.jar
    	
    	this.jarFileName = licenseNumber + '_' + productName + '_' + version + '_' + customerName + '_' + myDate + '.jar'; 	
    		
    	return licenseTxtData;
    }  
}