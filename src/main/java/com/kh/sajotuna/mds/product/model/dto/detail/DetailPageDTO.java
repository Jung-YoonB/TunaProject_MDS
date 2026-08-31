package com.kh.sajotuna.mds.product.model.dto.detail;

import java.util.List;
import org.apache.ibatis.type.Alias;
import com.kh.sajotuna.mds.product.model.dto.coupon.CouponDTO;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;


@Setter
@Getter
@ToString
@AllArgsConstructor
@Alias("DetailPageDTO")
public class DetailPageDTO {

	private ProductDetailDTO product;
	private List<OptionDTO> option;
	private List<CouponDTO> coupon;
}
