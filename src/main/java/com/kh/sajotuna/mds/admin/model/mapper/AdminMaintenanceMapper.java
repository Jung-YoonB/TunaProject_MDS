package com.kh.sajotuna.mds.admin.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AdminMaintenanceMapper {

	// 파일 정합성 검사용 - PRODUCTIMAGE/REVIEWIMAGE에 저장된 파일명 전체 목록
	List<String> selectAllProductImageSaveNames();

	List<String> selectAllReviewImageSaveNames();
}
