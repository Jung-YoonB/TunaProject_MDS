package com.kh.sajotuna.mds.admin.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.admin.model.dto.AdminOrderListItemDTO;
import com.kh.sajotuna.mds.admin.model.dto.AdminOrderSummaryDTO;

@Mapper
public interface AdminOrderMapper {

	List<AdminOrderListItemDTO> selectOrderList();

	AdminOrderSummaryDTO selectSummary();

	int updateDeliveryStatus(@Param("orderId") Long orderId, @Param("deliveryStatus") String deliveryStatus,
			@Param("trackingNo") String trackingNo);
}
