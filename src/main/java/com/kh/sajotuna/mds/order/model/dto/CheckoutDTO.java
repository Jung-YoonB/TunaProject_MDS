package com.kh.sajotuna.mds.order.model.dto;

import java.util.List;

import org.apache.ibatis.type.Alias;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Alias("CheckoutDTO")
public class CheckoutDTO {

	private Long memberId;
	private Long orderId;
	private long totalPrice;
	private double discountRate;
	private Long point;
	private Integer usedPoint;
	private int balance;
	private int earnPoint;
	private Long paymentId;
	private String addressNameFix;
	private String detailAddressFix;
	private Long couponId;
	private Long chistId;
	private double couponValue;
	
	private List<OrderItemDTO> itemList;
}
