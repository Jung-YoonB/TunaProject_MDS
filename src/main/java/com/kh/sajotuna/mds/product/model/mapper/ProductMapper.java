package com.kh.sajotuna.mds.product.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.kh.sajotuna.mds.product.model.dto.detail.OptionDTO;
import com.kh.sajotuna.mds.product.model.dto.detail.ProductDetailDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.BannerDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.CategoryDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.ProductListDTO;

@Mapper
public interface ProductMapper {

	List<ProductListDTO> getList();
	
	List<BannerDTO> bannerList();
	List<CategoryDTO> categoryList();
	
	ProductDetailDTO productDetail(Long productId);
	String getThumbnail(Long productId);
	List<String> getImages (Long productId);
	
	List<OptionDTO> getOptionList(Long productId);
}
