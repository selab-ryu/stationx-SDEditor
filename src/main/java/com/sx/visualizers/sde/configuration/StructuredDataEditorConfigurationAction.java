package com.sx.visualizers.sde.configuration;

import com.liferay.portal.configuration.metatype.bnd.util.ConfigurableUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.ConfigurationAction;
import com.liferay.portal.kernel.portlet.DefaultConfigurationAction;
import com.liferay.portal.kernel.util.ParamUtil;
import com.sx.visualizers.sde.constants.StructuredDataEditorPortletKeys;

import java.util.Map;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.ConfigurationPolicy;
import org.osgi.service.component.annotations.Modified;

import aQute.bnd.annotation.metatype.Configurable;

@Component(
        configurationPid = "com.sx.visualizers.sde.configuration.StructuredDataEditorConfiguration",
        configurationPolicy = ConfigurationPolicy.OPTIONAL, 
        immediate = true,
        property = {
            "javax.portlet.name="+StructuredDataEditorPortletKeys.STRUCTURED_DATA_EDITOR
        },
        service = ConfigurationAction.class
    )
public class StructuredDataEditorConfigurationAction extends DefaultConfigurationAction {
	@Override
	public void include(	PortletConfig portletConfig, 
											HttpServletRequest httpServletRequest,
											HttpServletResponse httpServletResponse) throws Exception {

		httpServletRequest.setAttribute(StructuredDataEditorConfiguration.class.getName(), _structuredDataEditorConfiguration);

		super.include(portletConfig, httpServletRequest, httpServletResponse);
    }

	@Override
	public void processAction(
											PortletConfig portletConfig, 
											ActionRequest actionRequest, 
											ActionResponse actionResponse) throws Exception {

		String city = ParamUtil.getString(actionRequest, "city");
		String unit = ParamUtil.getString(actionRequest, "unit");  



		setPreference(actionRequest, "city", city);
		setPreference(actionRequest, "unit", unit);


		super.processAction(portletConfig, actionRequest, actionResponse);
    }

    /**
     * 
     * (1)If a method is annoted with @Activate then the method will be called at the time of activation of the component
     *  so that we can perform initialization task
     *  
     * (2) This class is annoted with @Component where we have used configurationPid with id com.proliferay.configuration.DemoConfiguration
     * So if we modify any configuration then this method will be called. 
     */
    @Activate
    @Modified
    protected void activate(Map<Object, Object> properties) {
        _log.info("#####Calling activate() method######");
        
        //_structuredDataEditorConfiguration = Configurable.createConfigurable(StructuredDataEditorConfiguration.class, properties);
        _structuredDataEditorConfiguration = ConfigurableUtil.createConfigurable(StructuredDataEditorConfiguration.class, properties);
    }

    private static final Log _log = LogFactoryUtil.getLog(StructuredDataEditorConfigurationAction.class);

    private volatile StructuredDataEditorConfiguration _structuredDataEditorConfiguration;  
}
