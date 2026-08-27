package com.kh.sajotuna.mds.product.model.service;

import java.util.List;

import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;


public interface ProductService {
	
	MainPageDTO getList();
	
	DetailPageDTO detailPage(Long productId);

	List<ReviewDTO> getReviewList(Long productId, Long memberId);

	String increaseReviewLike(Long reviewId, Long memberId);

	String getCoupons(Long memberId, Long couponId);
}
