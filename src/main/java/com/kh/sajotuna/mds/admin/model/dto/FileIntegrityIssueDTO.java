package com.kh.sajotuna.mds.admin.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// uploads 디렉터리와 DB(PRODUCTIMAGE/REVIEWIMAGE)를 대조해서 나온 불일치 1건.
// MyBatis 쿼리 결과가 아니라 AdminMaintenanceServiceImpl에서 디스크/DB 목록을 비교해 직접 조립함
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FileIntegrityIssueDTO {
	private String issueType; // "ORPHAN_FILE"(파일만 있음, 삭제 가능) | "MISSING_FILE"(DB만 있음, 삭제 불가)
	private String category; // "product" | "review"
	private String fileName;
}
