<%@page import="com.liferay.portal.kernel.json.JSONException"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.sx.icecap.constant.IcecapMVCCommands"%>
<%@page import="com.liferay.document.library.kernel.model.DLFolderConstants"%>
<%@page import="com.liferay.petra.string.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.PropsKeys"%>
<%@page import="com.liferay.portal.kernel.util.PrefsPropsUtil"%>
<%@page import="com.liferay.petra.string.StringUtil"%>
<%@page import="com.liferay.document.library.kernel.model.DLFileEntryConstants"%>
<%@page import="com.liferay.portal.kernel.util.Constants"%>
<%@page import="com.liferay.portal.kernel.service.ServiceContext"%>
<%@page import="com.liferay.portal.kernel.model.TicketConstants"%>
<%@page import="com.liferay.portal.kernel.model.User"%>
<%@page import="com.liferay.portal.kernel.service.TicketLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.model.Ticket"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="com.sx.constant.StationXConstants"%>
<%@page import="com.sx.icecap.constant.IcecapDataTypeAttributes"%>
<%@page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@page import="com.sx.icecap.constant.IcecapWebKeys"%>
<%@page import="com.sx.icecap.model.DataType"%>
<%@ include file="../init.jsp" %>

<script type="text/javascript" src="<%=request.getContextPath()%>/js/samples/crf-data-samples-fixed.js"></script>


<%
	DataType dataType = (DataType)renderRequest.getAttribute(DataType.class.getName());
	JSONObject structuredData = (JSONObject)renderRequest.getAttribute(IcecapWebKeys.STRUCTURED_DATA_JSON_OBJECT);
	
	String cmd = (String)renderRequest.getAttribute(StationXWebKeys.CMD);
	String structuredDataId = (String)renderRequest.getAttribute(IcecapWebKeys.STRUCTURED_DATA_ID);
	if( Validator.isNull(structuredDataId) ){
		structuredDataId = "0";
	}
	
	Ticket ticket = TicketLocalServiceUtil.addTicket(user.getCompanyId(), User.class.getName(), user.getUserId(), TicketConstants.TYPE_IMPERSONATE, null, null, new ServiceContext());
	
	Calendar today = Calendar.getInstance(locale);
%>

<portlet:resourceURL id="<%= IcecapMVCCommands.RESOURCE_STRUCTURED_DATA_DELETE_FILE %>" var="deleteFileURL">
</portlet:resourceURL>

<%
	JSONArray terms = structuredData.getJSONArray("terms");
	for( int i=0; i<terms.length(); i++ ){
		JSONObject termData = terms.getJSONObject(i);
		if( termData.getString("termType").equalsIgnoreCase("File")){
			termData.put( "deleteFileURL", deleteFileURL.toString() );
			
		}
	}
%>

<portlet:actionURL name="<%= IcecapMVCCommands.ACTION_STRUCTURED_DATA_ADD %>" var="saveActionURL">
	<portlet:param name="<%= StationXWebKeys.CMD %>" value="<%= cmd %>"/>
	<portlet:param name="<%= StationXWebKeys.DATATYPE_ID %>" value="<%=String.valueOf(dataType.getDataTypeId()) %>"/>
	<portlet:param name="dataTypeName" value="<%=dataType.getDataTypeName() %>"/>
	<portlet:param name="dataTypeVersion" value="<%=dataType.getDataTypeVersion() %>"/>
	<portlet:param name="<%= IcecapWebKeys.STRUCTURED_DATA_ID %>" value="<%= structuredDataId %>"/>
</portlet:actionURL>

<portlet:resourceURL id="<%= IcecapMVCCommands.RESOURCE_STRUCTURED_DATA_ADD_SAMPLE %>" var="addSampleData">
	<portlet:param name="<%= StationXWebKeys.DATATYPE_ID %>" value="<%=String.valueOf(dataType.getDataTypeId()) %>"/>
</portlet:resourceURL>

<aui:container cssClass="SXIcecap-web">
	<aui:row cssClass="form-section">
		<aui:col md="12" >
			<aui:form action="<%= saveActionURL %>" enctype="multipart/form-data" method="POST" name="fm" inlineLabels="true" >
				<aui:fieldset-group markupView="lexicon">
					<aui:fieldset label="datatype">
						<span style="display:table-cell; width:40%;">
						<aui:input name="dataTypeName" label="datatype-name" disabled="true" value="<%= dataType.getDataTypeName() %>"></aui:input>
						</span>
						<span style="display:table-cell; width:10%;">
						<aui:input name="dataTypeVersion" label="datatype-version" disabled="true" value="<%= dataType.getDataTypeVersion() %>"></aui:input>
						</span>
						<span style="display:table-cell; width:10%;">
						<aui:input name="dataTypeExtension" label="datatype-extention" disabled="true" value="<%= dataType.getExtension() %>"></aui:input>
						</span>
					</aui:fieldset>
				</aui:fieldset-group>
				<div>
					<span><%= dataType.getTooltip(locale) %></span>
				</div>
				<hr class=""></hr>
				
				<input type="hidden" id="<portlet:namespace/>hasFile" name="<portlet:namespace/>hasFile"/>
				<input type="hidden" id="<portlet:namespace/>uploadParams" name="<portlet:namespace/>uploadParams"/>
				<input type="hidden" id="<portlet:namespace/>structuredData" name="<portlet:namespace/>structuredData"/>
				<div class="container-fluid">
					<div class="row">
						<div class="col-md-12"  id="<portlet:namespace/>canvasPanel"></div>
					</div>
				</div>
				<aui:button-row>
					<c:choose>
						<c:when test="<%= cmd.equalsIgnoreCase(StationXConstants.CMD_ADD) %>">
							<aui:button type="submit" name="add"></aui:button>
						</c:when>
						<c:otherwise>
							<aui:button type="submit" name="update"></aui:button>
						</c:otherwise>
					</c:choose>
					<aui:button name="addSamples" value="add-samples"></aui:button>
					<aui:button name="delete" value="delete"></aui:button>
				</aui:button-row>
			</aui:form>
		</aui:col>
	</aui:row>
</aui:container>

<script>
$(document).ready(function(){
	let SX = StationX(  '<portlet:namespace/>', 
			'<%= defaultLocale.toString() %>',
			'<%= locale.toString() %>',
			<%= jsonLocales.toJSONString() %> );
	
	let jsonDataStructure = <%= structuredData.toString() %>;
	
	let dataStructure = SX.newDataStructure(  jsonDataStructure) ;
	if( <%= cmd.equalsIgnoreCase("update") %> === true ){
		$("#<portlet:namespace/>structuredData").val( dataStructure.toFileContent() );
	}
	
	dataStructure.render( SX.SXConstants.FOR_EDITOR, $('#<portlet:namespace/>canvasPanel') );
	
	let uploadParams = new Object();
	
	Liferay.on( SX.SXIcecapEvents.DATATYPE_SDE_VALUE_CHANGED, function( event ){
		event.stopPropagation();
		event.preventDefault();
		
		let eventData = event.sxeventData;
		
		if( eventData.targetPortlet !== '<portlet:namespace/>' ){
			return;
		}
		
		let term = eventData.term;
		
		if( term.termType === SX.TermTypes.FILE){
			$('#<portlet:namespace/>hasFile').val(true);
		
			if( term.value ){
				uploadParams[term.termName] = term.getJsonValue();
			}
			else{
				delete uploadParams[term.termName];
			}
			
			$('#<portlet:namespace/>uploadParams').val( 
						JSON.stringify(uploadParams) );
		}
		
		$("#<portlet:namespace/>structuredData").val( dataStructure.toFileContent() );
	});
	
	$('#<portlet:namespace/>addSamples').click( function(event){
		crfSampleData.forEach( data =>{
				$.ajax({
					url: '<%=  addSampleData.toString() %>',
					method: 'post',
					dataType: 'text',
					data: {
						<portlet:namespace/>sampleData: JSON.stringify(data)
					},
					success: function( result ){
						console.log( result );
					}
				});
		});
		/*
		crfSampleData.forEach( data =>{
			Object.keys( data ).forEach( key =>{
				if( !data[key] ){
					delete data[key];
				}
				else{
					let term = dataStructure.getTermByName( key );
					if( term.termType === "List" ){
						if( term.displayStyle === 'select'){
							data[key] = [data[key]];
						}
					}
					else if( term.termType === 'Numeric'){
						data[key] = Number(data[key]);
					}
					else if( term.termType === 'Date'){
						data[key] = new Date(data[key]).getTime();
					}
				}
			});
		});
		*/
	});
});
</script>
