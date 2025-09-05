  <%@page import="com.sx.visualizers.sde.constants.SDEMVCCommands"%>
<%@page import="com.sx.icecap.constant.IcecapMVCCommands"%>
<%@page import="com.sx.icecap.constant.IcecapWebKeys"%>
<%@page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@page import="com.sx.constant.StationXConstants"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@page import="com.sx.util.visualizer.api.VisualizerUtil"%>
<%@page import="com.sx.util.visualizer.api.VisualizerConfig"%>
<%@page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.json.JSONArray"%>
<%@page import="com.liferay.portal.kernel.language.LanguageUtil"%>
<%@page import="java.util.Set"%>
<%@page import="com.liferay.portal.kernel.util.PortalUtil"%>
<%@page import="java.util.Locale"%>
<%@ include file="init.jsp" %>

<link rel="stylesheet" href="<%= request.getContextPath()%>/css/main.css">

<%
	VisualizerConfig visualizerConfig = VisualizerUtil.getVisualizerConfig(renderRequest, portletDisplay, user);

	boolean menu = visualizerConfig.menuOptions.getBoolean("menu", false);
	boolean sample = visualizerConfig.menuOptions.getBoolean("sample", false);
	boolean openLocalFile = visualizerConfig.menuOptions.getBoolean("openLocalFile", false);
	boolean openServerFile = visualizerConfig.menuOptions.getBoolean("openServerFile", false);
	boolean saveAsLocalFile = visualizerConfig.menuOptions.getBoolean("saveAsLocalFile", false);
	boolean saveAsServerFile = visualizerConfig.menuOptions.getBoolean("saveAsServerFile", false);
	boolean download = visualizerConfig.menuOptions.getBoolean("download", false);
	
	String employer = visualizerConfig.employer;
	
	String cmd = ParamUtil.getString(renderRequest, StationXWebKeys.CMD, StationXConstants.CMD_ADD);

	String strDataPacket = ParamUtil.getString(renderRequest, StationXWebKeys.DATA_PACKET, "");
	boolean hasDataPacket = !strDataPacket.isEmpty();
	
	boolean employed = Validator.isNotNull(employer) && !employer.isEmpty();

	if( employed ){
		System.out.println( "Visualizer is employed by " + employer);
	}
	else{
		System.out.println( "Visualizer is not employed...");
	}
%>

<portlet:resourceURL id="<%= SDEMVCCommands.RESOURSE_COMMAND %>" var="serveResourceURL"></portlet:resourceURL>

<aui:container cssClass="station-x">
	<aui:row>
		<aui:col md="6">
			<div id="<portlet:namespace/>title" style="display:flex;align-items:self-end;overflow:hide;height:100%;font-size:0.9rem;font-weight:600;"></div>
		</aui:col>
		<aui:col md="4">
			<div id="<portlet:namespace/>inputStatusBar" style="display:flex;align-items:self-end;overflow:hide;height:100%;margin-bottom:10px;margin-left:10px; font-size:0.9rem;font-weight:600;float:right;">
			</div>
		</aui:col>
		
		<aui:col md="2"  name="menu">
			<div class="dropdown text-right">
				<button class="btn btn-primary dropdown-toggle" type="button" data-toggle="dropdown">
					Menu<span class="caret"></span>
   				</button>
				<ul class="dropdown-menu dropdown-menu-bottom">
						<li><a href="#" id="<portlet:namespace/>sample"><liferay-ui:message key="sample"/></a></li>
						<li><a href="#" id="<portlet:namespace/>openLocalFile"><liferay-ui:message key="open-local-file"/></a></li>
						<li><a href="#" id="<portlet:namespace/>openServerFile"><liferay-ui:message key="open-server-file"/></a></li>
						<li><a href="#" id="<portlet:namespace/>saveAsLocalFile"><liferay-ui:message key="save-as-local-file"/></a></li>
						<li><a href="#" id="<portlet:namespace/>saveAsServerFile"><liferay-ui:message key="save-as-server-file"/></a></li>
						<li><a href="#" id="<portlet:namespace/>saveAsDBRecord"><liferay-ui:message key="save-as-db-record"/></a></li>
						<li><a href="#" id="<portlet:namespace/>dawnload"><liferay-ui:message key="download"/></a></li>
				</ul>
			</div>
		</aui:col>	
	</aui:row>
	<aui:row>
		<aui:col>
			<hr class="title-horizontal-line">
		</aui:col>
	</aui:row>
	<aui:row>
		<aui:col md="12">
			<div id="<portlet:namespace/>canvas" style="<%=visualizerConfig.getDisplayStyle() %>">
				<div class="container-fluid">
					<div class="row" id="<portlet:namespace/>goToBar" style="display:none;" >
						<div class="col-md-6">
							<aui:select name="goToCategory" label="go-to-category" inlineLabel="left" inlineField="true">
								<aui:option label="term-name" value="termName"></aui:option>
								<aui:option label="display-name" value="displayName"></aui:option>
							</aui:select>
						</div>
						<div class="col-md-6" class="ui-widget">
							<aui:input name="goToSelector" label="go-to" inlineLabel="left" inlineField="true"></aui:input>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12"  id="<portlet:namespace/>canvasPanel"></div>
					</div>
				</div>
			</div>
		</aui:col>
	</aui:row>
</aui:container>

<script>
$(document).ready(function(){
	let SX = StationX(  '<portlet:namespace/>', 
			'<%= defaultLocale.toString() %>',
			'<%= locale.toString() %>',
			<%= jsonLocales.toJSONString() %> );
	
	 /***********************************************************************
		 * Draw Function on Canvas
		 ***********************************************************************/
		let loadData = function( dataStructure ){
		 	//console.log('dataStructure: ', dataStructure);
		 	if( dataStructure.structuredDataId ){
		 		
				$('#<portlet:namespace/>canvasPanel').empty();
				$('#<portlet:namespace/>title').text(dataStructure.title);
		 	}
			dataStructure.render();
			//dataStructure.fireStructuredDataChangedEvent();
			//visualizer.fireVisualizerDataLoadedEvent();
		};
		
	/***********************************************************************
	 * Handling SX Events and event handlers
	 ***********************************************************************/
	 let handshakeEventHandler = function( dataPacket ){
 		visualizer.employer = dataPacket.sourcePortlet;
		
 		//console.log( 'handshake: ', visualizer );
		visualizer.fireVisualizerReadyEvent( true );
	}

	let loadDataEventHandler = function( dataPacket ){
		//console.log('loadDataEventHandler: ', dataPacket);
		if( dataPacket.payloadType === SX.Constants.PayloadType.DATA_STRUCTURE){
			let profile = dataPacket.profile ? dataPacket.profile : new Object(); 
			profile.resourceCommandURL = visualizer.resourceURL;
			dataStructure  = SX.newDataStructure(
					dataPacket.dataStructure, 
					profile,
					SX.Constants.FOR_EDITOR, 
					$('#<portlet:namespace/>canvasPanel') );
	
			let structuredData = dataPacket.structuredData;
			
			if( structuredData ){
				dataStructure.loadData( structuredData, 'JSON' );
			}
			//console.log( 'Editor structuredData: ', structuredData, dataStructure );
		}

		visualizer.loadCanvas( dataStructure );
	};
	
	let structuredDataChangedEventHandler = function( dataPacket ){
		//console.log('structuredDataChangedEventHandler: ', dataPacket );
		
		visualizer.fireVisualizerDataChangedEvent( dataPacket.payloadType, dataPacket.payload );
	}
	
	let requestDataEventHandler = function ( jsonData, params ){
		var eventData = {
				type_: SX.Constants.PathType.STRUCTURED_DATA,
				content_: dataType.structure()
		};
		visualizer.fireResponseDataEvent(eventData, params );
	};
	
	let responseDataEventHandler = function( data, params ){
		//console.log('[responseDataEventHandler]', data, params);
		
		switch( callbackParams.procFunc ){
		case 'readServerFile':
			visualizer.runProcFuncs( 'readServerFile', data, true );
			break;
		}
	};
	
	let initializeEventHandler = function( data, params ){
		//console.log('[initializeEventHandler] ');
		
		var initData = JSON.parse('<%=visualizerConfig.initData%>');
		initData.dataType_ = {
			name: dataType.name(),
			version:dataType.version()
		};
		
		processInitAction(initData, false);
	};
	
	/***********************************************************************
	 * Global variables and initialization section
	 ***********************************************************************/
	 let $canvas = $('#<portlet:namespace/>canvas');
	 let disabled = JSON.parse( '<%=visualizerConfig.disabled%>');
	 //let <portlet:namespace/>dataType = SX.createDataType();
	 let config = {
	 			namespace: '<portlet:namespace/>',
	 			displayCanvas: $('#<portlet:namespace/>canvas')[0],
	 			portletId: '<%=portletDisplay.getId()%>',
	 			employer: '<%=visualizerConfig.employer%>',
	 			displayOptions: JSON.parse('<%=visualizerConfig.menuOptions.toString()%>'),
	 			resourceURL: '<%=serveResourceURL%>',
	 			eventHandlers: {
	 					'SX_HANDSHAKE': handshakeEventHandler,
	 					'SX_LOAD_DATA': loadDataEventHandler,
	 					'SX_STRUCTURED_DATA_CHANGED': structuredDataChangedEventHandler
	 			},
	 			loadCanvas: loadData,
	 			procFuncs:{
	 				readServerFile: function( jsonData ){
	 					console.log('Custom function for readServerFile....');
	 				}
	 			},
	 			disabled: JSON.parse( '<%=visualizerConfig.disabled%>')
	 };
	 
	 
	 let visualizer = SX.createVisualizer(config);
	 //console.log( 'Visualizer: ', visualizer);
	 
	 let jsonDataStructure;
	 
	 if( JSON.parse('<%= hasDataPacket %>') ){
		 let dataPacket = JSON.parse('<%= strDataPacket %>');
		 if( dataPacket.payloadType === SX.Constants.PayloadType.DATA_STRUCTURE ){
			 jsonDataStructure = dataPacket.payload;
			 //console.log('initDataPacket: ', jsonDataStructure);
		 }
	 }
	 
 	let dataStructure = jsonDataStructure ? 
 					SX.newDataStructure(
 							jsonDataStructure,
 							{ resourceCommandURL: visualizer.resourceURL },
 							SX.Constants.FOR_EDITOR, 
							$('#<portlet:namespace/>canvasPanel')) 
					: undefined;

 	//console.log('dataStructure: ', dataStructure );
 	

	if( JSON.parse('<%= employed %>') ){
		if( dataStructure ){
			visualizer.loadCanvas( dataStructure );
		}
		visualizer.fireVisualizerReadyEvent(  true );
	}
	else{
		visualizer.fireVisualizerWaitingEvent( false );
	}
	/***********************************************************************
	 * Window Event binding functions 
	 ***********************************************************************/
	$('#<portlet:namespace/>sample').click(function(){
		if( disabled )
			return;
		visualizer.fireRequestSampleContentEvent();
	});
	$('#<portlet:namespace/>openLocalFile').click(function(){
		if( disabled )
			return;
		visualizer.openLocalFile( true );
	});
	$('#<portlet:namespace/>openServerFile').click(function(){
		if( disabled )
			return;
		visualizer.openServerFile(null, true);
	});
	
});
</script>