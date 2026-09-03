package com.kh.sajotuna.mds.cart.model.service;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.CartListDTO;
import com.kh.sajotuna.mds.cart.model.dto.ResponseCartListDTO;
import com.kh.sajotuna.mds.cart.model.dto.findInfoDTO;
import com.kh.sajotuna.mds.cart.model.mapper.CartMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class CartServiceImpl implements CartService{
    private final CartMapper mapper;
    @Override
    public String insertCartInfo(CartDTO cart) {
        int result;
        System.out.println(cart);

        findInfoDTO findInfo = new  findInfoDTO(cart.getMemberId(), cart.getPopId());
        if(cart.getQty() == 0 ) {
            return "상품의 수량을 입력해주세요";
        }
        int checkCart = mapper.findCartById(findInfo);
        if(checkCart == 1) {
            // 이미 담긴 옵션이면 기존 수량에 더한다. 퀵버튼과 상품 상세가 이 메서드를 공유한다.
            result = mapper.incrementQty(cart.getMemberId(), cart.getPopId(), cart.getQty());
            return result > 0 ? "이미 담긴 상품의 수량을 추가했습니다." : "수량 추가에 실패했습니다.";
        }else if(cart.getQty() <= 0){
             return "갯수를 지정해주세요";
        }else {
            result = mapper.insertCart(cart);
        }
       return result > 0 ? "상품이 장바구니에 등록되었습니다." : "오류가 발생하였습니다. 다시 시도해주세요";
    }

    @Override
    public ResponseCartListDTO getCartList(Long memberId) {
        int cartListPrice = 0;

        List<CartListDTO> getCartList =  mapper.getCartList(memberId);
        System.out.println("getCartList :: " + getCartList);

        for(CartListDTO list : getCartList) {
            cartListPrice+=list.getTotalPrice();
        }

        return new ResponseCartListDTO(getCartList,cartListPrice);
    }

    @Override
    public String removeCart(Long memberId, Long popId) {
        int result = 0;
        result+= mapper.removeCart(memberId,popId);
        System.out.println("result :: " + result);
        if(result>0) {
            return "장바구니 목록에서 제외되었습니다.";
        }else {
            return "장바구니 제외에 실패했습니다.";
        }
    }

    @Override
    public String updateQty(Long memberId, Long popId, int qty) {
        if (qty < 1) {
            return "수량은 1개 이상이어야 합니다.";
        }
        int result = mapper.updateQty(memberId, popId, qty);
        return result > 0 ? "수량이 변경되었습니다." : "수량 변경에 실패했습니다.";
    }
}
