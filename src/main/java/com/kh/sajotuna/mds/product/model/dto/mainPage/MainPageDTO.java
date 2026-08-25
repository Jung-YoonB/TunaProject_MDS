package com.kh.sajotuna.mds.product.model.dto.mainPage;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Setter
public class MainPageDTO {

	private List<BannerDTO> banner;
	private List<ProductListDTO> product;
	private List<CategoryDTO> category;
}
