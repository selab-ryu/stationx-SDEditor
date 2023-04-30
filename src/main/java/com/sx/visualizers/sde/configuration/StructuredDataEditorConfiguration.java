package com.sx.visualizers.sde.configuration;

import aQute.bnd.annotation.metatype.Meta;

@Meta.OCD(  
        id = "com.sx.visualizers.sde.configuration.StructuredDataEditorConfiguration"
    )
public interface StructuredDataEditorConfiguration {
	@Meta.AD(required = false)
    public String city();

    @Meta.AD(required = false)
    public String temperatureUnit();
}
