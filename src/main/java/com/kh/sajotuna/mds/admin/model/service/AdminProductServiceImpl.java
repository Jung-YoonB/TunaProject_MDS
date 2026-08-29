package com.kh.sajotuna.mds.admin.model.service;

import java.io.IOException;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.admin.model.dto.ProductImageInsertDTO;
import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.admin.model.mapper.AdminProductMapper;
import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;
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

	// 화면 안내 문구(JPG/PNG/WEBP)와 동일한 기준으로 서버에서도 실제 업로드되는 파일 종류를 제한
	private static final Set<String> ALLOWED_IMAGE_CONTENT_TYPES = Set.of("image/jpeg", "image/png", "image/webp");

	private final AdminProductMapper mapper;
	private final ObjectMapper objectMapper;

	@Value("${file.upload-dir.product}")
	private String uploadDir;

	@Override
	public List<CategoryDTO> getCategories() {
		return mapper.selectAllCategories();
	}

	@Override
	public List<TagOptionDTO> getTags() {
		return mapper.selectAllTags();
	}

	@Override
	@Transactional
	public void registerProduct(String productTitle, String productName, String optionName, int price, int stock,
			Long categoryId, String productContent, String tagsJson, MultipartFile mainImage,
			List<MultipartFile> subImages, List<MultipartFile> descriptionImages) {

		if (mainImage == null || mainImage.isEmpty()) {
			throw new IllegalStateException("대표 이미지는 필수입니다.");
		}
		if (descriptionImages == null || descriptionImages.stream().allMatch(MultipartFile::isEmpty)) {
			throw new IllegalStateException("설명 이미지는 최소 1장 이상 등록해야 합니다.");
		}
		// PRODUCT_TITLE/PRODUCT_NAME/PRODUCT_CONTENT/OPTION_NAME은 NOT NULL 컬럼이고, Oracle은 빈 문자열을 NULL로
		// 취급하므로 여기서 막지 않으면 DB 제약조건 위반(ORA-01400)이 그대로 노출된다
		requireNonBlank(productTitle, "상품 게시글 제목은 필수입니다.");
		requireNonBlank(productName, "상품명은 필수입니다.");
		requireNonBlank(optionName, "옵션명은 필수입니다.");
		requireNonBlank(productContent, "상품 설명은 필수입니다.");
		if (price < 0) {
			throw new IllegalStateException("판매가격은 0 이상이어야 합니다.");
		}
		if (stock < 0) {
			throw new IllegalStateException("재고는 0 이상이어야 합니다.");
		}
		if (categoryId == null) {
			throw new IllegalStateException("카테고리를 선택해 주세요.");
		}

		// 실제로 디스크에 쓰기 전에 전부 검사해서, 뒤쪽 이미지가 부적합할 때
		// 앞쪽 이미지만 파일로 남는(트랜잭션 롤백은 DB에만 적용되고 파일엔 안 적용됨) 상황을 방지
		checkImageType(mainImage);
		checkImageTypes(subImages);
		checkImageTypes(descriptionImages);

		ProductDetailDTO product = new ProductDetailDTO();
		product.setProductTitle(productTitle);
		product.setProductName(productName);
		product.setProductContent(productContent);
		mapper.insertProduct(product);

		OptionDTO option = new OptionDTO();
		option.setOptionName(optionName);
		option.setPrice(price);
		option.setStock(stock);
		mapper.insertProductOption(option);
		mapper.insertOptionDetail(product.getProductId(), option.getOptionId());

		mapper.insertCategoryDetail(product.getProductId(), categoryId);

		saveImage(product.getProductId(), mainImage, TITLE_IMAGE_MAIN);
		saveImages(product.getProductId(), subImages, TITLE_IMAGE_SUB);
		saveImages(product.getProductId(), descriptionImages, TITLE_IMAGE_DESCRIPTION);

		registerTags(product.getProductId(), tagsJson);
	}

	private void requireNonBlank(String value, String message) {
		if (value == null || value.isBlank()) {
			throw new IllegalStateException(message);
		}
	}

	private void checkImageTypes(List<MultipartFile> files) {
		if (files == null) {
			return;
		}
		for (MultipartFile file : files) {
			checkImageType(file);
		}
	}

	private void checkImageType(MultipartFile file) {
		if (file == null || file.isEmpty()) {
			return;
		}
		String contentType = file.getContentType();
		if (contentType == null || !ALLOWED_IMAGE_CONTENT_TYPES.contains(contentType)) {
			throw new IllegalStateException("이미지는 JPG, PNG, WEBP 파일만 등록할 수 있습니다.");
		}
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
