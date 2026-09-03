package com.kh.sajotuna.mds.cart.Controller;

import com.kh.sajotuna.mds.util.LoginUtil;
import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.ResponseCartListDTO;
import com.kh.sajotuna.mds.cart.model.service.CartService;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequiredArgsConstructor
@RequestMapping("/cart")
public class CartController {
    private final CartService service;

    @PostMapping("/add-cart")
    public String insertCart( CartDTO cart, HttpSession session, Model model) {

        MemberDTO member = LoginUtil.member(session);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        cart.setMemberId(member.getMemberId());
        String message = service.insertCartInfo(cart);
        model.addAttribute("message", message);
        return "redirect:/cart/my-cart";
    }

    @GetMapping("/my-cart")
    public String getCartList(HttpSession session, Model model) {
        MemberDTO member = LoginUtil.member(session);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        ResponseCartListDTO cartList = service.getCartList(member.getMemberId());
        model.addAttribute("cartList", cartList);
        return "product/cart";
    }

    // 헤더 장바구니 뱃지용 - 수량 합계가 아니라 담긴 옵션(행) 개수. 비로그인이면 0
    @GetMapping("/count")
    @ResponseBody
    public int count(HttpSession session) {
        MemberDTO member = LoginUtil.member(session);
        if (member == null) {
            return 0;
        }
        return service.getCartList(member.getMemberId()).getCartList().size();
    }

    // 수량 +/- 버튼용. 다른 CUD와 달리 리다이렉트가 아니라 결과만 돌려준다 - JS가 페이지 새로고침
    // 없이 그 줄의 수량/금액만 갱신한다(버튼을 누를 때마다 전체 목록을 다시 그리면 스크롤 위치가
    // 튀는 등 번거로움). 실패("false")면 JS가 화면을 원래 값으로 되돌린다.
    @PostMapping("/update-qty")
    @ResponseBody
    public boolean updateQty(HttpSession session, Long popId, int qty) {
        MemberDTO member = LoginUtil.member(session);
        if (member == null) {
            return false;
        }
        return service.updateQty(member.getMemberId(), popId, qty).contains("변경되었습니다");
    }

    @GetMapping("/remove-cart")
    public String removeCart(HttpSession session, Model model, Long popId) {
        MemberDTO member = LoginUtil.member(session);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        String message = service.removeCart(member.getMemberId(), popId);
        model.addAttribute("message", message);
        return "redirect:/cart/my-cart";
    }
}
