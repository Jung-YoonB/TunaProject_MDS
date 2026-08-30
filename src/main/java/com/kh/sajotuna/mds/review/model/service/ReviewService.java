package com.kh.sajotuna.mds.review.model.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.review.model.dto.ReviewWriteInfoDTO;

public interface ReviewService {

	// 리뷰 작성 화면에 보여줄 상품/옵션/가격/썸네일 조회 + 작성 가능 여부 검증
	ReviewWriteInfoDTO getWriteInfo(Long odId, Long memberId);

	// 리뷰 등록 (본문 + 사진)
	void writeReview(Long memberId, Long odId, int score, String reviewText, List<MultipartFile> images);
}
