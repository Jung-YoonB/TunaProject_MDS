package com.kh.sajotuna.mds.wish.controller;

import com.kh.sajotuna.mds.util.LoginUtil;
import com.kh.sajotuna.mds.member.model.dto.MemberDTO;
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
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/wish")
public class WishController {
    private final WishService service;

    @PostMapping("/insert-wish")
    public String insertWish(HttpSession session, Long productId, Model model) {

        MemberDTO member = LoginUtil.member(session);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        findWishInfoDTO findWishInfoDTO = new findWishInfoDTO(member.getMemberId(), productId);

        String addWish = service.insertWish(findWishInfoDTO);
        model.addAttribute("message", addWish);
        return "redirect:/mds/detail/" + productId;

    }

    @GetMapping("/remove-wish")
    public String removeWish(HttpSession session, Long productId, Model model) {
        MemberDTO member = LoginUtil.member(session);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        findWishInfoDTO findWishInfoDTO = new findWishInfoDTO(member.getMemberId(), productId);
        String message = service.removeWish(findWishInfoDTO);

        model.addAttribute("message", message);
        return "redirect:/wish/my-wish";
    }

    // 헤더 찜 뱃지용 - 실제 WISH 개수. 비로그인이면 0
    @GetMapping("/count")
    @ResponseBody
    public int count(HttpSession session) {
        MemberDTO member = LoginUtil.member(session);
        if (member == null) {
            return 0;
        }
        return service.getWishList(member.getMemberId()).size();
    }

    @GetMapping("/my-wish")
    public String myWish(HttpSession session, Model model) {
        MemberDTO member = LoginUtil.member(session);
        if(member == null){
            model.addAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        List<WishListDTO> list = service.getWishList(member.getMemberId());
        model.addAttribute("list", list);
        return "product/wish";
    }
}
