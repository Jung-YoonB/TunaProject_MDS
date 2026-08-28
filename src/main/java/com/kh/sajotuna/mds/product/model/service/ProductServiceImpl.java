package com.kh.sajotuna.mds.product.model.service;

import java.util.ArrayList;
import java.util.List;

import com.kh.sajotuna.mds.product.model.dto.mainPage.SearchDTO;
import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.Review.ReviewDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.Review.ReviewImagesDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;
import com.kh.sajotuna.mds.product.model.mapper.ProductMapper;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService{
	private final ProductMapper mapper;
	
	@Override
	public MainPageDTO getList(SearchDTO search) {
		
		List<ProductListDTO> list = mapper.getList(search);
		List<BannerDTO> bannerList = mapper.bannerList();
		MainPageDTO dto = new MainPageDTO(list, bannerList);
		System.out.println("product list:: " + list.toString());
		System.out.println("banner list :: " + bannerList.toString());
		
		return dto;
	}

	@Override
	public DetailPageDTO detailPage(Long productId) {
		ProductDetailDTO dto = mapper.productDetail(productId);
		String thumbnail = mapper.getThumbnail(productId);

		List<String> images = mapper.getImages(productId);
		List<String> detailContents = mapper.getDetailContents(productId);
		List<CouponDTO> coupons = mapper.getCoupons();

		dto.setThumbnail(thumbnail);
		dto.setImage(images);
		dto.setDetailContents(detailContents);
		System.out.println("service detail :: " + dto);
		List<OptionDTO> optionList = mapper.getOptionList(productId);
		for(OptionDTO o : optionList) {
			o.setPrice(o.getPrice() - dto.getPrice());
		}
		return new DetailPageDTO(dto, optionList, coupons);
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
	public List<ReviewDTO> getReviewList(Long productId, Long memberId) {

		List<ReviewDTO> reviewList = mapper.getReviewList(productId, memberId);
		List<Long> reviewIds = new ArrayList<>();
		List<ReviewImagesDTO> images = new  ArrayList<>();

		for(ReviewDTO review : reviewList) {
			reviewIds.add(review.getReviewId());
		}
		List<ReviewImagesDTO> reviewImages = mapper.getReviewImages(reviewIds);

		for(ReviewDTO review : reviewList) {
			for(ReviewImagesDTO image : reviewImages) {
				if(review.getReviewId().equals(image.getReviewId())) {
					images.add(image);
				}
			}
			review.setReviewImages(images);
		}
		return  reviewList;
	}

	@Override
	public String increaseReviewLike(Long reviewId, Long memberId) {
		//좋아요 올라가고, 중간테이블 추가하고 끝?
		if(memberId == null) {
			return "not member";
		}
		int increase = 0;
		if(mapper.checkLike(reviewId, memberId) == null) {
			 increase += mapper.updateLikeCount(reviewId);
			increase+= mapper.insertReviewLike(reviewId, memberId);
		}else {
			mapper.updateLikeDiscount(reviewId);
			mapper.deleteReviewLike(reviewId, memberId);
		}
		if (increase > 0) {
			return  "on";
		}else {
			return  "off";
		}
	}
}
