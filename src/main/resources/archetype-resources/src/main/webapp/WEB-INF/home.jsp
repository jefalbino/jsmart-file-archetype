<%@ taglib prefix="sm" uri="http://jsmartframework.com/v2/jsp/taglib/jsmart5" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>JSmart5 Framework - File Archetype</title>
    </head>

    <body class="container">

        <!-- Example of file upload and download -->

        <div class="col-md-6" style="margin-top: 50px;">

            <!-- Alert to provide response from WebBean -->
            <sm:alert id="feedback">
                <sm:header title="@{texts.file.archetype.feedback.alert}">
                    <sm:icon name="glyphicon-fire" />
                </sm:header>
                <!-- Message will be added via WebContext on HomeBean -->
                <div style="text-align: right;">
                    <sm:button label="I got it!" onClick="$('#feedback').alert('close');" />
                </div>
            </sm:alert>

            <!-- To upload file the form enctype must be multipart/form-data -->
            <sm:form enctype="multipart/form-data">

                <sm:output type="p" value="Choose file up to 1MB to upload to server for later download"
                        style="text-align: center;" />

                <sm:upload id="upload-id" label="@{texts.file.archetype.upload.label}" rightAddOn="upload-btn"
                        placeHolder="@{texts.file.archetype.upload.placeholder}" value="@{homeBean.filePart}">

                    <!-- Validate the maximum length of chose file -->
                    <sm:validate look="warning" text="@{texts.file.archetype.maximum.file.size}" maxLength="1000000" />

                    <!-- Tooltip to help the field meaning -->
                    <sm:tooltip title="Browser file to upload" side="bottom"/>

                    <!-- Button to send -->
                    <sm:button id="upload-btn" ajax="true" label="@{texts.file.archetype.button.label}"
                            action="@{homeBean.uploadFile}" update="download-list">

                        <!-- Glyphicon to be placed inside button -->
                        <sm:icon name="glyphicon-cloud-upload" />
                        <!-- Animated load will replace the icon during the request -->
                        <sm:load />
                    </sm:button>
                </sm:upload>

                <sm:progressgroup id="upload-status" onInterval="uploadStatus" interval="300">
                    <sm:progressbar value="0" look="success" minValue="0" maxValue="40" minWidth="2em" />
                    <sm:progressbar value="40" look="warning" minValue="40" maxValue="80"  striped="true" withLabel="true" />
                    <sm:progressbar value="80" look="danger" minValue="80" maxValue="100" />
                </sm:progressgroup>
            </sm:form>
        </div>

        <div class="col-md-6" style="margin-top: 50px;">

            <!-- List containing all files previously uploaded for download -->
            <sm:list id="download-list" values="@{homeBean.downloadListAdapter}" var="item"
                    scrollSize="10" maxHeight="300px;" scrollOffset="@{item.fileName}">

                <!-- Load to present loading when request is done to get more list items via scroll -->
                <sm:load type="h4" label=" Loading ..." />

                <!-- Template for create each list row -->
                <sm:row>
                    <!-- File name -->
                    <sm:header title="@{item.fileName}" />

                    <!-- Description of file size -->
                    <sm:text res="texts" key="file.archetype.file.size">
                        <sm:param name="file-size" value="@{item.fileSize}" />
                    </sm:text>

                    <!-- Icon to download file -->
                    <sm:link id="link-download" style="position: absolute; right: 0; top: 0;" label="Download"
                            outcome="/home?fileName=@{item.fileName}">
                        <sm:icon name="glyphicon-cloud-download" />
                        <sm:load />
                    </sm:link>
                </sm:row>

                <!-- Component to present content when list is empty -->
                <sm:empty style="color: #ddd; font-size: 18px; text-align: center;">
                    <sm:icon name="glyphicon-tasks" />
                    <sm:text res="texts" key="file.archetype.no.file" />
                </sm:empty>
            </sm:list>
        </div>

        <!-- Upload status functions -->
        <script type="text/javascript">

            <!-- Called every 300ms progress check interval -->
            function uploadStatus(progress, value) {

            }
        </script>
    </body>

</html>