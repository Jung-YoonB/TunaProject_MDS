package com.kh.sajotuna.mds.order.model.dto;

import java.math.BigDecimal;
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
	private BigDecimal discountRate;
	private Long point;
	private Integer usedPoint;
	private long balance;
	private long earnPoint;
	private Long paymentId;
	private Long clientPaidAmount;
	private BigDecimal couponValue;
	private String addressNameFix;
	private String detailAddressFix;
	private Long couponId;
	private Long chistId;
	private Long stock;
	
	private List<OrderItemDTO> itemList;
	private List<Long> cartIds;
}
