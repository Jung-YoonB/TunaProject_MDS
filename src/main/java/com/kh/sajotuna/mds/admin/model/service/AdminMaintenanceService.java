package com.kh.sajotuna.mds.admin.model.service;

import java.util.List;

import com.kh.sajotuna.mds.admin.model.dto.FileIntegrityIssueDTO;

public interface AdminMaintenanceService {

	// uploads/product, uploads/review 디렉터리를 DB(PRODUCTIMAGE/REVIEWIMAGE)와 대조해서 불일치 목록 반환
	List<FileIntegrityIssueDTO> checkFileIntegrity();

	// orphan 파일(DB에 참조가 없는 파일)만 삭제 가능 - DB에 남아있는 파일은 이 메서드로 지울 수 없음
	void deleteOrphanFile(String category, String fileName);
}
