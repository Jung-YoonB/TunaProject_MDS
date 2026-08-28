package com.kh.sajotuna.mds.cart.model.mapper;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.CartListDTO;
import com.kh.sajotuna.mds.cart.model.dto.findInfoDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CartMapper {

    int insertCart(CartDTO cart);
    int findCartById(findInfoDTO findInfo);

    List<CartListDTO> getCartList(Long memberId);

}
