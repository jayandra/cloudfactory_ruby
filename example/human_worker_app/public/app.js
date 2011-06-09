$(document).ready(function() {

    $(".add").click(function() {
        $("form > p:first-child").clone(true).insertAfter("form > p:first-child");
        return false;
    });

    $(".remove").click(function() {
        $(this).parent().remove();
    });

});
