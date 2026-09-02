package com.kh.sajotuna.mds.product.model.service;

import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.MemberGradeDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import java.util.List;


public interface ProductService {
	
	MainPageDTO getList(Long memberId);

	DetailPageDTO detailPage(Long productId, Long memberId);

	// 로그인 회원의 등급/할인율 - 상품 상세 페이지의 "등급 할인" 표시용(비로그인이면 호출하지 않음)
	MemberGradeDTO getMemberGrade(Long memberId);

	List<ReviewDTO> getReviewList(Long productId, Long memberId, int page);

	String increaseReviewLike(Long reviewId, Long memberId);

	String getCoupons(Long memberId, Long couponId);
	int totalReviewPages(Long memberId);

	int totalPages(SearchDTO searchDTO);

	List<ProductListDTO> getSearchList(SearchDTO search, int page, Long memberId);

	// 검색 화면 카테고리/태그 칩 목록
	List<CategoryDTO> getCategories();

	List<TagOptionDTO> getTags();

	// 배너용 상품 대표 이미지(최근 등록순 최대 5장). 메인은 MainPageDTO로 함께 받지만
	// 검색 화면은 사이드바 배너만 필요해서 따로 꺼내 쓴다.
	List<BannerDTO> getBanners();
}
