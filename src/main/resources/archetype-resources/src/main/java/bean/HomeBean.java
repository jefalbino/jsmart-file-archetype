package ${package}.bean;

import com.jsmart5.framework.adapter.ListAdapter;
import com.jsmart5.framework.annotation.PreSubmit;
import com.jsmart5.framework.annotation.QueryParam;
import com.jsmart5.framework.util.WebText;
import com.jsmart5.framework.manager.WebContext;
import com.jsmart5.framework.annotation.WebBean;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.util.*;
import javax.annotation.PostConstruct;
import javax.servlet.http.Part;

import ${package}.adapter.Adapter;
import ${package}.service.SpringService;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;

@WebBean
public class HomeBean {

    private static final Map<String, Adapter> fileMap = new TreeMap<>();

    @Autowired
    private SpringService springService;

    @QueryParam(name = "fileName")
    private String fileName;

    private Part filePart;

    private DownloadListAdapter downloadListAdapter;

    @PostConstruct
    public void init() {
        downloadListAdapter = new DownloadListAdapter();

        // Download file case id is specified on URL
        if (!StringUtils.isBlank(fileName)) {
            downloadFile(fileName);
        }
    }

    @PreSubmit(forAction = "uploadFile")
    public boolean preUploadFile() {
        boolean validated = true;

        if (filePart == null || StringUtils.isBlank(filePart.getSubmittedFileName())) {
            WebContext.addWarning("feedback", WebText.getString("texts", "file.archetype.file.error"));
            validated = false;
        }
        return validated;
    }

    public void uploadFile() {
        try {
            File file = File.createTempFile(filePart.getSubmittedFileName(), null);

            Adapter adapter = new Adapter();
            adapter.setFileName(filePart.getSubmittedFileName());
            adapter.setFileSize(filePart.getSize());
            adapter.setFileLocation(file.getAbsolutePath());

            if (file.exists()) {
                file.delete();
            }
            try (ReadableByteChannel rbc = Channels.newChannel(filePart.getInputStream());
                 FileOutputStream fos = new FileOutputStream(file)) {
                fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
                fos.flush();
            }

            fileMap.put(adapter.getFileName(), adapter);

        } catch (IOException e) {
            WebContext.addWarning("feedback", WebText.getString("texts", "file.archetype.file.write.error",
                    filePart.getSubmittedFileName()));
        }
    }

    public void downloadFile(String fileName) {
        Adapter adapter = fileMap.get(fileName);
        if (adapter == null) {
            WebContext.addWarning("feedback", WebText.getString("texts", "file.archetype.file.no.exist", fileName));
            return;
        }

        File file = new File(adapter.getFileLocation());
        if (!file.exists()) {
            WebContext.addWarning("feedback", WebText.getString("texts", "file.archetype.file.no.exist", fileName));
            return;
        }

        try {
            WebContext.writeResponseAsFileStream(file, 2048);
        } catch (Exception e) {
            WebContext.addWarning("feedback", WebText.getString("texts", "file.archetype.file.read.error", fileName));
        }
    }

    public Part getFilePart() {
        return filePart;
    }

    public void setFilePart(Part filePart) {
        this.filePart = filePart;
    }

    public DownloadListAdapter getDownloadListAdapter() {
        return downloadListAdapter;
    }

    private class DownloadListAdapter extends ListAdapter<Adapter> {

        @Override
        public List<Adapter> load(final int offsetIndex, final Object offset, final int size) {
            if (fileMap.isEmpty()) {
                return Collections.EMPTY_LIST;
            }

            List<Adapter> adapterList = new ArrayList<>(fileMap.values());

            if (offsetIndex + size <= adapterList.size()) {
                return adapterList.subList(offsetIndex, offsetIndex + size);
            } else {
                return adapterList.subList(offsetIndex, adapterList.size());
            }
        }
    }
}

