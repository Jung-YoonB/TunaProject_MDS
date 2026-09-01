package com.kh.sajotuna.mds.product.model.dto.mainPage;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Alias("CategoryDTO")
public class CategoryDTO {
	private String categoryName;

	// CATEGORY.CATEGORY_ID - 관리자 상품 등록 화면(admin.AdminProductService)의 카테고리
	// 드롭다운이 값으로 쓰기 위해 추가. 원래 admin 쪽에 별도 CategoryOptionDTO가 있었는데
	// 같은 CATEGORY 테이블을 참조하는 DTO라 이쪽으로 합침(ReviewDTO와 동일한 방식)
	private Long categoryId;
}
