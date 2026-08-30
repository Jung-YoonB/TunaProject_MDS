package com.kh.sajotuna.mds.review.model.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImagesDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewWriteInfoDTO;

@Mapper
public interface ReviewMapper {

	// 주문 상세 번호로 DELIVERY_STATUS:DELIVERED (배송 완료 상태)인지 확인
	String checkDeliveryStatus(Long odId);

	// 리뷰 작성 화면에 보여줄 상품/옵션/가격/썸네일 조회 (odId가 해당 memberId 소유일 때만 조회됨)
	ReviewWriteInfoDTO getReviewWriteInfo(@Param("odId") Long odId, @Param("memberId") Long memberId);

	// 해당 주문상세에 이미 리뷰가 작성됐는지 확인
	int checkReviewExists(@Param("memberId") Long memberId, @Param("odId") Long odId);

	// 리뷰 본문 등록
	int insertReview(ReviewDTO review);

	// 리뷰 이미지 추가
	int insertReviewImages(ReviewImagesDTO reviewImages);
}
