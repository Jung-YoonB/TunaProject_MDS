package com.kh.sajotuna.mds.admin.model.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.admin.model.dto.CategoryOptionDTO;
import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;

public interface AdminProductService {

	List<CategoryOptionDTO> getCategories();

	List<TagOptionDTO> getTags();

	// tagsJson: [{"tagName":"...","tagColor":"#RRGGBB"}, ...] 형태의 JSON 문자열
	void registerProduct(String productName, int price, int stock, Long categoryId, String productContent,
			String tagsJson, MultipartFile mainImage, List<MultipartFile> subImages,
			List<MultipartFile> descriptionImages);
}
