package com.kh.sajotuna.mds.product.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.kh.sajotuna.mds.product.model.dto.ProductListDTO;

@Mapper
public interface ProductMapper {

	List<ProductListDTO> getList();
}
