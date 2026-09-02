package com.kh.sajotuna.mds.admin.model.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;

public interface AdminProductService {

	List<CategoryDTO> getCategories();

	List<TagOptionDTO> getTags();

	// optionsJson: [{"optionName":"...","price":0,"stock":0}, ...] - 옵션 1개당 PRODUCTOPTION+OPTIONDETAIL 1건씩 만든다
	// tagsJson   : [{"tagName":"...","tagColor":"#RRGGBB"}, ...]
	void registerProduct(String productTitle, String productName, String optionsJson,
			Long categoryId, String productContent, String tagsJson, MultipartFile mainImage,
			List<MultipartFile> subImages, List<MultipartFile> descriptionImages);
}
