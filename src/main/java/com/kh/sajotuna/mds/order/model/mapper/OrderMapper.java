package com.kh.sajotuna.mds.order.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.order.model.dto.OrderItemDTO;
import com.kh.sajotuna.mds.order.model.dto.PaymentViewDTO;

@Mapper
public interface OrderMapper {
	
	// 멤버id로 정보 받아오기 (멤버쪽도 멤버id로 조회하는 기능이 있지만 가져올 데이터가 다름)
	PaymentViewDTO selectByMemberIdForPay(Long memberId);
	
	// 카트id들 정보 받아오기
	List<OrderItemDTO> selectCartIds(@Param("cartIds") List<Long> cartIds);
	
	// popId로 검색해오기
	OrderItemDTO selectPopId(Long popId);
	
}
