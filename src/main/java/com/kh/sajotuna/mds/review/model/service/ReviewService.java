package com.kh.sajotuna.mds.review.model.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewWriteInfoDTO;

public interface ReviewService {

	// 리뷰 작성 화면에 보여줄 상품/옵션/가격/썸네일 조회 + 작성 가능 여부 검증
	ReviewWriteInfoDTO getWriteInfo(Long odId, Long memberId);

	// 리뷰 등록 (본문 + 사진)
	void writeReview(Long memberId, Long odId, int score, String reviewText, List<MultipartFile> images);

	// 마이페이지 "내가 쓴 리뷰" 목록 조회 (페이징)
	List<ReviewDTO> listMyReviews(Long memberId, int page);

	// 위 조회 조건의 전체 페이지 수
	int totalMyReviewPages(Long memberId);

	// 리뷰 삭제 (본인 소유 확인 포함)
	void deleteReview(Long reviewId, Long memberId);
}
