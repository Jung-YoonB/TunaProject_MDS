package com.kh.sajotuna.mds.review.model.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImagesDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewWriteInfoDTO;
import com.kh.sajotuna.mds.review.model.mapper.ReviewMapper;
import com.kh.sajotuna.mds.util.FileUploadUtil;
import com.kh.sajotuna.mds.util.ImageValidationUtil;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

	private static final int MAX_IMAGE_COUNT = 5;
	private static final int MAX_REVIEW_TEXT_LENGTH = 500;
	private static final String IMAGE_URL_PREFIX = "/uploads/review/";

	private final ReviewMapper mapper;

	@Value("${file.upload-dir.review}")
	private String uploadDir;

	@Override
	public ReviewWriteInfoDTO getWriteInfo(Long odId, Long memberId) {
		ReviewWriteInfoDTO info = mapper.getReviewWriteInfo(odId, memberId);
		if (info == null) {
			throw new IllegalStateException("잘못된 접근입니다.");
		}

		String deliveryStatus = mapper.checkDeliveryStatus(odId);
		if (!"DELIVERED".equals(deliveryStatus)) {
			throw new IllegalStateException("배송이 완료된 상품만 리뷰를 작성할 수 있습니다.");
		}

		if (mapper.checkReviewExists(memberId, odId) > 0) {
			throw new IllegalStateException("이미 리뷰를 작성한 주문입니다.");
		}

		return info;
	}

	@Override
	@Transactional
	public void writeReview(Long memberId, Long odId, int score, String reviewText, List<MultipartFile> images) {
		// 등록 직전 재검증 (소유자/배송상태/중복작성)
		getWriteInfo(odId, memberId);

		// REVIEW_TEXT는 VARCHAR2(1500 BYTE)라 한글(3바이트)만 있어도 500자까지는 안전하게 들어가지만,
		// 그 이상은 DB 제약 위반(ORA-12899)이 그대로 노출될 수 있어 글자 수 기준으로 서버에서도 확인
		if (reviewText != null && reviewText.length() > MAX_REVIEW_TEXT_LENGTH) {
			throw new IllegalStateException("리뷰 내용은 " + MAX_REVIEW_TEXT_LENGTH + "자 이내로 입력해 주세요.");
		}

		if (images != null && images.size() > MAX_IMAGE_COUNT) {
			throw new IllegalStateException("사진은 최대 " + MAX_IMAGE_COUNT + "장까지 첨부할 수 있습니다.");
		}
		checkImageTypes(images);

		ReviewDTO review = new ReviewDTO();
		review.setMemberId(memberId);
		review.setOdId(odId);
		review.setScore(score);
		review.setReviewText(reviewText);
		mapper.insertReview(review);

		if (images == null) {
			return;
		}

		boolean isFirstImage = true;
		for (MultipartFile file : images) {
			if (file == null || file.isEmpty()) {
				continue;
			}

			// 파일명만 미리 생성해서 DB엔 즉시 반영하고, 실제 디스크 쓰기는 트랜잭션 커밋 후로 미룬다.
			// (admin 상품 등록과 동일한 방식 - orphan 파일 방지)
			String saveName = FileUploadUtil.generateSaveName(file);
			FileUploadUtil.saveOnCommit(file, uploadDir, saveName);

			ReviewImagesDTO image = new ReviewImagesDTO();
			image.setReviewId(review.getReviewId());
			image.setReviewImageOriginalName(file.getOriginalFilename());
			image.setReviewImage(saveName);
			image.setReviewImagePath(IMAGE_URL_PREFIX);
			// 가장 먼저 첨부된 사진을 대표(0)로, 나머지는 서브(1)로 저장
			image.setReviewTitleImage(isFirstImage ? 0 : 1);
			mapper.insertReviewImages(image);

			isFirstImage = false;
		}
	}

	// Content-Type 헤더는 요청자가 임의로 바꿔 보낼 수 있어 신뢰할 수 없으므로,
	// 실제 파일 시그니처(매직 바이트)까지 확인하는 ImageValidationUtil로 검사 (admin 상품 등록과 동일한 방식)
	private void checkImageTypes(List<MultipartFile> files) {
		if (files == null) {
			return;
		}
		for (MultipartFile file : files) {
			if (!ImageValidationUtil.isAllowedImage(file)) {
				throw new IllegalStateException("이미지는 JPG, PNG, WEBP 파일만 등록할 수 있습니다.");
			}
		}
	}
}
