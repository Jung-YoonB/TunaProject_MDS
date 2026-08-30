package com.kh.sajotuna.mds.admin.model.dto;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Alias("AdminOrderSummaryDTO")
public class AdminOrderSummaryDTO {
	private int newOrders;
	private int preparing;
	private int shipped;
	private int canceled;
}
