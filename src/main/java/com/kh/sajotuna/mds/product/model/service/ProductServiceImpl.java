package com.kh.sajotuna.mds.product.model.service;

import com.kh.sajotuna.mds.admin.model.dto.TagOptionDTO;
import com.kh.sajotuna.mds.coupon.model.CouponDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.MemberGradeDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.product.model.mapper.ProductMapper;
import com.kh.sajotuna.mds.review.model.dto.ReviewDTO;
import com.kh.sajotuna.mds.review.model.dto.ReviewImagesDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService{
	private final ProductMapper mapper;

	// 페이지 크기는 화면마다 다르므로 용도별로 나눠 둔다(MemberServiceImpl의 COUPON/DELIVERY_PAGE_SIZE,
	// ReviewServiceImpl의 MY_REVIEWS_PAGE_SIZE와 같은 방식).
	// 상품 상세에 붙는 리뷰: 한 번에 5개
	private static final int REVIEWS_PAGE_SIZE = 5;
	// 검색 결과 상품: 한 페이지 20개
	private static final int SEARCH_PAGE_SIZE = 20;
	// 메인 화면 상품 목록은 페이징하지 않는다. 0을 넘기면 product.xml이 OFFSET/FETCH를 붙이지 않는다.
	private static final int NO_PAGING = 0;

	@Override
	public MainPageDTO getList(Long memberId) {
		SearchDTO searchDTO = new SearchDTO();
		List<ProductListDTO> list = mapper.getList(searchDTO, 0, NO_PAGING, memberId);
		List<BannerDTO> bannerList = mapper.bannerList();
		MainPageDTO dto = new MainPageDTO(list, bannerList);
		System.out.println("product list:: " + list.toString());
		System.out.println("banner list :: " + bannerList.toString());

		return dto;
	}

	@Override
	public DetailPageDTO detailPage(Long productId, Long memberId) {
		ProductDetailDTO dto = mapper.productDetail(productId, memberId);
		// 없는 상품 번호로 들어오면(주소창 직접 입력 등) 여기서 null이라 아래 setThumbnail에서
		// NPE -> 500 페이지가 떴다. 호출부가 "없음"을 판단할 수 있게 null로 돌려준다.
		if (dto == null) {
			return null;
		}
		String thumbnail = mapper.getThumbnail(productId);

		List<String> images = mapper.getImages(productId);
		List<String> detailContents = mapper.getDetailContents(productId);
		List<CouponDTO> coupons = mapper.getCoupons();

		dto.setThumbnail(thumbnail);
		dto.setImage(images);
		dto.setDetailContents(detailContents);
		System.out.println("service detail :: " + dto);
		List<OptionDTO> optionList = mapper.getOptionList(productId);
		return new DetailPageDTO(dto, optionList, coupons);
	}

	@Override
	public MemberGradeDTO getMemberGrade(Long memberId) {
		return mapper.getMemberGrade(memberId);
	}

	@Override
	public String getCoupons(Long memberId, Long couponId ) {
		int check = mapper.couponCheck(memberId, couponId);
		if(check != 0) {
			return "이미 등록된 쿠폰입니다.";
		}
		int getCoupon = mapper.insertCoupon(memberId, couponId);
		if(getCoupon != 0) {
			return "쿠폰이 등록되었습니다.";
		}else {
			return "쿠폰 등록에 실패했습니다.";
		}

	}
	@Override
	public int totalReviewPages(Long productId) {
		int totalCount = mapper.countReviews(productId);
		return Math.max(1, (int) Math.ceil((double) totalCount / REVIEWS_PAGE_SIZE));
	}

	@Override
	public List<ReviewDTO> getReviewList(Long productId, Long memberId, int page) {
		int safePage = Math.max(page, 1);
		int offset = (safePage - 1) * REVIEWS_PAGE_SIZE;

		List<ReviewDTO> reviewList = mapper.getReviewList(productId, memberId, offset, REVIEWS_PAGE_SIZE);
		List<Long> reviewIds = new ArrayList<>();

		for(ReviewDTO review : reviewList) {
			reviewIds.add(review.getReviewId());
		}

//		 리뷰가 아예 없으면 쿼리 에러 방지를 위해 곧바로 빈 리스트 리턴
		if (reviewIds.isEmpty()) {
			return reviewList;
		}
		List<ReviewImagesDTO> reviewImages = mapper.getReviewImages(reviewIds);

		for(ReviewDTO review : reviewList) {
			List<ReviewImagesDTO> images = new ArrayList<>();
			for(ReviewImagesDTO image : reviewImages) {
				if(review.getReviewId().equals(image.getReviewId())) {
					images.add(image);
				}
			}
			review.setReviewImages(images);
		}
		return reviewList;
	}

	@Override
	public String increaseReviewLike(Long reviewId, Long memberId) {
		//좋아요 올라가고, 중간테이블 추가하고 끝?
		if(memberId == null) {
			return "not member";
		}
		int increase = 0;
		if(mapper.checkLike(reviewId, memberId) == null) {
			increase+= mapper.insertReviewLike(reviewId, memberId);
		}else {
			mapper.deleteReviewLike(reviewId, memberId);
		}
		if (increase > 0) {
			return  "on";
		}else {
			return  "off";
		}
	}

	@Override
	public int totalPages(SearchDTO searchDTO) {
		int totalCount = mapper.countSearchProducts(searchDTO);
		return Math.max(1, (int) Math.ceil((double) totalCount / SEARCH_PAGE_SIZE));
	}


	@Override
	public List<ProductListDTO> getSearchList(SearchDTO search, int page, Long memberId) {
		int safePage = Math.max(page, 1);
		int offset = (safePage - 1) * SEARCH_PAGE_SIZE;
		List<ProductListDTO> list = mapper.getList(search, offset, SEARCH_PAGE_SIZE, memberId);
		System.out.println("search list :: " + list);
		return list;
	}

	@Override
	public List<CategoryDTO> getCategories() {
		return mapper.selectAllCategories();
	}

	@Override
	public List<TagOptionDTO> getTags() {
		return mapper.selectAllTags();
	}

	@Override
	public List<BannerDTO> getBanners() {
		return mapper.bannerList();
	}
}
