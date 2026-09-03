package com.kh.sajotuna.mds.product.model.service;

import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.coupon.model.CouponDTO;
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

	// 발급 가능한(유효기간 남은) 쿠폰 중 이 회원이 아직 안 받은 것을 전부 발급한다. 반환값은 새로 발급된 개수.
	int issueAllCoupons(Long memberId);

	// "쿠폰 받기" 모달에 보여줄 목록 - 지금 이 회원이 새로 받을 수 있는 쿠폰만.
	List<CouponDTO> getIssuableCoupons(Long memberId);
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
