package com.kh.sajotuna.mds.util;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import org.springframework.web.multipart.MultipartFile;

public class FileUploadUtil {

	private FileUploadUtil() {}

	// MultipartFile을 uploadDir(상대경로, 예: uploads/review)에 UUID 파일명으로 저장하고 저장된 파일명을 반환
	public static String saveFile(MultipartFile file, String uploadDir) throws IOException {
		String originalName = file.getOriginalFilename();
		String ext = "";
		if (originalName != null && originalName.contains(".")) {
			ext = originalName.substring(originalName.lastIndexOf('.'));
		}
		String saveName = UUID.randomUUID().toString() + ext;

		File dir = new File(uploadDir).getAbsoluteFile();
		if (!dir.exists()) {
			dir.mkdirs();
		}

		file.transferTo(new File(dir, saveName));

		return saveName;
	}
}
