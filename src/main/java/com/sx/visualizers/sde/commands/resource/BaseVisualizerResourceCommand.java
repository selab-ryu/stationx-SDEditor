package com.sx.visualizers.sde.commands.resource;

import com.liferay.document.library.kernel.model.DLFileEntry;
import com.liferay.document.library.kernel.model.DLFolder;
import com.liferay.document.library.kernel.model.DLFolderConstants;
import com.liferay.document.library.kernel.service.DLAppService;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.upload.FileItem;
import com.liferay.portal.kernel.upload.UploadRequest;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.debug.Debug;
import com.sx.icecap.constant.IcecapDataTypeAttributes;
import com.sx.icecap.constant.IcecapSSSTermAttributes;
import com.sx.icecap.constant.IcecapWebKeys;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;
import com.sx.visualizers.sde.constants.SDEMVCCommands;
import com.sx.visualizers.sde.constants.StructuredDataEditorPortletKeys;

import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + StructuredDataEditorPortletKeys.STRUCTURED_DATA_EDITOR,
	        "mvc.command.name="+SDEMVCCommands.RESOURSE_COMMAND
	    },
	    service = MVCResourceCommand.class
)
public class BaseVisualizerResourceCommand extends BaseMVCResourceCommand {
	private static long DEFAULT_PARENT_FOLDER_ID = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	
	@Reference
	DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	DLAppService _dlAppService;

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		Debug.printHeader("BaseVisualizerResourceCommand");
		
		String cmd = ParamUtil.getString(resourceRequest, "command", "");
		
		long dataTypeId = ParamUtil.getLong(resourceRequest, IcecapDataTypeAttributes.DATATYPE_ID, 0);
		long structuredDataId = ParamUtil.getLong(resourceRequest, IcecapWebKeys.STRUCTURED_DATA_ID,  0);
		
		String dataTypeName = ParamUtil.getString(resourceRequest, IcecapDataTypeAttributes.DATATYPE_NAME);
		String dataTypeVersion = ParamUtil.getString(resourceRequest, IcecapDataTypeAttributes.DATATYPE_VERSION);
		String termName = ParamUtil.getString(resourceRequest, IcecapSSSTermAttributes.TERM_NAME, "");
		String termVersion = ParamUtil.getString(resourceRequest, IcecapSSSTermAttributes.TERM_VERSION, "");
		String dataContent = ParamUtil.getString(resourceRequest, IcecapWebKeys.STRUCTURED_DATA, "");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);

		JSONObject response = JSONFactoryUtil.createJSONObject();
		
		System.out.println("cmd: " + cmd  );
		System.out.println("dataTypeId: " + dataTypeId  );
		System.out.println("structuredDataId: " + structuredDataId  );
		System.out.println("dataTypeName: " + dataTypeName  );
		System.out.println("dataTypeVersion: " + dataTypeVersion  );
		System.out.println("termName: " + termName  );
		System.out.println("termVersion: " + termVersion  );
		System.out.println("dataContent: " + dataContent  );
		
		response.put( "cmd", cmd);
		int result = 0; //means success

		if( cmd.equalsIgnoreCase("UPLOAD_DATA_FILE")) {
			StructuredData structuredData = null; 
			if( structuredDataId < 1 ) {
				ServiceContext dataSC = ServiceContextFactory.getInstance(StructuredData.class.getName(), resourceRequest);
				structuredData = _dataTypeLocalService.addStructuredData(
								dataTypeId, 
								dataTypeId, 
								dataContent, 
								WorkflowConstants.STATUS_APPROVED,
								dataSC);
				
				structuredDataId = structuredData.getStructuredDataId();
				
			}
			response.put( "structuredDataId", structuredDataId );

			UploadRequest uploadRequest = PortalUtil.getUploadPortletRequest(resourceRequest);
			Map<String, FileItem[]> uploadFileMap= uploadRequest.getMultipartParameterMap();
			Set<Entry<String, FileItem[]>> entrySet = uploadFileMap.entrySet();
			
			for( Entry<String, FileItem[]> fileEntry : entrySet ){
				FileItem item[] = fileEntry.getValue();
				if( item.length == 0 ) {
					continue;
				}
				
				ServiceContext dlFolderSC = ServiceContextFactory.getInstance( DLFolder.class.getName(), resourceRequest );
				long dataFileFolderId = _dataTypeLocalService.getDataFileFolderId(
						themeDisplay.getScopeGroupId(),
						DEFAULT_PARENT_FOLDER_ID,
						dataTypeName,
						dataTypeVersion,
						structuredDataId,
						termName,
						termVersion,
						dlFolderSC,
						true);
				
				JSONObject jsonFiles = JSONFactoryUtil.createJSONObject();
				FileItem[] fileItems = fileEntry.getValue();
				for( FileItem fileItem : fileItems ) {
					if( fileItem.getSize() == 0 ) {
						continue;
					}
					
					String title = fileItem.getFileName();
					
					InputStream inputStream = fileItem.getInputStream();
					String description = "";
					long repositoryId = themeDisplay.getScopeGroupId();
					String mimeType = fileItem.getContentType();
					
					JSONObject jsonFile = JSONFactoryUtil.createJSONObject();
					try {
						ServiceContext fileServiceContext = ServiceContextFactory.getInstance( DLFileEntry.class.getName(), resourceRequest );
						FileEntry addedFile = _dlAppService.addFileEntry(repositoryId, dataFileFolderId, title, mimeType, title, description, "", inputStream, fileItem.getSize(), fileServiceContext);
						
						jsonFile.put( "parentFolderId", dataFileFolderId );
						jsonFile.put( "fileId", addedFile.getFileEntryId() );
						jsonFile.put( "name", addedFile.getFileName() );
						jsonFile.put( "type", addedFile.getMimeType() );
						jsonFile.put( "size", addedFile.getSize() );
						
						jsonFiles.put( addedFile.getFileName(), jsonFile );
					} catch( PortalException e ) {
						result = 2; // means duplicated
						
						FileEntry dupFile = _dlAppService.getFileEntry(themeDisplay.getScopeGroupId(), dataFileFolderId, title);
						jsonFile.put( "parentFolderId", dataFileFolderId );
						jsonFile.put( "name", dupFile.getFileName() );
						jsonFile.put( "fileId", dupFile.getFileEntryId() );
						jsonFile.put( "type", dupFile.getMimeType() );
						jsonFile.put( "size", dupFile.getSize() );
						
						/*
						System.out.println("parentFolderId: " + dataFileFolderId );
						System.out.println("name: " + dupFile.getFileName() );
						System.out.println("fileId: " + dupFile.getFileEntryId() );
						System.out.println("type: " + dupFile.getMimeType() );
						System.out.println("size: " + dupFile.getSize() );
						*/
						
						jsonFiles.put( dupFile.getFileName(), jsonFile );
						
						response.put( "message", e.getMessage() );
					} catch( SystemException e ) {
						result = 1;
						response.put( "message",  e.getMessage() );
					}
					
					if( result == 1 ) {
						break;
					}
				}
				
				response.put(fileEntry.getKey(), jsonFiles);
				
				if( result == 1 ) {
					break;
				}
			}
			
			response.put( "result", result );
		}
		else if( cmd.equalsIgnoreCase("DELETE_DATA_FILE")) {
			String fileName = ParamUtil.getString(resourceRequest, "fileName", "");
			long fileEntryId = ParamUtil.getLong(resourceRequest, "fileId", 0);
			
			response.put("fileName", fileName );
			response.put("fileId", fileEntryId );
			
			try {
				FileEntry fileEntry = _dlAppService.getFileEntry(fileEntryId);
				_dlAppService.deleteFileEntry(fileEntryId);
				
				response.put("result", 0);
				response.put("message", "success");
				System.out.println( response.toString(4));
			} catch( PortalException e) {
				response.put("result", 1);
				response.put("message", e.getMessage() );
			}
		}

		PrintWriter pw = resourceResponse.getWriter();
		pw.write(response.toString());
		pw.flush();
		pw.close();
	}
}
