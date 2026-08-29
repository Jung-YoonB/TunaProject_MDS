package com.kh.sajotuna.mds.admin.model.service;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.admin.model.dto.CategoryOptionDTO;
import com.kh.sajotuna.mds.admin.model.dto.ProductImageInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.ProductInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.ProductOptionInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.admin.model.mapper.AdminProductMapper;
import com.kh.sajotuna.mds.util.FileUploadUtil;

import lombok.RequiredArgsConstructor;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

@Service
@RequiredArgsConstructor
public class AdminProductServiceImpl implements AdminProductService {

	private static final String IMAGE_URL_PREFIX = "/uploads/product/";
	private static final int TITLE_IMAGE_MAIN = 0;
	private static final int TITLE_IMAGE_SUB = 1;
	private static final int TITLE_IMAGE_DESCRIPTION = 2;

	private final AdminProductMapper mapper;
	private final ObjectMapper objectMapper;

	@Value("${file.upload-dir.product}")
	private String uploadDir;

	@Override
	public List<CategoryOptionDTO> getCategories() {
		return mapper.selectAllCategories();
	}

	@Override
	public List<TagOptionDTO> getTags() {
		return mapper.selectAllTags();
	}

	@Override
	@Transactional
	public void registerProduct(String productName, int price, int stock, Long categoryId, String productContent,
			String tagsJson, MultipartFile mainImage, List<MultipartFile> subImages,
			List<MultipartFile> descriptionImages) {

		if (mainImage == null || mainImage.isEmpty()) {
			throw new IllegalStateException("대표 이미지는 필수입니다.");
		}
		// PRODUCT_TITLE/PRODUCT_NAME/PRODUCT_CONTENT는 NOT NULL 컬럼이고, Oracle은 빈 문자열을 NULL로
		// 취급하므로 여기서 막지 않으면 DB 제약조건 위반(ORA-01400)이 그대로 노출된다
		if (productName == null || productName.isBlank()) {
			throw new IllegalStateException("상품명은 필수입니다.");
		}
		if (productContent == null || productContent.isBlank()) {
			throw new IllegalStateException("상품 설명은 필수입니다.");
		}

		ProductInsertDTO product = new ProductInsertDTO();
		product.setProductName(productName);
		product.setProductContent(productContent);
		mapper.insertProduct(product);

		ProductOptionInsertDTO option = new ProductOptionInsertDTO();
		option.setOptionName(productName);
		option.setPrice(price);
		option.setStock(stock);
		mapper.insertProductOption(option);
		mapper.insertOptionDetail(product.getProductId(), option.getOptionId());

		if (categoryId != null) {
			mapper.insertCategoryDetail(product.getProductId(), categoryId);
		}

		saveImage(product.getProductId(), mainImage, TITLE_IMAGE_MAIN);
		saveImages(product.getProductId(), subImages, TITLE_IMAGE_SUB);
		saveImages(product.getProductId(), descriptionImages, TITLE_IMAGE_DESCRIPTION);

		registerTags(product.getProductId(), tagsJson);
	}

	private void saveImages(Long productId, List<MultipartFile> files, int titleImageType) {
		if (files == null) {
			return;
		}
		for (MultipartFile file : files) {
			saveImage(productId, file, titleImageType);
		}
	}

	private void saveImage(Long productId, MultipartFile file, int titleImageType) {
		if (file == null || file.isEmpty()) {
			return;
		}

		String saveName;
		try {
			saveName = FileUploadUtil.saveFile(file, uploadDir);
		} catch (IOException e) {
			throw new IllegalStateException("이미지 업로드에 실패했습니다.", e);
		}

		ProductImageInsertDTO image = new ProductImageInsertDTO();
		image.setProductId(productId);
		image.setOriginalName(file.getOriginalFilename());
		image.setSaveName(saveName);
		image.setPath(IMAGE_URL_PREFIX);
		image.setTitleImageType(titleImageType);
		mapper.insertProductImage(image);
	}

	private void registerTags(Long productId, String tagsJson) {
		if (tagsJson == null || tagsJson.isBlank()) {
			return;
		}

		List<TagOptionDTO> tags;
		try {
			tags = List.of(objectMapper.readValue(tagsJson, TagOptionDTO[].class));
		} catch (JacksonException e) {
			throw new IllegalStateException("태그 정보가 올바르지 않습니다.", e);
		}

		for (TagOptionDTO tag : tags) {
			if (tag.getTagName() == null || tag.getTagName().isBlank()) {
				continue;
			}

			TagOptionDTO existing = mapper.findTagByName(tag.getTagName());
			Long tagId;
			if (existing != null) {
				tagId = existing.getTagId();
			} else {
				TagOptionDTO newTag = new TagOptionDTO();
				newTag.setTagName(tag.getTagName());
				newTag.setTagColor(tag.getTagColor());
				mapper.insertTag(newTag);
				tagId = newTag.getTagId();
			}
			mapper.insertTagDetail(productId, tagId);
		}
	}
}
