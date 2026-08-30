package com.kh.sajotuna.mds.admin.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// 상품 등록 폼의 태그 선택 목록 조회 + 신규 태그 생성(find-or-create) 양쪽에 사용
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias("TagOptionDTO")
public class TagOptionDTO {
	private Long tagId;
	private String tagName;
	private String tagColor;
}
