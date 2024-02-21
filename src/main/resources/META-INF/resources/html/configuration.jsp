<%@page import="com.sx.constant.RepositoryTypes"%>
<%@page import="com.liferay.portal.kernel.util.Constants"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.GetterUtil"%>
<%@ include file="init.jsp" %>

<liferay-portlet:actionURL portletConfiguration="<%=true%>" var="configurationActionURL" />
<liferay-portlet:renderURL portletConfiguration="<%=true%>"
    var="configurationRenderURL" />

<%  
String portletWidth = GetterUtil.getString(portletPreferences.getValue("portletWidth", "100%"));
String portletHeight = GetterUtil.getString(portletPreferences.getValue("portletHeight", "800px"));
String portletScroll = GetterUtil.getString(portletPreferences.getValue("portletScroll", "hidden"));
boolean menu = GetterUtil.getBoolean(portletPreferences.getValue("menu", "false"));
boolean sample = GetterUtil.getBoolean(portletPreferences.getValue("sample", "false"));
boolean openLocalFile = GetterUtil.getBoolean(portletPreferences.getValue("openLocalFile", "false"));
boolean openServerFile = GetterUtil.getBoolean(portletPreferences.getValue("openServerFile", "false"));
boolean save = GetterUtil.getBoolean(portletPreferences.getValue("save", "false"));
boolean saveAtLocal = GetterUtil.getBoolean(portletPreferences.getValue("saveAtLocal", "false"));
boolean download = GetterUtil.getBoolean(portletPreferences.getValue("download", "false"));
boolean upload = GetterUtil.getBoolean(portletPreferences.getValue("upload", "false"));
boolean hidden = portletScroll.equals("hidden");
boolean auto = portletScroll.equals("auto");

System.out.println( "Memues: " + menu);
String portletRepository = GetterUtil.getString(portletPreferences.getValue("portletRepository", RepositoryTypes.USER_HOME.toString()));
%>

<aui:form action="<%= configurationActionURL %>" method="post" name="fm"> 
    <aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />

    <!-- Preference control goes here -->
    <aui:container>
    	<aui:row>
    		<aui:col md="6">
    			<aui:fieldset label="portlet-size">
						    <aui:input label="Portlet Width:" name="preferences--portletWidth--" type="text" value="<%= portletWidth %>" inlineField="true" inlineLabel="true"  />
						    <aui:input label="Portlet Height:"  name="preferences--portletHeight--" type="text" value="<%= portletHeight %>" inlineField="true" inlineLabel="true"  />
				</aui:fieldset>
			    <aui:select label="portlet-scroll" name="preferences--portletScroll--">
			    	<aui:option value="hidden" label="hidden"></aui:option>
			    	<aui:option value="auto"  label="auto"></aui:option>
			    </aui:select>
    		</aui:col>
    		<aui:col md="6">
    			<aui:fieldset label="menus"> 
    				<aui:input type="checkbox" name="preferences--menu--" checked="<%=menu%>" label="Menu"/>
    				<div style="border:solid grey 1px;padding: 10px;">
    					<aui:input type="checkbox" name="preferences--sample--" checked="<%=sample%>" label="Sample" disabled="true"/>
    					<aui:input type="checkbox" name="preferences--openLocalFile--" checked="<%=openLocalFile%>" label="Open Local File"  disabled="true"/>
    					<aui:input type="checkbox" name="preferences--openServerFile--" checked="<%=openServerFile%>" label="Open Server File"  disabled="true"/>
	    				<aui:input type="checkbox" name="preferences--save--" checked="<%=save%>" label="Save At Server"  disabled="true"/>
	    				<aui:input type="checkbox" name="preferences--saveAtLocal--" checked="<%=saveAtLocal%>" label="Save At Local"  disabled="true"/>
	    				<aui:input type="checkbox" name="preferences--download--" checked="<%=download%>" label="Download"  disabled="true"/>
	    				<aui:input type="checkbox" name="preferences--upload--" checked="<%=upload%>" label="Upload"  disabled="true"/>
    				</div>
    			</aui:fieldset>
    		</aui:col>
    	</aui:row>
    	<aui:button-row>
	        <aui:button type="submit" value="Save" cssClass="btn btn-primary"/>
    	</aui:button-row>
    </aui:container>
</aui:form>

