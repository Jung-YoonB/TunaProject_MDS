package com.kh.sajotuna.mds.review.model.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImageDTO;

@Mapper
public interface ReviewMapper {

	// 주문 상세 번호로 DELIVERY_STATUS:DELIVERED (배송 완료 상태)인지 확인
	String checkDeliveryStatus(Long odId);
	
	// 리뷰 본문 등록
	int insertReview(ReviewDTO review);
	
	// 리뷰 이미지 추가
	int insertReviewImages(ReviewImageDTO reviewImage);
}
