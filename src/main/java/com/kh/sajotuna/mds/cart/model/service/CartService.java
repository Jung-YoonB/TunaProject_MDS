package com.kh.sajotuna.mds.cart.model.service;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.ResponseCartListDTO;

public interface CartService {

    String insertCartInfo(CartDTO cart);
    ResponseCartListDTO getCartList(Long memberId);
    String removeCart(Long memberId, Long popId);
    String updateQty(Long memberId, Long popId, int qty);
}
