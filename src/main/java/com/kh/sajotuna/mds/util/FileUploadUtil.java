package com.kh.sajotuna.mds.util;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.multipart.MultipartFile;

public class FileUploadUtil {

	private FileUploadUtil() {}

	// 파일명만 미리 생성(디스크에는 아직 안 씀) - DB insert에 저장 파일명을 먼저 넣어야 할 때 사용
	public static String generateSaveName(MultipartFile file) {
		String originalName = file.getOriginalFilename();
		String ext = "";
		if (originalName != null && originalName.contains(".")) {
			ext = originalName.substring(originalName.lastIndexOf('.'));
		}
		return UUID.randomUUID().toString() + ext;
	}

	// MultipartFile을 uploadDir(상대경로, 예: uploads/review)에 saveName으로 즉시 저장
	public static void writeToDisk(MultipartFile file, String uploadDir, String saveName) throws IOException {
		File dir = new File(uploadDir).getAbsoluteFile();
		if (!dir.exists()) {
			dir.mkdirs();
		}
		file.transferTo(new File(dir, saveName));
	}

	// DB 트랜잭션이 커밋된 뒤에만 실제로 디스크에 씀 - 트랜잭션이 롤백되면 이 파일은 아예 안 써짐.
	// 등록 흐름 중간에 실패해도 이미 써진 이미지 파일이 orphan으로 남는 문제를 원천 차단하기 위함.
	// 트랜잭션 밖에서 호출되면(원래는 없어야 함) 안전장치로 즉시 저장한다.
	public static void saveOnCommit(MultipartFile file, String uploadDir, String saveName) {
		if (!TransactionSynchronizationManager.isSynchronizationActive()) {
			writeQuietly(file, uploadDir, saveName);
			return;
		}

		TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
			@Override
			public void afterCommit() {
				writeQuietly(file, uploadDir, saveName);
			}
		});
	}

	// 커밋 이후 시점이라 실패해도 DB를 되돌릴 방법이 없음(이미 커밋 완료) - 로그만 남김.
	// 이런 경우(DB엔 있는데 파일은 없는 상태)를 잡아내는 게 관리자 화면의 "파일 정합성 검사" 기능의 역할
	private static void writeQuietly(MultipartFile file, String uploadDir, String saveName) {
		try {
			writeToDisk(file, uploadDir, saveName);
		} catch (IOException e) {
			System.err.println("[FileUploadUtil] 커밋 후 파일 저장 실패: " + uploadDir + "/" + saveName + " - " + e.getMessage());
		}
	}
}
