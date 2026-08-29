package com.kh.sajotuna.mds.review.model.service;

import java.io.IOException;
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

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

	private static final int MAX_IMAGE_COUNT = 5;
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

		if (images != null && images.size() > MAX_IMAGE_COUNT) {
			throw new IllegalStateException("사진은 최대 " + MAX_IMAGE_COUNT + "장까지 첨부할 수 있습니다.");
		}

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

			String saveName;
			try {
				saveName = FileUploadUtil.saveFile(file, uploadDir);
			} catch (IOException e) {
				throw new IllegalStateException("사진 업로드에 실패했습니다.", e);
			}

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
}
