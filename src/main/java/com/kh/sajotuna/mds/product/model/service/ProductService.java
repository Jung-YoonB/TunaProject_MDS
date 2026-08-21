package com.kh.sajotuna.mds.product.model.service;

import java.util.List;
import com.kh.sajotuna.mds.product.model.dto.ProductListDTO;


public interface ProductService {
	
	List<ProductListDTO> getList();
}
