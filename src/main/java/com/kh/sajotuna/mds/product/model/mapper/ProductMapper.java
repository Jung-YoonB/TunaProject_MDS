package com.kh.sajotuna.mds.product.model.mapper;

import java.util.List;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImagesDTO;
import org.apache.ibatis.annotations.Mapper;

import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProductMapper {
	//상품 리스트
	List<ProductListDTO> getList(SearchDTO search);
	
	List<BannerDTO> bannerList();

	//상품 상세 페이지
	ProductDetailDTO productDetail(Long productId);
	String getThumbnail(Long productId);
	List<String> getImages (Long productId);
	List<String> getDetailContents (Long productId);
	List<CouponDTO> getCoupons();

	//쿠폰
	List<OptionDTO> getOptionList(Long productId);
	int couponCheck(@Param("memberId") Long memberId, @Param("couponId") Long couponId);
	int insertCoupon(@Param("memberId") Long memberId, @Param("couponId") Long couponId);

	//리뷰 관련
	List<ReviewDTO> getReviewList(@Param("productId") Long productId, @Param("memberId") Long memberId);
	List<ReviewImagesDTO> getReviewImages(List<Long> reviewId);

	int insertReviewLike(@Param("reviewId") Long reviewId,  @Param("memberId") Long memberId);
	void deleteReviewLike(@Param("reviewId") Long reviewId, @Param("memberId") Long memberId);
	Long checkLike(@Param("reviewId") Long reviewId,  @Param("memberId") Long memberId);
}
