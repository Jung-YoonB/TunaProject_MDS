package com.kh.sajotuna.mds.order.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.kh.sajotuna.mds.coupon.model.dto.MyPageCouponDTO;
import com.kh.sajotuna.mds.member.model.mapper.MemberMapper;
import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;
import com.kh.sajotuna.mds.order.model.mapper.OrderMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor	
public class OrderServiceImpl implements OrderService {
	private final OrderMapper mapper;
	private final MemberMapper memberMapper;
	
	@Override
	public PaymentViewDTO cartPrepare(Long memberId, List<Long> cartIds) {
		// 멤버 정보 조회
		PaymentViewDTO pvData = mapper.selectByMemberIdForPay(memberId);
		// 장바구니 조회
		List<OrderItemDTO> itemList = mapper.selectCartIds(cartIds);
		// 총 가격 계산
		long totalPrice = 0L;
		for(OrderItemDTO i : itemList) {
			totalPrice += i.getOptionPrice() * i.getQty();
		}
		// 보유 쿠폰 조회
		List<MyPageCouponDTO> couponList = memberMapper.selectCouponsByMemberId(memberId);
		
		// 데이터 통합
		pvData.setItemList(itemList);
		pvData.setTotalPrice(totalPrice);
		pvData.setCouponList(couponList);
		
		return pvData;
	}

	@Override
	public PaymentViewDTO directPrepare(Long memberId, OrderItemDTO orderItem) {
		// 멤버 정보 조회
		PaymentViewDTO pvData = mapper.selectByMemberIdForPay(memberId);
		// 장바구니 조회
		List<OrderItemDTO> itemList = new ArrayList<>();
		OrderItemDTO result = mapper.selectPopId(orderItem.getPopId());
		result.setQty(orderItem.getQty());
		itemList.add(result);
				
		// 총 가격 계산
		long totalPrice = 0L;
		for(OrderItemDTO i : itemList) {
			totalPrice += i.getOptionPrice() * i.getQty();
		}
		// 보유 쿠폰 조회
		List<MyPageCouponDTO> couponList = memberMapper.selectCouponsByMemberId(memberId);
				
		// 데이터 통합
		pvData.setItemList(itemList);
		pvData.setTotalPrice(totalPrice);
		pvData.setCouponList(couponList);
				
		return pvData;
	}

	
	
}
