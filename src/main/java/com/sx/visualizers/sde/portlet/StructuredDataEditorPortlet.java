package com.sx.visualizers.sde.portlet;

import com.liferay.document.library.kernel.service.DLAppService;
import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONException;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.constant.StationXConstants;
import com.sx.constant.StationXWebKeys;
import com.sx.debug.Debug;
import com.sx.icecap.constant.IcecapDataTypeAttributes;
import com.sx.icecap.constant.IcecapWebKeys;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;
import com.sx.icecap.service.StructuredDataLocalService;
import com.sx.visualizers.sde.constants.StructuredDataEditorPortletKeys;

import java.io.IOException;
import java.util.List;
import java.util.Set;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

/**
 * @author jerry
 */
@Component(
		configurationPid = "com.sx.visualizers.sde.configuration.StructuredDataEditorConfiguration",
		immediate = true,
		property = {
			"com.liferay.portlet.add-default-resource=true",
			"com.liferay.portlet.display-category=category.station-x-visualizers",
			"com.liferay.portlet.header-portlet-css=/css/main.css",
			"com.liferay.portlet.instanceable=true",
			"javax.portlet.display-name=Structured Data Editor",
			"javax.portlet.init-param.template-path=/",
			"javax.portlet.init-param.view-template=/html/visualizer-wrapper.jsp",
			"javax.portlet.init-param.config-template=/html/configuration.jsp",
			"javax.portlet.name=" + StructuredDataEditorPortletKeys.STRUCTURED_DATA_EDITOR,
			"javax.portlet.resource-bundle=content.Language",
			"javax.portlet.security-role-ref=power-user,user,guest"
		},
		service = Portlet.class
)
public class StructuredDataEditorPortlet extends MVCPortlet {

	@Reference
	DataTypeLocalService _dataTypeLocalService;
	
	@Override
	public void doView(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		
Debug.printHeader("StructuredDataEditorPortlet");
		
		String strDataPacket = ParamUtil.getString(renderRequest, "dataPacket", "");

		System.out.println("visualizer controller dataPacket: " + strDataPacket );
		
		if( !strDataPacket.isEmpty() ) {
			try {
				JSONObject dataPacket = JSONFactoryUtil.createJSONObject(strDataPacket);
				renderRequest.setAttribute(StationXWebKeys.DATA_PACKET, dataPacket);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		
		/*
		try {
			if( dataTypeId > 0 && structuredDataId > 0 ) {
				jsonDataStructure = _dataTypeLocalService.getStructuredDataWithValues(dataTypeId, structuredDataId);
				renderRequest.setAttribute(StationXWebKeys.CMD, StationXConstants.CMD_UPDATE);
			}
			else if( dataTypeId > 0 && structuredDataId == 0 ) {
				jsonDataStructure = _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId);
				renderRequest.setAttribute(StationXWebKeys.CMD, StationXConstants.CMD_ADD);
			}
		} catch( JSONException e ) {
			throw new PortletException( e.getMessage() );
		}

		renderRequest.setAttribute(IcecapWebKeys.STRUCTURED_DATA_JSON_OBJECT, jsonDataStructure);
		*/
		super.doView(renderRequest, renderResponse);
	}

	@Override
	public void doConfig(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		// TODO Auto-generated method stub
		super.doConfig(renderRequest, renderResponse);
	}
}