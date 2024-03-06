import { LightningElement, api, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

import BUSINESS_AS_USUAL from '@salesforce/schema/Account.BusinessAsUsual__c';
import NoAccountLinkedLabel from '@salesforce/label/c.NoAccountLinkedToCase';

export default class DynamicForm extends LightningElement {

    static renderMode = 'light';

    // expose a field to make it available in the template
    businessAsUsualField = BUSINESS_AS_USUAL;

    // flexipage provides recordId and title of the component
    @api title;
    @api recordId;
    @api accountId;

    records;
    errors;

    label = {NoAccountLinkedLabel};

    @wire(graphql, {
        query: '$caseQuery',
        variables: '$caseData',
    })
    caseQueryResult({ data, errors }) {
        if (data) {
            this.records = data.uiapi.query.Case.edges.map(edge => edge.node);
            if (this.records && this.records.length > 0) {
                this.accountId = this.records[0].AccountId.value;
            }
        }
        this.errors = errors;
    }

    get caseQuery() {
        // sends a request to the server only if recordId is provided
        if (!this.recordId) {
            return undefined;
        }

        return gql`
            query CaseData($recordId: ID) {
                uiapi {
                    query {
                        Case (where: { Id: { eq: $recordId } } ) {
                            edges {
                                node {
                                    Id
                                    AccountId {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `;
    }

    get caseData() {
        return {
            recordId: this.recordId,
        };
    }

}