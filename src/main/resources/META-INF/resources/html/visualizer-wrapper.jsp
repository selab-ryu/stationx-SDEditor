
<%@page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@page import="com.sx.icecap.constant.IcecapMVCCommands"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="com.sx.constant.StationXWebKeys"%>
<%@page import="com.sx.icecap.constant.IcecapWebKeys"%>
<%@page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@page import="com.sx.icecap.model.DataType"%>
<%@ include file="init.jsp" %>

<%

String basePortlet = ParamUtil.getString(renderRequest, "basePortlet");
JSONObject structuredData = (JSONObject)renderRequest.getAttribute(IcecapWebKeys.STRUCTURED_DATA_JSON_OBJECT);
boolean enableMenu = ParamUtil.getBoolean(renderRequest, "enableMenu", true);

String cmd = (String)renderRequest.getAttribute(StationXWebKeys.CMD);
long structuredDataId = ParamUtil.getLong( renderRequest, IcecapWebKeys.STRUCTURED_DATA_ID, 0 );
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

<div class="container sx-visualizer">
	<c:if test="<%= enableMenu %>">
		<div class="row header">
			<div class="col-sm-10">
				<div id="<portlet:namespace/>title" class="title"></div>
			</div>
			<div class="col-sm-2 menu"  id="<portlet:namespace/>menu">
				<div class="dropdown text-right">
					<button class="btn btn-primary dropdown-toggle" type="button" data-toggle="dropdown">
						Menu<span class="caret"></span>
	   				</button>
					<ul class="dropdown-menu dropdown-menu-right">
	                       <li><a href="#" id="<portlet:namespace/>sample"><i class="icon-file"></i>Sample</a></li>
	                       <li><a href="#" id="<portlet:namespace/>openLocalFile"><i class="icon-file"></i>Open local file</a></li>
	                       <li><a href="#" id="<portlet:namespace/>openServerFile"><i class="icon-file"></i>Open Server file</a></li>
					</ul>
				</div>
			</div>	
		</div>
	</c:if>
	<div class="row frame">
		<div class="col-md-12" id="<portlet:namespace/>canvasPanel">
		</div>
	</div>
</div>

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
	
	Liferay.on(SX.SXIcecapEvents.DATATYPE_SDE_VALUE_CHANGED, function( event ){
		let eventData = event.sxeventData;

		if( eventData.targetPortlet !== '<portlet:namespace/>' )		return;
		console.log( 'SDE DATATYPE_SDE_VALUE_CHANGED received...', eventData);
		
		let term = eventData.term;
		if( term.termType === 'List' ){
			dataStructure.activateSlaveTerms( term );
		}
		
		let sxEvent = {
				sxeventData: {
					sourcePortlet: '<portlet:namespace/>',
					targetPortlet: '<%= basePortlet %>',
					data: dataStructure.toFileContent()
				}
			};
		
		Liferay.fire( 'STRUCTURED_DATA_CHANGED', sxEvent  );
	});

});

</script>