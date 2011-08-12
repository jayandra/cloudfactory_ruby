<script src="http://code.jquery.com/jquery-latest.js"></script>

<script type="text/javascript">
     $(document).ready(function() {
	        var url = $("#instructions a").attr('href');
	        var splitted_url = url.split("/");
	        var gender = splitted_url[splitted_url.length - 3];
	        var new_gender = gender.toLowerCase() == "male" ? "female" : "male";
	        splitted_url[splitted_url.length - 3] = new_gender;
	        var age = splitted_url[splitted_url.length - 1];
	        age = decodeURI(age).split(" ")[0];
	        splitted_url[splitted_url.length - 1] = age;
	        var new_url = splitted_url.join("/");
	        $("#instructions a").attr('href',new_url);
	    });
</script>