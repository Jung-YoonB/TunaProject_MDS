package com.kh.sajotuna.mds.product.model.service;

import com.kh.sajotuna.mds.product.model.dto.detail.DetailPageDTO;
import com.kh.sajotuna.mds.product.model.dto.mainPage.MainPageDTO;


public interface ProductService {
	
	MainPageDTO getList();
	
	DetailPageDTO detailPage(Long productId);
}
