package com.kh.sajotuna.mds.cart.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ResponseCartListDTO {
    private List<CartListDTO> cartList;
    private int cartListPrice;
}
