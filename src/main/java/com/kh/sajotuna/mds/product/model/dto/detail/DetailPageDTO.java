package com.kh.sajotuna.mds.product.model.dto.detail;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Setter
@Getter
@ToString
@AllArgsConstructor
public class DetailPageDTO {

	private ProductDetailDTO product;
	private List<OptionDTO> option;
}
