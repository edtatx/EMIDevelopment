<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Quote_Approved</fullName>
        <description>Quote Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Approved</template>
    </alerts>
    <alerts>
        <fullName>Quote_Rejected</fullName>
        <description>Quote Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Send_Approval_Request</fullName>
        <description>Send Approval Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>ed.tjarks@emicoastal.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Quote_Approval_Needed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_to_Approved</fullName>
        <description>Update Quote Status to &quot;Approved&quot;</description>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Draft</fullName>
        <description>Update Quote Status to &quot;Draft&quot;</description>
        <field>Status</field>
        <literalValue>Draft</literalValue>
        <name>Update to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_In_Review</fullName>
        <description>Update Quote Status to &quot;In Review&quot;</description>
        <field>Status</field>
        <literalValue>In Review</literalValue>
        <name>Update to In Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Rejected</fullName>
        <description>Update Quote to &quot;Rejected&quot; Status</description>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>Update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
