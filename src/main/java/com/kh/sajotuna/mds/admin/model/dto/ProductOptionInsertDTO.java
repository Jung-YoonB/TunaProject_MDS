package com.kh.sajotuna.mds.admin.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// addProduct.jsp엔 옵션 개념이 없어, 등록되는 상품마다 이 "기본 옵션" 1개에 가격/재고를 담는다
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias("ProductOptionInsertDTO")
public class ProductOptionInsertDTO {
	private Long optionId;
	private String optionName;
	private int price;
	private int stock;
}
