package com.kh.sajotuna.mds.admin.model.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;

public interface AdminProductService {

	List<CategoryDTO> getCategories();

	List<TagOptionDTO> getTags();

	// tagsJson: [{"tagName":"...","tagColor":"#RRGGBB"}, ...] 형태의 JSON 문자열
	void registerProduct(String productTitle, String productName, String optionName, int price, int stock,
			Long categoryId, String productContent, String tagsJson, MultipartFile mainImage,
			List<MultipartFile> subImages, List<MultipartFile> descriptionImages);
}
