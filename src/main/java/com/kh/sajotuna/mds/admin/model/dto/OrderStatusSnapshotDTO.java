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
@Alias("OrderStatusSnapshotDTO")
public class OrderStatusSnapshotDTO {
	private String orderStatus;
	private String deliveryStatus; // 아직 DELIVERY 행이 없으면 null
}
