/**
 * @description Show the following account information with images: 
 *                  - CSAT score
 *                  - Service level
 *                  - Hypercare yes/no
 *                  - Charity
 * @author BRITE
 */
 import { LightningElement, api, wire } from 'lwc';

 import getAccountData from '@salesforce/apex/AccountCsatTypeHypercareCtrl.getAccountData';
 
 import ICONS from '@salesforce/resourceUrl/AccountTypeIconsSvg';
  
 const VALUE_UNKNOWN = '...';
 const ACCOUNT_TYPE_MERCHANT = 'Merchant';
 const ACCOUNT_TYPE_MERCHANT_PARTNER = 'Merchant & Partner';
 const ACCOUNT_TYPE_PARTNER = 'Partner';
 
 const SERVICE_LEVEL_VIP = 'vip';
 const SERVICE_LEVEL_PARTNER = 'partner';
 const SERVICE_LEVEL_INTEGRATOR = 'integrator';
 const SERVICE_LEVEL_SCHEMES = 'schemes';
 const SERVICE_LEVEL_SMALL = 'small';
 const SERVICE_LEVEL_MIDMARKET = 'mid-market';
 const SERVICE_LEVEL_ENTERPRISE = 'enterprise';
 const SERVICE_LEVEL_CHARITY = 'charity';

 const PARTNER_SUBTYPE_INTEGRATOR = 'System Integrators';
 const INDUSTRY_CHARITY = 'Non-Profit Organizations';
 
 export default class accountCsatTypeHypercare extends LightningElement {
 
    @api recordId;
 
    @api showCsat;
    @api showServiceLevel;
    @api showHypercare;
 
    csatIcon;
    csatValue;
    csatBucket;
 
    serviceLevelIcon;
    serviceLevelValue;
    companySegmentValue;
    accountType;
    isSystemIntegrator;
    serviceLevelBucket;
    hyperCareText;
    isEscalated = false;
    hypercareValue = false;
    industry;
    isCharity = false;

    hypercareIcon = ICONS + '/other/heart.svg#heart';
     
    @wire(getAccountData, { recordId: '$recordId' })
    accountData({data, error}) {
        if (data) {
            this.csatValue = data.csatScorePercentage;
            this.serviceLevelValue = data.serviceLevel;
            this.companySegmentValue = data.companySegment;
            this.accountType = data.accountType;
            this.isSystemIntegrator = (data.partnerSubType == PARTNER_SUBTYPE_INTEGRATOR);
            this.isEscalated = data.isEscalated;
            this.hypercareValue = data.hypercareMode;
            this.industry = data.industry;

            this.setHyperCareText();
            this.setCsatBucketIcon(this.csatValue);
            this.setServiceLevelBucketIcon(this.serviceLevelValue, this.companySegmentValue, this.accountType, this.isSystemIntegrator, this.industry);
 
            this.toggleColor();
        } else if (error) {
            console.log(error);
            this.setHyperCareText();
            this.setCsatBucketIcon(null);
            this.setServiceLevelBucketIcon(null, null, null, null, null);
            this.toggleColor();
        }
    }

 
     /**
      * @description Based on wether the Case is escalated, set the text of the hypercare icon.
      */
     setHyperCareText() {
         if (this.isEscalated) {
             this.hyperCareText = 'escalated';
         } else {
             this.hyperCareText = 'hypercare';
         }
     }
     
 
     /**
      * @description Based on the actual CSAT score of the account, 
      *      place the score in a bucket and assign an icon to it.
      */
     setCsatBucketIcon(csat) {
         if (csat == null) {
             this.csatBucket = VALUE_UNKNOWN;
             this.csatIcon = ICONS + '/smiley/expressionless.svg#expressionless';
         } else if (csat.valueOf() < 40) {
             this.csatBucket = '0-40';
             this.csatIcon = ICONS + '/smiley/doubt.svg#doubt';
         } else if (csat.valueOf() < 60) {
             this.csatBucket = '40-60';
             this.csatIcon = ICONS + '/smiley/expressionless.svg#expressionless';
         } else if (csat.valueOf() < 80) {
             this.csatBucket = '60-80';
             this.csatIcon = ICONS + '/smiley/happy.svg#happy';
         } else {
             this.csatBucket = '80+';
             this.csatIcon = ICONS + '/smiley/happy.svg#happy';
         }
     }
 
    /**
     * @description Based on the Service Level and Company Segment of the account, 
     *      place the value in a bucket and assign an icon to it.
     */
    setServiceLevelBucketIcon(serviceLevel, companySegment, accountType, isSystemIntegrator, industry) {
        if (serviceLevel == 'VIP') {
            this.serviceLevelBucket = SERVICE_LEVEL_VIP;
            this.serviceLevelIcon = ICONS + '/other/diamond.svg#diamond';
        } else if (industry == INDUSTRY_CHARITY) {
            this.isCharity = true;
            this.serviceLevelBucket = SERVICE_LEVEL_CHARITY;
            this.serviceLevelIcon = ICONS + '/other/charity.svg#charity';
        } else if (accountType == ACCOUNT_TYPE_MERCHANT || accountType == ACCOUNT_TYPE_MERCHANT_PARTNER) {
            switch(companySegment) {
                case '0 - 1 million':
                    this.serviceLevelBucket = SERVICE_LEVEL_SMALL;
                    this.serviceLevelIcon = ICONS + '/building/store.svg#store';
                    break;
                case '1 - 5 million':
                case '5 - 10 million':
                case '10 - 25 million':
                    this.serviceLevelBucket = SERVICE_LEVEL_MIDMARKET;
                    this.serviceLevelIcon = ICONS + '/building/company.svg#company';
                    break;
                case '25 - 50 million':
                case '50 - 150 million':
                case '150 - 500 million':
                case '500 - 2 billion':
                case '2 billion +':
                    this.serviceLevelBucket = SERVICE_LEVEL_ENTERPRISE;
                    this.serviceLevelIcon = ICONS + '/building/headquarters.svg#headquarters';
                    break;
                default: 
                    this.serviceLevelBucket = VALUE_UNKNOWN;
                    this.serviceLevelIcon = ICONS + '/building/company.svg#company';
            }
        } else if (isSystemIntegrator) {
            this.serviceLevelBucket = SERVICE_LEVEL_INTEGRATOR;
            this.serviceLevelIcon = ICONS + '/other/integrator.svg#integrator';
        } else if (accountType == ACCOUNT_TYPE_PARTNER) {
            this.serviceLevelBucket = SERVICE_LEVEL_PARTNER;
            this.serviceLevelIcon = ICONS + '/other/partner.svg#partner';
        } else {
            this.serviceLevelBucket = VALUE_UNKNOWN;
            this.serviceLevelIcon = ICONS + '/building/company.svg#company';
        } 
    }
 
     /**
      * @description Based on the value, icon and text needs to be in black (default), green or gray.
      */
     toggleColor() {
         if (this.showCsat) {
             var divCsatText = this.template.querySelector('[data-id="csat-text"]');
             var divCsatIcon = this.template.querySelector('[data-id="csat-icon"]');
             if (this.csatValue == null) {
                 divCsatText.className = 'text-color-unknown';
                 divCsatIcon.className = 'filter-unknown';
             } else {
                 divCsatText.className = 'text-color-default';
                 divCsatIcon.className = 'filter-default';
             }
         }
 
         if (this.showServiceLevel) {
             var divServiceLevelText = this.template.querySelector('[data-id="servicelevel-text"]');
             var divServiceLevelIcon = this.template.querySelector('[data-id="servicelevel-icon"]');
             if (this.serviceLevelBucket == SERVICE_LEVEL_VIP) {
                 divServiceLevelText.className = 'text-color-green';
                 divServiceLevelIcon.className = 'filter-green';
             } else if (this.serviceLevelBucket == SERVICE_LEVEL_INTEGRATOR 
                 || this.serviceLevelBucket == SERVICE_LEVEL_PARTNER 
                 || this.serviceLevelBucket == SERVICE_LEVEL_SCHEMES
                 || this.serviceLevelBucket == SERVICE_LEVEL_CHARITY) {
                     
                 divServiceLevelText.className = 'text-color-blue';
                 divServiceLevelIcon.className = 'filter-blue';
             } else if (this.serviceLevelBucket == VALUE_UNKNOWN) {
                 divServiceLevelText.className = 'text-color-unknown';
                 divServiceLevelIcon.className = 'filter-unknown';
             } else {
                 divServiceLevelText.className = 'text-color-default';
                 divServiceLevelIcon.className = 'filter-default';
             }
         }
 
         if (this.showHypercare) {
             var divHypercareText = this.template.querySelector('[data-id="hypercare-text"]');
             var divHypercareIcon = this.template.querySelector('[data-id="hypercare-icon"]');
             if (this.isEscalated) {
                 divHypercareText.className = 'text-color-red';
             } else if (this.hypercareValue){
                 divHypercareText.className = 'text-color-green';
             } else {
                 divHypercareText.className = 'text-color-unknown';
             }
             if (this.hypercareValue) {
                 divHypercareIcon.className = 'filter-green';
             } else {
                 divHypercareIcon.className = 'filter-unknown';
             }
         }
     }
 
 }