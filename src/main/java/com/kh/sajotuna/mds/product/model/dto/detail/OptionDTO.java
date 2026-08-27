package com.kh.sajotuna.mds.product.model.dto.detail;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class OptionDTO {
	private Long optionId;
	private String optionName;
	private int price;
	private Long popId;
	private int stock;
}
