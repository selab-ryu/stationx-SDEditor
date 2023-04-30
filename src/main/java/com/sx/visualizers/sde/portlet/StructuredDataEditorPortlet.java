package com.sx.visualizers.sde.portlet;

import com.sx.visualizers.sde.constants.StructuredDataEditorPortletKeys;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import javax.portlet.Portlet;

import org.osgi.service.component.annotations.Component;

/**
 * @author jerry
 */
@Component(
		configurationPid = "com.sx.visualizers.sde.configuration.StructuredDataEditorConfiguration",
		immediate = true,
		property = {
			"com.liferay.portlet.display-category=category.station-x-visualizers",
			"com.liferay.portlet.header-portlet-css=/css/main.css",
			"com.liferay.portlet.instanceable=true",
			"javax.portlet.display-name=StructuredDataEditor",
			"javax.portlet.init-param.template-path=/html/SDE/",
			"javax.portlet.init-param.view-template=/html/SDE/visualizer-wrapper.jsp",
			"javax.portlet.init-param.config-template=/html/SDE/configuration.jsp",
			"javax.portlet.name=" + StructuredDataEditorPortletKeys.STRUCTURED_DATA_EDITOR,
			"javax.portlet.resource-bundle=content.Language",
			"javax.portlet.security-role-ref=power-user,user"
		},
		service = Portlet.class
)
public class StructuredDataEditorPortlet extends MVCPortlet {
}