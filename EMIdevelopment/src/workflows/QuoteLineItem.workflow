<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Default_Quote_Cost</fullName>
        <field>Quote_Unit_Cost__c</field>
        <formula>Product2.Cost__c</formula>
        <name>Default Quote Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_End_Date</fullName>
        <field>End_Date__c</field>
        <formula>Start_Date__c +  Quote.Opportunity.Expected_Duration__c</formula>
        <name>Update End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Start_Date</fullName>
        <field>Start_Date__c</field>
        <formula>Quote.Opportunity.Expected_Start_Date__c</formula>
        <name>Update Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Calculate End Date</fullName>
        <actions>
            <name>Update_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Quote.Opportunity.Expected_Duration__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default Costs from Product</fullName>
        <actions>
            <name>Default_Quote_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Quote_Unit_Cost__c</field>
            <operation>lessOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Default Start Date</fullName>
        <actions>
            <name>Update_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Quote.Opportunity.Expected_Start_Date__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
