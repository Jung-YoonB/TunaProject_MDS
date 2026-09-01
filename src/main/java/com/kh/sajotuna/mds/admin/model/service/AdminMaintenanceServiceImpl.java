package com.kh.sajotuna.mds.admin.model.service;

import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.kh.sajotuna.mds.admin.model.dto.FileIntegrityIssueDTO;
import com.kh.sajotuna.mds.admin.model.mapper.AdminMaintenanceMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminMaintenanceServiceImpl implements AdminMaintenanceService {

	private static final String CATEGORY_PRODUCT = "product";
	private static final String CATEGORY_REVIEW = "review";

	private final AdminMaintenanceMapper mapper;

	@Value("${file.upload-dir.product}")
	private String productUploadDir;

	@Value("${file.upload-dir.review}")
	private String reviewUploadDir;

	@Override
	public List<FileIntegrityIssueDTO> checkFileIntegrity() {
		List<FileIntegrityIssueDTO> issues = new ArrayList<>();
		issues.addAll(compare(CATEGORY_PRODUCT, productUploadDir, mapper.selectAllProductImageSaveNames()));
		issues.addAll(compare(CATEGORY_REVIEW, reviewUploadDir, mapper.selectAllReviewImageSaveNames()));
		return issues;
	}

	// 디스크에 실제로 있는 파일명 집합과 DB가 참조하는 파일명 집합을 서로 대조.
	// 디스크에만 있으면 ORPHAN_FILE(삭제 가능), DB에만 있으면 MISSING_FILE(파일이 사라진 것 - 삭제 불가, 확인 필요)
	private List<FileIntegrityIssueDTO> compare(String category, String uploadDir, List<String> dbFileNames) {
		List<FileIntegrityIssueDTO> issues = new ArrayList<>();

		Set<String> dbSet = new HashSet<>(dbFileNames);
		Set<String> diskSet = listFileNames(uploadDir);

		for (String fileName : diskSet) {
			if (!dbSet.contains(fileName)) {
				issues.add(new FileIntegrityIssueDTO("ORPHAN_FILE", category, fileName));
			}
		}
		for (String fileName : dbSet) {
			if (!diskSet.contains(fileName)) {
				issues.add(new FileIntegrityIssueDTO("MISSING_FILE", category, fileName));
			}
		}
		return issues;
	}

	private Set<String> listFileNames(String uploadDir) {
		Set<String> names = new HashSet<>();
		File dir = new File(uploadDir).getAbsoluteFile();
		File[] files = dir.listFiles();
		if (files == null) {
			return names;
		}
		for (File file : files) {
			if (file.isFile()) {
				names.add(file.getName());
			}
		}
		return names;
	}

	@Override
	public void deleteOrphanFile(String category, String fileName) {
		String uploadDir = resolveUploadDir(category);

		// 경로 순회 방지 - 파일명에 구분자/상위 디렉터리 참조가 섞여 들어올 수 없게 함
		if (fileName == null || fileName.isBlank()
				|| fileName.contains("/") || fileName.contains("\\") || fileName.contains("..")) {
			throw new IllegalStateException("올바르지 않은 파일명입니다.");
		}

		// 검사 시점과 삭제 버튼 클릭 시점 사이에 그 파일이 실제로 등록됐을 수도 있으니, 지우기 직전에 다시 확인
		List<String> dbFileNames = CATEGORY_PRODUCT.equals(category)
				? mapper.selectAllProductImageSaveNames()
				: mapper.selectAllReviewImageSaveNames();
		if (dbFileNames.contains(fileName)) {
			throw new IllegalStateException("이미 DB에 등록된 파일이라 삭제할 수 없습니다. 목록을 새로고침해 주세요.");
		}

		File target = new File(new File(uploadDir).getAbsoluteFile(), fileName);
		if (target.exists() && !target.delete()) {
			throw new IllegalStateException("파일 삭제에 실패했습니다.");
		}
	}

	private String resolveUploadDir(String category) {
		if (CATEGORY_PRODUCT.equals(category)) {
			return productUploadDir;
		}
		if (CATEGORY_REVIEW.equals(category)) {
			return reviewUploadDir;
		}
		throw new IllegalStateException("올바르지 않은 카테고리입니다.");
	}
}
