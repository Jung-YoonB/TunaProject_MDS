package com.kh.sajotuna.mds.admin.model.service;

import java.util.List;

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
import com.kh.sajotuna.mds.util.ImageValidationUtil;

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

	// Content-Type 헤더는 요청자가 임의로 바꿔 보낼 수 있어 신뢰할 수 없으므로,
	// 실제 파일 시그니처(매직 바이트)까지 확인하는 ImageValidationUtil로 검사
	private void checkImageType(MultipartFile file) {
		if (!ImageValidationUtil.isAllowedImage(file)) {
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

		// 파일명만 미리 생성해서 DB엔 즉시 반영하고, 실제 디스크 쓰기는 트랜잭션 커밋 후로 미룬다.
		// 등록 도중 뒤쪽 단계(태그 파싱 등)에서 실패해도, 이미 써진 이미지 파일이 롤백된 상품에
		// orphan으로 남는 일이 없도록 하기 위함(DB 롤백은 파일 시스템엔 적용 안 되는 문제의 근본 해결)
		String saveName = FileUploadUtil.generateSaveName(file);
		FileUploadUtil.saveOnCommit(file, uploadDir, saveName);

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
