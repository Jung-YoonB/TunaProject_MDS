<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    임시 미리보기 전용 JSP.
    실제 컨트롤러/서비스가 detail 모델을 넘겨주기 전까지 productDetail.jsp의
    EL/JSTL 렌더링(옵션 재고 규칙 등)만 확인하기 위한 더미 데이터 주입 파일.

    - 실제 컨트롤러/서비스/매퍼는 전혀 건드리지 않음
    - WEB-INF 밖에 있어서 브라우저에서 바로 접속 가능: /productDetailPreview.jsp
    - 백엔드 연결 끝나면 이 파일은 삭제할 것
--%>

<%-- 서브 이미지는 일부러 6개(홀수 아닌 짝수 그리드 확인용)로 넣어서 고정 4개가 아니어도 잘 나오는지 확인 --%>
<c:set var="product" value="${{
    'productTitle':'코토나 타월 핸드타월 세트',
    'avgScore':4.9,'reviewCount':128,'wishCount':56,
    'productContent':'집들이 수건 선물 세트 - 최고급 순면 100% 소재로 제작되어 흡수력이 뛰어나고 촉감이 부드럽습니다.',
    'thumbnail':'uuid_towel_main.jpg',
    'image':['uuid_towel_sub1.jpg','uuid_towel_sub2.jpg','uuid_towel_sub3.jpg','uuid_towel_sub4.jpg','uuid_towel_sub5.jpg','uuid_towel_sub6.jpg'],
    'detailImage':['uuid_towel_detail2.jpg']
}}" />

<%--
     재고 규칙 확인용: 100개(정상) / 48개(재고 임박) / 3개(재고 임박) / 0개(품절)
     가격은 실제 schema.sql 더미(전부 35800원 동일)와 다르게 일부러 옵션마다 다르게 줘서
     옵션 변경 시 가격/총액이 실제로 바뀌는지 검증할 수 있게 함
--%>
<c:set var="opt1" value="${{'popId':1,'optionName':'코지&amp;펠트바구니','price':35800,'stock':100}}" />
<c:set var="opt2" value="${{'popId':2,'optionName':'비하인드&amp;펠트바구니','price':38800,'stock':48}}" />
<c:set var="opt3" value="${{'popId':3,'optionName':'마일드&amp;펠트바구니','price':41800,'stock':3}}" />
<c:set var="opt4" value="${{'popId':4,'optionName':'에버블루&amp;펠트바구니','price':44800,'stock':0}}" />

<c:set var="optionList" value="${[opt1, opt2, opt3, opt4]}" />

<%-- 리뷰 탭 확인용 더미 (이미지 있는 리뷰 1개 + 이미지 없는 리뷰 1개) --%>
<c:set var="reviewImg1" value="${{'reviewImagePath':'/upload/review/','reviewImageSaveName':'uuid_towel_review.jpg'}}" />
<c:set var="review1" value="${{'writerNicname':'길동이','score':5,'writeDateStr':'2026-08-20','reviewText':'배송도 빠르고 수건 감촉이 너무 좋아요!','reviewImages':[reviewImg1]}}" />
<c:set var="review2" value="${{'writerNicname':'수건러버','score':4,'writeDateStr':'2026-08-15','reviewText':'선물용으로 딱 좋았습니다. 포장도 깔끔해요.','reviewImages':[]}}" />
<c:set var="reviews" value="${[review1, review2]}" />

<c:set var="detail" value="${{'product':product,'option':optionList,'reviews':reviews}}" scope="request" />


<jsp:include page="/WEB-INF/views/product/productDetail.jsp"/>
