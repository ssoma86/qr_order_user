<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%request.setCharacterEncoding("UTF-8");%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
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
  		
  		if(event.persisted || (window.performance && window.performance.navigation.type == 2)) {
  			history.go(1);
  		}
	}
   
   	$(document).ready(function() {
   	});
   	
   	function goCart() {
   		if(opener!=null&&opener!=undefined){
   			window.open('', '_self', '');
   		    window.close();
   		} else if(window.parent!=null&&window.parent!=undefined) {
	   		var menuList = [];
	   		var cartCount = sessionStorage.getItem("cartCount");
	   		var totalPrice = sessionStorage.getItem("totalPrice");
	   		var html = "";
	   		
	   		if(sessionStorage.length > 0) {
		   		for(var i = 0 ; i < sessionStorage.length; i++) {
		   			if(sessionStorage.key(i).includes("cartData")) {
		   				var moid = JSON.parse(sessionStorage.getItem(sessionStorage.key(i))).moid;
		   				var menuData = sessionStorage.getItem(sessionStorage.key(i));
		   				console.log(moid);
		   				console.log(menuData);
		   				
		   				html += "<input type='hidden' name='moid' value='" + moid + "'/>";
		   				html += "<input type='hidden' name='" + moid + "' value='" + menuData + "'/>"
					}
		   		}
		   		console.log("cartCount : " + cartCount);
		   		console.log("totalPrice : " + totalPrice);
		   		
		   		html += "<input type='hidden' name='cartCount' value='" + cartCount + "'/>";
		   		html += "<input type='hidden' name='totalPrice' value='" + totalPrice + "'/>";
		   		html += "<input type='hidden' name='storeRoom' value='" + JSON.stringify(${storeRoom}) + "'/>";
		   		
		   		$('#cartData').append(html);
		   		$('#cartData').submit();
		   		$('#cartData').html('');		
	   		}

   		}
   	}
   </script>
<body>
	<form action="<%= request.getContextPath() %>/qr/showCart/${orderData.storeRoomCd}" name="cartData" id="cartData" method="POST" style="display:none;"></form>
	<div class="wrap">
      <header>
         <div class="gnb">
            <a href="<%= request.getContextPath() %>/qr/${storeRoom.store.storeId}/${storeRoom.storeRoomCd}">
               <div class="gnb-logo"><img src="<%= request.getContextPath() %>/qr/img/logo.png"></div>
               <div class="shop-name">${shopName}</div>
               <div class="user-n">${roomName}</div>
            </a>
         </div>
      </header>
      <section class="content result-wrap">
         <div class="result">
            <div class="i-complete">
               <img src="<%= request.getContextPath() %>/qr/img/i-x.png">
            </div>
            <div class="title">
            	<c:choose>
            		<c:when test="${message eq 'systemError' }">
            			<b>시스템 오류</b><br>결제에 <span>실패</span> 했습니다.
            			<br>관리자에게 문의 하세요.
            		</c:when>
            		<c:otherwise>
            			<b>${shopName}</b>의 <b>${roomName}</b><br>결제에 <span>실패</span> 했습니다.
            		</c:otherwise>
            	</c:choose>
            </div>
         </div>
         <div class="pay-info">
         	<c:choose>
         		<c:when test="${message eq 'systemError' }">
         			<b>시스템 오류</b><br>결제에 <span>실패</span> 했습니다.
         			<br>관리자에게 문의 하세요.
            	</c:when>
            	<c:otherwise>
		            <fmt:parseDate value="${payResult.AuthDate}" var="AuthDate" pattern="yyMMddHHmmss"/>
		            <div class="pay-date">실패일시: <fmt:formatDate value="${AuthDate}" pattern="yyyy년 MM월 dd일 HH:mm"/></div>
		            <c:choose>
		            	<c:when test ="${payResult.ErrorMsg ne '' }">
		            		<div class="fail-info">실패사유: ${payResult.ErrorMsg}</div>
		            	</c:when>
		            	<c:otherwise>
		            		<div class="fail-info">실패사유: ${payResult.ResultMsg}</div>
		            	</c:otherwise>
		            </c:choose>
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
            	</c:otherwise>
            </c:choose>
         </div>
         <div class="btn-wrap">
            <a href="#" onclick="goCart();" class="btn btn-l btn-w">장바구니로 이동</a>
         </div> 
      </section>  
   </div>
</body>
</html>