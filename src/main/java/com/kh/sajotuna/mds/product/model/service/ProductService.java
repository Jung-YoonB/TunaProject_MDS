package com.kh.sajotuna.mds.product.model.service;

import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.Review.ReviewListDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;

import java.util.List;


public interface ProductService {
	
	MainPageDTO getList(SearchDTO search);
	
	DetailPageDTO detailPage(Long productId);

	List<ReviewListDTO> getReviewList(Long productId, Long memberId);

	String increaseReviewLike(Long reviewId, Long memberId);

	String getCoupons(Long memberId, Long couponId);
}
