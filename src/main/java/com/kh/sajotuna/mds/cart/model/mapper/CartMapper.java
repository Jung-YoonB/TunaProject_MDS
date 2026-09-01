package com.kh.sajotuna.mds.cart.model.mapper;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.CartListDTO;
import com.kh.sajotuna.mds.cart.model.dto.findInfoDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CartMapper {

    //장바구니 등록
    int insertCart(CartDTO cart);
    //장바구니에 이미 있는 상품인지 확인
    int findCartById(findInfoDTO findInfo);

    //장바구니 리스트
    List<CartListDTO> getCartList(Long memberId);

    int removeCart(@Param("memberId") Long memberId, @Param("popId") Long popId);

}
