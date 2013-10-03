$(document).ready(function() {
    setTimeout("refresh_issues_list();",60000);
    main_sort();
    add_time();
    close_ticket();
    tooltip_show();
    change_to_in_progress();
    change_person();
    start_stop();
    poke();
    if($('#is-shown').val()==0){
        $('#new-issue-plugin').hide();
    }
    $('#issue_project_id').on('change', function(e){
        change_person();
    })
    $('#clear_new_issue_form').on('click', function(){
		 $('#issue-form').find(':input').each(function() {
				switch(this.type) {
					case 'password':
					case 'select-multiple':
					case 'select-one':
					case 'text':
					case 'textarea':
						$(this).val('');
						break;
					case 'checkbox':
					case 'radio':
						this.checked = false;
			        }
			    });
    })

    $('#new_issue_form_show').on('click', function(){
		$('#new-issue-plugin').toggle({duration:500, easing:"linear"});
        if ($('#new-issue-plugin').is(":visible")){
            $('#is-shown').val(0)
        }
        else{
            $('#is-shown').val(1)
        }
    })
});

function close_ticket(){
    $('td.checkbox').each(function(e){
        $(this).on("click", function(a){
            if($(":first-child",this).is(':checked')){
                $(this).parent().css({
                    textDecoration: 'line-through',
                    color: 'gray'
                });
                data= $('#table-it-form').serialize(true)
                $.ajax('/plugin_app/update_issue', {
					type:"POST",
                    data: data
                })
            }
            else{
                idparam = $(":first-child",this).val()
                $(this).parent().attr('style',[])
                $.ajax('/plugin_app/uncheck_issue', {
					type: "POST",
                    data: {
                        'id':idparam
                    }
                })
            }
        });
    });
}

function refresh_issues_list(){
    par = window.location.href.split("?")
    $.ajax('/plugin_app/refresh_issues_list', {
        data: par[1]
    })
    tooltips=$('.tooltip')
    toolsize = tooltips.size()
    if(toolsize>0){
        i=0
        while(i<toolsize){
            tooltips[i].remove();
            i++
        }
    }
    setTimeout("refresh_issues_list();",60000);
}

function add_time(){
    $('.addtimeclick').each(function(e){
        $(this).on("click", function(a){
            time_val=$(this).prev().val();
            issue_id=$(this).prev().prev().val();
            $.ajax('/plugin_app/add_time', {
				type: "POST",
                data: {
                    'time': time_val,
                    'issue_id': issue_id
                },
                onComplete: function(){
					type: "POST",
                    $.ajax('/plugin_app/refresh_issues_list')
                },
                onLoading: $(this).prev().val('')
            })
        })
    })
}

function tooltip_show(){
	$('td.subject a').qtip({
	   content: $(this).attr('title'),
	   show: 'mouseover',
	   hide: 'mouseout'
	})
}

function clear_form_fields(){
    $('#issue_subject').val('')
    $('#issue_description').val('')
}
function change_to_in_progress(){
    $('.change-to-in-progress').each(function(e){
        $(this).on('click', function(eff){
            $.ajax('/plugin_app/change_to_in_progress', {
				type: "POST",
                data: {
                    'issue_id': e.identify()
                }
            })
            e.removeClassName('status_1').addClassName('status_2')
        }
        )
    })
}
function change_person(){
    proj_id=$('#issue_project_id').val();

    hasz= new Array({
        id:96,
        val:1,
        name:'Krzysztof'
    },{
        id:101,
        val:17,
        name:'Bartek'
    }, {
        id:98,
        val:15,
        name:'Ewelina L.'
    },{
        id:99,
        val:16,
        name:'Ewelina Ś.'
    },{
        id:94,
        val:8,
        name:'Mateusz'
    },{
        id:100,
        val:14,
        name:'Olga'
    }, {
        id:95,
        val:7,
        name:'Wiktor'
    },{
	    id:168,
	    val:30,
	    name:'Daniel'
	},{
	    id:156,
	    val:27,
	    name:'Franek'
	},{
		id:130,
		val:25,
		name: "Przemek"
	},{
		id:107,
		val:21,
		name: "Łukasz"
	},{
		id:167,
		val:31,
		name: "Basia"
	});
    if(proj_id==94){
        $('#issue_assigned_to_id').val(8)
        }
    for(var i=0; i<hasz.length; i++){
        if(hasz[i].id==proj_id){
            $('#issue_assigned_to_id').val(hasz[i].val);
            break;
        }
    }
}

function start_stop(){
    $('.start_time').each(function(e){
        $(this).on("click", function(a){
            $.ajax('/plugin_app/start_time', {
				type: "POST",
                data: {
                    'issue_id': $(this).attr("value")
                }
            })
            $(this).removeClass('start_time').addClass('stop_time');
        });
    })

    $('.stop_time').each(function(e){
        $(this).on("click", function(a){

            $.ajax('/plugin_app/stop_time', {
				type: "POST",
                data: {
                    'issue_id': $(this).attr("value")
                }
            })
            $(this).removeClass('stop_time').addClass('start_time');
        });
    })
}

function getURLParameter(url, sParam){
    var sPageURL = url;
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++){
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam)
            return sParameterName[1];
    }
}
function poke(){
    $('.poke').each(function(e){
        $(this).on('click', function(eff){
            $.ajax($(this).attr('value'), {
				type: "POST",
                data: {
                    'issue_id': getURLParameter($(this).attr("value"), "id")
                }
            })
            $(this).removeClass('status_1').addClass('status_2')
        }
        )
    })
}
