/**
 * @description   : Class to process custom logging 
 * @author (s)    : BRITE
 */
public without sharing class CustomLog {
	public static final String DEBUG = 'DEBUG'; 
	public static final String INFO = 'INFO'; 
	public static final String WARNING = 'WARNING'; 
	public static final String ERROR = 'ERROR'; 
	public static final String FATAL = 'FATAL';
	public static Integer customLogCount = null;
	private static List<CustomLog__c> clList = new List<CustomLog__c>();
	 
    public static void log(String type, String message, String description, String stackTrace) {
    	try {
    		CustomLogSettings__c cs = CustomLogSettings__c.getValues('ALL');
    		if (cs == null) {
		    	cs = new CustomLogSettings__c(Name='ALL', LogActive__c=true, LogLevel__c='DEBUG', MaxRecords__c=1000);
    			insert cs;
    		}
    		if (cs.LogActive__c && isLevelHigherOrEqual(type, cs.LogLevel__c)) {
    			if (customLogCount == null) {
    				customLogCount = database.countQuery('select count() from CustomLog__c');
    			}
    			customLogCount++;
    			if (customLogCount>=cs.MaxRecords__c) {
    				Database.DeleteResult[] drList = Database.delete([select id from CustomLog__c order by CreatedDate limit 100],false);
					// Iterate through each returned result
					for(Database.DeleteResult dr : drList) {
					    if (dr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        //System.debug('Successfully deleted CustomLog__c with ID: ' + dr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : dr.getErrors()) {
					            //System.debug('The following error has occurred.');                    
								System.debug('Custom Log failed: '+err.getStatusCode() + ': ' + err.getMessage());
					            //System.debug(err.getStatusCode() + ': ' + err.getMessage());
					            //System.debug('CustomLog__c fields that affected this error: ' + err.getFields());
					        }
					    }
					}
    			}
    			if (message != null && message.length()>255) {
    				message = message.substring(0,255);
    			}
    			if (description != null && description.length()>32767) {
    				description = description.substring(0,32767);
    			}
    			if (stackTrace != null && stackTrace.length()>32767) {
    				stackTrace = stackTrace.substring(0,32767);
    			}
    			
    			//insert new CustomLog__c(Type__c=type, Message__c=message, Description__c=description, StackTrace__c=stackTrace);
    			Database.SaveResult sr = Database.insert(new CustomLog__c(Type__c=type, Message__c=message, Description__c=description, StackTrace__c=stackTrace),false);
			    if (sr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        //System.debug('Successfully inserted CustomLog__c with ID: ' + sr.getId());
			    }
			    else {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            //System.debug('The following error has occurred.');                    
						System.debug('Custom Log failed: '+err.getStatusCode() + ': ' + err.getMessage());
			            //System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            //System.debug('CustomLog__c fields that affected this error: ' + err.getFields());
			        }
			    }
			}
    	} catch (Exception ex) {
    		System.debug('Custom Log failed: '+ex.getMessage() + ' | ' + ex.getStackTraceString());
    	}
    }

    public static void create(String type, String message, String description, String stackTrace) {
    	try {
    		CustomLogSettings__c cs = CustomLogSettings__c.getValues('ALL');
    		if (cs == null) {
		    	cs = new CustomLogSettings__c(Name='ALL', LogActive__c=true, LogLevel__c='DEBUG', MaxRecords__c=1000);
    			insert cs;
    		}
    		if (cs.LogActive__c && isLevelHigherOrEqual(type, cs.LogLevel__c)) {
    			if (message != null && message.length()>255) {
    				message = message.substring(0,255);
    			}
    			if (description != null && description.length()>32767) {
    				description = description.substring(0,32767);
    			}
    			if (stackTrace != null && stackTrace.length()>32767) {
    				stackTrace = stackTrace.substring(0,32767);
    			}
    			
    			clList.add(new CustomLog__c(Type__c=type, Message__c=message, Description__c=description, StackTrace__c=stackTrace));
			}
    	} catch (Exception ex) {
    		System.debug('Custom Log failed: '+ex.getMessage() + ' | ' + ex.getStackTraceString());
    	}
    }
    
    public static void commitLog() {
    	try {
    		CustomLogSettings__c cs = CustomLogSettings__c.getValues('ALL');
    		Integer cnt = 0;
    		if (cs == null) {
		    	cs = new CustomLogSettings__c(Name='ALL', LogActive__c=true, LogLevel__c='DEBUG', MaxRecords__c=1000);
    			insert cs;
    		}
    		if (cs.LogActive__c && clList != null && clList.size() > 0) {
    			cnt = clList.size();
    			if (customLogCount == null) {
    				customLogCount = database.countQuery('select count() from CustomLog__c');
    			}
    			customLogCount += cnt;
    			cnt += 10;
    			if (customLogCount>=cs.MaxRecords__c) {
    				Database.DeleteResult[] drList = Database.delete([select id from CustomLog__c order by CreatedDate limit :cnt],false);
					// Iterate through each returned result
					for(Database.DeleteResult dr : drList) {
					    if (dr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        //System.debug('Successfully deleted CustomLog__c with ID: ' + dr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : dr.getErrors()) {
					            //System.debug('The following error has occurred.');                    
								System.debug('Custom Log failed: '+err.getStatusCode() + ': ' + err.getMessage());
					            //System.debug(err.getStatusCode() + ': ' + err.getMessage());
					            //System.debug('CustomLog__c fields that affected this error: ' + err.getFields());
					        }
					    }
					}
    			}
    			
    			//insert new CustomLog__c(Type__c=type, Message__c=message, Description__c=description, StackTrace__c=stackTrace);
    			Database.SaveResult[] srList = Database.insert(clList,false);
				for(Database.SaveResult sr : srList) {
				    if (sr.isSuccess()) {
				        // Operation was successful, so get the ID of the record that was processed
				        //System.debug('Successfully inserted CustomLog__c with ID: ' + sr.getId());
				    }
				    else {
				        // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {
				            //System.debug('The following error has occurred.');                    
							System.debug('Custom Log failed: '+err.getStatusCode() + ': ' + err.getMessage());
				            //System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            //System.debug('CustomLog__c fields that affected this error: ' + err.getFields());
				        }
				    }
				}
			}
    	} catch (Exception ex) {
    		System.debug('Custom Log failed: '+ex.getMessage() + ' | ' + ex.getStackTraceString());
    	} finally {
			clList = new List<CustomLog__c>();
    	}
    }
    
    /* PRIVATE METHODS */
    
    /**
     * @description Verify if logging level is higher or equal to the setting of logging level. 
     */
    @testVisible
    private static Boolean isLevelHigherOrEqual(String logLevel, String logLevelSetting) {
        Boolean isHigherOrEqual = false;
        
        if (logLevelSetting == 'DEBUG'
            || (logLevelSetting == 'INFO' && logLevel != 'DEBUG')
            || (logLevelSetting == 'WARNING' && logLevel != 'DEBUG' && logLevel != 'INFO')
            || (logLevelSetting == 'ERROR' && (logLevel == 'ERROR' || logLevel == 'FATAL'))
            || (logLevelSetting == 'FATAL' && logLevel == 'FATAL')) {
            isHigherOrEqual = true;
        } 
        
        return isHigherOrEqual;
    }
}