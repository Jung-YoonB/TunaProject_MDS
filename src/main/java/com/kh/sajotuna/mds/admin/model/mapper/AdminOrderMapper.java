package com.kh.sajotuna.mds.admin.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.kh.sajotuna.mds.admin.model.dto.AdminOrderListItemDTO;
import com.kh.sajotuna.mds.admin.model.dto.AdminOrderSummaryDTO;
import com.kh.sajotuna.mds.admin.model.dto.OrderStatusSnapshotDTO;

@Mapper
public interface AdminOrderMapper {

	List<AdminOrderListItemDTO> selectOrderList();

	AdminOrderSummaryDTO selectSummary();

	OrderStatusSnapshotDTO selectStatusSnapshot(@Param("orderId") Long orderId);

	int updateDeliveryStatus(@Param("orderId") Long orderId, @Param("deliveryStatus") String deliveryStatus,
			@Param("trackingNo") String trackingNo, @Param("company") String company);

	int insertDelivery(@Param("orderId") Long orderId, @Param("deliveryStatus") String deliveryStatus,
			@Param("trackingNo") String trackingNo, @Param("company") String company);

	int updateOrderStatus(@Param("orderId") Long orderId, @Param("orderStatus") String orderStatus);

	int confirmPayment(@Param("orderId") Long orderId);
}
