package com.kh.sajotuna.mds.admin.model.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DeliveryUpdateRequestDTO {
	private String deliveryStatus;
	private String trackingNo;
}
