package com.kh.sajotuna.mds.product.model.service;

import java.util.ArrayList;
import java.util.List;

import com.kh.sajotuna.mds.product.model.dto.detail.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;
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
	public MainPageDTO getList() {
		
		List<ProductListDTO> list = mapper.getList();
		List<BannerDTO> bannerList = mapper.bannerList();
		List<CategoryDTO> categoryList = mapper.categoryList();
		MainPageDTO dto = new MainPageDTO(bannerList, list, categoryList);
		System.out.println("product list:: " + list.toString());
		System.out.println("banner list :: " + bannerList.toString());
		
		return dto;
	}

	@Override
	public DetailPageDTO detailPage(Long productId) {
		
		System.out.println("productId :: " + productId);
		ProductDetailDTO dto = mapper.productDetail(productId);
		String thumbnail = mapper.getThumbnail(productId);
		List<String> images = mapper.getImages(productId);
		dto.setThumbnail(thumbnail);
		dto.setImage(images);
		System.out.println("service detail :: " + dto.toString());
		List<OptionDTO> optionList = mapper.getOptionList(productId);
		for(OptionDTO o : optionList) {
			o.setPrice(o.getPrice() - dto.getPrice());
		}
		DetailPageDTO result = new DetailPageDTO(dto, optionList);
		return result;
	}

	@Override
	public List<ReviewDTO> getReviewList(Long productId) {

		List<ReviewDTO> reviewList = mapper.getReviewList(productId);
		List<Long> reviewIds = new ArrayList<>();
		List<ReviewImagesDTO> images = new  ArrayList<>();

		for(ReviewDTO review : reviewList) {
			reviewIds.add(review.getReviewId());
		}
		List<ReviewImagesDTO> reviewImages = mapper.getReviewImages(reviewIds);

		for(ReviewDTO review : reviewList) {
			for(ReviewImagesDTO image : reviewImages) {
				if(review.getReviewId() == image.getReviewId()) {
					images.add(image);
				}
			}
			review.setReviewImages(images);
		}
		return  reviewList;
	}
}
