package com.kh.sajotuna.mds.admin.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.admin.model.dto.CategoryOptionDTO;
import com.kh.sajotuna.mds.admin.model.dto.ProductImageInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.ProductInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.ProductOptionInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;

@Mapper
public interface AdminProductMapper {

	// 상품 등록 폼 렌더링용
	List<CategoryOptionDTO> selectAllCategories();

	List<TagOptionDTO> selectAllTags();

	// 상품 본문 등록
	int insertProduct(ProductInsertDTO product);

	// 기본 옵션(가격/재고) 등록 + 상품-옵션 연결
	int insertProductOption(ProductOptionInsertDTO option);

	int insertOptionDetail(@Param("productId") Long productId, @Param("optionId") Long optionId);

	int insertCategoryDetail(@Param("productId") Long productId, @Param("categoryId") Long categoryId);

	int insertProductImage(ProductImageInsertDTO image);

	// 태그 find-or-create
	TagOptionDTO findTagByName(String tagName);

	int insertTag(TagOptionDTO tag);

	int insertTagDetail(@Param("productId") Long productId, @Param("tagId") Long tagId);
}
