package com.sx.visualizers.sde.commands.render;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.trash.TrashHelper;
import com.sx.constant.StationXPortletKeys;
import com.sx.icecap.constant.IcecapMVCCommands;
import com.sx.icecap.constant.IcecapWebPortletKeys;
import com.sx.icecap.service.DataTypeLocalService;
import com.sx.icecap.constant.IcecapConstants;
import com.sx.icecap.constant.IcecapSSSTermAttributes;
import com.sx.constant.StationXWebKeys;
import com.sx.visualizers.sde.constants.SDEMVCCommands;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + StationXPortletKeys.STRUCTURED_DATA_EDITOR,
	        "mvc.command.name="+SDEMVCCommands.RENDER_EDITOR
	    },
	    service = MVCRenderCommand.class
)
public class SDERenderCommand implements MVCRenderCommand {
	
	@Reference(unbind = "-")
	protected void setTrashHelper(TrashHelper trashHelper) {
	  _trashHelper = trashHelper;
	}
	protected TrashHelper _trashHelper;
	
	@Reference
	protected DataTypeLocalService _dataTypeLocalService;

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		long dataTypeId = ParamUtil.getLong(renderRequest, IcecapSSSTermAttributes.DATA_TYPE_ID);
		
		return null;
	}

}
