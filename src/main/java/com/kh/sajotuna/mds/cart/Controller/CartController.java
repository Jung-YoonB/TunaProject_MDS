package com.kh.sajotuna.mds.cart.Controller;

import com.kh.sajotuna.mds.cart.model.dto.CartDTO;
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
import org.springframework.web.bind.annotation.RequestParam;

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
            return "redirect:/login";
        }

        System.out.println("memberId :: " + member.getMemberId());
        cart.setMemberId(member.getMemberId());
        System.out.println("cart :: " + cart);
        String message = service.insertCartInfo(cart);
        System.out.println("message :: " + message);
        model.addAttribute("message", message);
        return "redirect:home/home";
    }

    @GetMapping("/my-cart")
    public String getCartList(HttpSession session, Model model) {
        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/login";
        }
        ResponseCartListDTO cartList = service.getCartList(member.getMemberId());
        model.addAttribute("cartList", cartList);
        System.out.println("cartList :: " + cartList);
        return "product/cart";
    }

    @GetMapping("/remove-cart")
    public String removeCart(HttpSession session, Model model, Long popId) {
        System.out.println("pop_id :: " + popId);
        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        String message = service.removeCart(member.getMemberId(), popId);
        System.out.println("message :: " + message);
        model.addAttribute("message", message);
        return "redirect:home/home";
    }
}
