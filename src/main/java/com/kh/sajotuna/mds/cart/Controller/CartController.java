package com.kh.sajotuna.mds.cart.Controller;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
import com.kh.sajotuna.mds.cart.model.dto.CartListDTO;
import com.kh.sajotuna.mds.cart.model.dto.ResponseCartListDTO;
import com.kh.sajotuna.mds.cart.model.service.CartService;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.util.SessionConst;
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

        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            System.out.println(member);
            System.out.println(model.getAttribute("message"));
            return "redirect:/member/login";
        }

        System.out.println("memberId :: " + member.getMemberId());
        cart.setMemberId(member.getMemberId());
        System.out.println("cart :: " + cart);
        String message = service.insertCartInfo(cart);
        System.out.println("message :: " + message);
        model.addAttribute("message", message);
        return "redirect:/cart/my-cart";
    }

    @GetMapping("/my-cart")
    public String getCartList(HttpSession session, Model model) {
        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        ResponseCartListDTO cartList = service.getCartList(member.getMemberId());
        model.addAttribute("cartList", cartList);
        System.out.println("cartList :: " + cartList);
        return "product/cart";
    }

    // 헤더 장바구니 뱃지용 - header.js가 페이지 로드마다 호출해서 실제 CART 기준 수량 합계를
    // 보여준다(AUDIT 신규 버그: 뱃지가 localStorage 목업이라 메인 페이지 등에서 실제 담긴 수량과
    // 안 맞던 것 조치). 비로그인이면 0.
    @GetMapping("/count")
    @ResponseBody
    public int count(HttpSession session) {
        MemberDTO member = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
        if (member == null) {
            return 0;
        }
        return service.getCartList(member.getMemberId()).getCartList().stream()
                .mapToInt(CartListDTO::getQty)
                .sum();
    }

    // 수량 +/- 버튼용. 다른 CUD와 달리 리다이렉트가 아니라 결과만 돌려준다 - JS가 페이지 새로고침
    // 없이 그 줄의 수량/금액만 갱신한다(버튼을 누를 때마다 전체 목록을 다시 그리면 스크롤 위치가
    // 튀는 등 번거로움). 실패("false")면 JS가 화면을 원래 값으로 되돌린다.
    @PostMapping("/update-qty")
    @ResponseBody
    public boolean updateQty(HttpSession session, Long popId, int qty) {
        MemberDTO member = (MemberDTO) session.getAttribute(SessionConst.LOGIN_SESSION);
        if (member == null) {
            return false;
        }
        return service.updateQty(member.getMemberId(), popId, qty).contains("변경되었습니다");
    }

    @GetMapping("/remove-cart")
    public String removeCart(HttpSession session, Model model, Long popId) {
        System.out.println("pop_id :: " + popId);
        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        String message = service.removeCart(member.getMemberId(), popId);
        System.out.println("message :: " + message);
        model.addAttribute("message", message);
        return "redirect:/cart/my-cart";
    }
}
