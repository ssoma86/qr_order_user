<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%request.setCharacterEncoding("UTF-8");%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
   <title>메뉴플러스</title>
   <meta http-equiv="Content-Type" content="text/html;" charset="utf-8">
   <meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
   <meta http-equiv="X-UA-Compatible" content="IE-Edge">
   <meta name='viewport' content='initial-scale=1, viewport-fit=cover'>
   <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css"/>
   <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/qr/css/common.css">
   <script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha256-2Pmvv0kuTBOenSvLm6bvfBSSHrUJ+3A7x6P5Ebd07/g=" crossorigin="anonymous"></script>
   <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>
   <script src="<%= request.getContextPath() %>/qr/js/common.js"></script>
   <script>
   	window.onpageshow = function(event) {
   		if(opener!=null&&opener!='undefined'){
   			opener.location.replace(window.location.href);
   			window.open('', '_self', '');
   			window.close();
   		}
   		
   		sessionStorage.clear();
  		
  		if(event.persisted || (window.performance && window.performance.navigation.type == 2)) {
  			history.go(1);
  		}
  	}

   	$(document).ready(function(e) {
  	});
   	
 	function goIndex() {
 		if(opener!=null&&opener!=undefined){
 			opener.sessionStorage.clear();
 			opener.location.replace('<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}');
      		window.open('', '_self', '');
      	    window.close();
      	} else if(window.parent!=null&&window.parent!=undefined){
      		parent.sessionStorage.clear();
      		parent.location.replace('<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}');
      	} else {
      		sessionStorage.clear();
      		location.replace('<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}');
      	}
 	}
   </script>
</head>
<body>
	<div class="wrap">
      <header>
         <div class="gnb">
            <a href="<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}" class="go-index">
               <div class="gnb-logo"><img src="<%= request.getContextPath() %>/qr/img/logo.png"></div>
               <div class="shop-name">${shopName}</div>
               <div class="user-n">${roomName}</div>
            </a>
         </div>
      </header>
      <section class="content result-wrap">
         <div class="result">
            <div class="i-complete">
               <img src="<%= request.getContextPath() %>/qr/img/i-check.png">
            </div>
            <div class="title">
               <b>${shopName}</b>의 <b>${roomName}</b><br>주문이 <span>완료</span> 되었습니다.
            </div>
         </div>
         <div class="pay-info">
         	<fmt:parseDate value="${payResult.AuthDate}" var="AuthDate" pattern="yyMMddHHmmss"/>
            <div class="pay-date">주문일시: <fmt:formatDate value="${AuthDate}" pattern="yyyy년 MM월 dd일 HH:mm"/></div>
            <div class="goods-wrap">
            <c:forEach items="${orderData.smenus}" var="menuList">
            	<div class="goods">
            		<div class="goods-name">${menuList.smenuNm}<span class="goods-quantity">${menuList.cnt}개</span></div>
            		<div class="goods-price"><fmt:formatNumber value="${menuList.menuAmt}" type="number"/><span>원</span></div>
            	</div>
            </c:forEach>
            </div>
            <div class="pay-sum">
               <div class="label">합계</div>
               <div class="price"><fmt:formatNumber value="${orderData.amt}" type="number"/><span>원</span></div>
            </div>
         </div>
         <div class="btn-wrap">
            <a href="#" onclick="goIndex();" class="btn btn-l btn-w">메인 페이지로 이동</a>
         </div> 
      </section>  
   </div>
</body>
</html>