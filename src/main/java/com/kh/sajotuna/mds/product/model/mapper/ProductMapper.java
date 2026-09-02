package com.kh.sajotuna.mds.product.model.mapper;

import java.util.List;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImagesDTO;
import org.apache.ibatis.annotations.Mapper;

import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.MemberGradeDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProductMapper {
	//상품 리스트
	List<ProductListDTO> getList(@Param("search")SearchDTO search,  @Param("offset")int offset, @Param("pageSize") int pageSize, @Param("memberId") Long memberId);

	List<BannerDTO> bannerList();

	// 검색 화면 카테고리/태그 칩. AdminProductMapper에도 같은 쿼리가 있지만 admin 화면 전용 매퍼라
	// 사용자 화면에서 끌어다 쓰면 도메인이 얽혀서 여기에 따로 둔다.
	List<CategoryDTO> selectAllCategories();

	// TagOptionDTO는 admin 패키지에 있지만, CategoryDTO처럼 product 쪽으로 옮기지 않고 그대로 쓴다
	// - admin 담당자가 지금 그 패키지에서 작업 중이라 이동시키면 충돌난다. 정리는 그 작업이 끝난 뒤에.
	List<TagOptionDTO> selectAllTags();

	//상품 상세 페이지
	ProductDetailDTO productDetail(@Param("productId") Long productId, @Param("memberId") Long memberId);
	String getThumbnail(Long productId);
	List<String> getImages (Long productId);
	List<String> getDetailContents (Long productId);
	List<CouponDTO> getCoupons();
	MemberGradeDTO getMemberGrade(Long memberId);

	//쿠폰
	List<OptionDTO> getOptionList(Long productId);
	int couponCheck(@Param("memberId") Long memberId, @Param("couponId") Long couponId);
	int insertCoupon(@Param("memberId") Long memberId, @Param("couponId") Long couponId);

	//리뷰 관련
	List<ReviewDTO> getReviewList(@Param("productId") Long productId, @Param("memberId") Long memberId,
								  @Param("offset")int offset, @Param("pageSize") int pageSize);
	List<ReviewImagesDTO> getReviewImages(List<Long> reviewId);

	int insertReviewLike(@Param("reviewId") Long reviewId,  @Param("memberId") Long memberId);
	void deleteReviewLike(@Param("reviewId") Long reviewId, @Param("memberId") Long memberId);
	Long checkLike(@Param("reviewId") Long reviewId,  @Param("memberId") Long memberId);
	int countReviews(@Param("productId") Long productId);

	int countSearchProducts(SearchDTO searchDto);
}
