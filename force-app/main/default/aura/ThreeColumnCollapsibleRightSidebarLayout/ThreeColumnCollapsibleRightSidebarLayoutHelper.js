({
    getCookie : function(name) {
        var cookieString = '; ' + document.cookie;
        var parts = cookieString.split('; ' + name + '=');
        if (parts.length === 2) {
            return parts.pop().split(';').shift();
        }

        return false;
    },

	setCookie : function(name, value) {
		document.cookie = name + '=' + value + '; path=/';
	}

})