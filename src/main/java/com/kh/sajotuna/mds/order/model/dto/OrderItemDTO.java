package com.kh.sajotuna.mds.order.model.dto;

import org.apache.ibatis.type.Alias;

@Alias("OrderItemDTO")
public class OrderItemDTO {

	private Long popId;
	private Long qty;
}
