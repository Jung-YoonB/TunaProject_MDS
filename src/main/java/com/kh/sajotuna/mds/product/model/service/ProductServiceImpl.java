package com.kh.sajotuna.mds.product.model.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.kh.sajotuna.mds.product.model.dto.ProductListDTO;
import com.kh.sajotuna.mds.product.model.mapper.ProductMapper;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService{
	private final ProductMapper mapper;
	
	@Override
	public List<ProductListDTO> getList() {
		
		List<ProductListDTO> list = mapper.getList();
		
		System.out.println("product list:: " + list.toString());
		return list;
	}

	
}
