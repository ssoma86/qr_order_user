
	<script type="text/javascript">
		function googleTranslateElementInit() {
			new google.translate.TranslateElement({pageLanguage: 'ko'
													, layout: google.translate.TranslateElement.InlineLayout.SIMPLE
													, autoDisplay: true}, 'google_translate_element');
		}
		
		
		function delCookie(name){
			today = new Date();
			today.setDate(today.getDate() - 1);
			document.cookie = name + "; path=/; expires=" + today.toUTCString() ;
		}
		
		function selectLanguage(lang){
			
			if(lang != ''){
			
				var googTrans = "";
				if(googTrans === "/ko/ko"){
					delCookie('googtrans');
				}else{
					menuplus.setCookie('googtrans', '/ko/' + lang);
				}
				
				location.reload();
				
				if(menuplus.getCookie('googtrans')){
					googTrans = menuplus.getCookie('googtrans');				
					
				}
				
				const el = document.getElementById('googleSelectLang');  //select box
				const len = el.options.length; //select box의 option 갯수
				
			  	for (let i=0; i<len; i++){  
			  	//select box의 option value가 입력 받은 value의 값과 일치할 경우 selected
			   		if(el.options[i].value == lang){
			    		el.options[i].selected = true;
			    		return true;
			    	}
			  	}  
			}
			
			return false;
			
		}
		
	</script>
	<script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit&hl=en"></script>
	
	<style>
		body > .skiptranslate { display : none; }
		.goog-te-gadget img{ display : none !important;	}
		.goog-te-banner-frame.skiptranslate { display : none !important;}
		
	</style>
	
	
	
	