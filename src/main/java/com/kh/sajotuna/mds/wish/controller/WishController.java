package com.kh.sajotuna.mds.wish.controller;

import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
import com.kh.sajotuna.mds.util.SessionConst;
import com.kh.sajotuna.mds.wish.model.dto.WishListDTO;
import com.kh.sajotuna.mds.wish.model.dto.findWishInfoDTO;
import com.kh.sajotuna.mds.wish.model.service.WishService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/wish")
public class WishController {
    private final WishService service;

    @PostMapping("/insert-wish")
    public String insertWish(HttpSession session, Long productId, Model model) {

        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            System.out.println(model.getAttribute("message"));
            return "redirect:/member/login";
        }

        findWishInfoDTO findWishInfoDTO = new findWishInfoDTO(member.getMemberId(), productId);

        String addWish = service.insertWish(findWishInfoDTO);
        model.addAttribute("message", addWish);
        System.out.println("addWishMessage :: " + addWish);
        return "redirect:/mds/detail/" + productId;

    }

    @GetMapping("/remove-wish")
    public String removeWish(HttpSession session, Long productId, Model model) {
        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            System.out.println(model.getAttribute("message"));
            return "redirect:/member/login";
        }

        findWishInfoDTO findWishInfoDTO = new findWishInfoDTO(member.getMemberId(), productId);
        String message = service.removeWish(findWishInfoDTO);

        model.addAttribute("message", message);
        System.out.println("removeWishMessage :: " + message);
        return "redirect:/wish/my-wish";
    }

    @GetMapping("/my-wish")
    public String myWish(HttpSession session, Model model) {
        MemberDTO member = (MemberDTO)session.getAttribute(SessionConst.LOGIN_SESSION);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            System.out.println(model.getAttribute("message"));
            return "redirect:/member/login";
        }
            List<WishListDTO> list = service.getWishList(member.getMemberId());
        System.out.println("list :: " + list);
        model.addAttribute("list", list);
        return "product/wish";
    }
}
