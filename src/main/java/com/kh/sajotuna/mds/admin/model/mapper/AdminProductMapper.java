package com.kh.sajotuna.mds.admin.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.admin.model.dto.ProductImageInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;

@Mapper
public interface AdminProductMapper {

	// 상품 등록 폼 렌더링용
	List<CategoryDTO> selectAllCategories();

	List<TagOptionDTO> selectAllTags();

	// 상품 본문 등록 (PRODUCT 테이블 - product.model.dto.detail.ProductDetailDTO와 공용)
	int insertProduct(ProductDetailDTO product);

	// 옵션(가격/재고) 1건 등록 + 상품-옵션 연결. 상품 하나에 옵션이 여러 개면 이 둘을 반복 호출한다
	// (PRODUCTOPTION 테이블 - product.model.dto.detail.OptionDTO와 공용)
	int insertProductOption(OptionDTO option);

	int insertOptionDetail(@Param("productId") Long productId, @Param("optionId") Long optionId);

	int insertCategoryDetail(@Param("productId") Long productId, @Param("categoryId") Long categoryId);

	int insertProductImage(ProductImageInsertDTO image);

	// 태그 find-or-create
	TagOptionDTO findTagByName(String tagName);

	int insertTag(TagOptionDTO tag);

	int insertTagDetail(@Param("productId") Long productId, @Param("tagId") Long tagId);
}
