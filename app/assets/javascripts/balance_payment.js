$(document).ready(function () {

	$('#credit_card_0').click(function(){
		$('#bank_account_info').hide();
		$('#credit_card_info').slideDown(500);
	   
	});

	$('#bank_account_1').click(function(){
		$('#credit_card_info').hide();
		$('#bank_account_info').slideDown(500);
	   
	});

	/////bank account cliecked
	$('#ba-submit').click(function (e) {
	    e.preventDefault();
	    ///get fields values
      name = $('#ba-name').val();
      account_number = $('#ba-an').val();
      routing_number = $('#ba-rn').val();
      type = $('#ba-type').val();
      amount = $('#amount').val();
      if (amount == "" || amount < 0.5){
		    show_msg("Amount could not be less than $ 0.05");
		  }else if(/^[0-9.]+$/.test(amount) == false){
		  	 show_msg("Amount could not be less than $ 0.05");
      }else if(name == ""){
	      show_msg("Name could not be blank");
	    }else if(routing_number == ""){
	       show_msg("Please provide valid routing number");

	    }else if(account_number == ""){
	      show_msg("Please provide valid account number");
		  }else if(type == ""){
		  	show_msg("Please select account type");
		  }
		  else{

		    var payload = {
		      name: name,
		      account_number: account_number,
		      routing_number: routing_number,
		      type: type
		    };

		    // Tokenize bank account
		    balanced.bankAccount.create(payload, function (response) {
		     switch (response.status) {
			    case 201:
		         var bankTokenURI = response.data['uri'];
		         ///if success then send a ajax request to the controller  with return token
		        $.ajax({
			        type: 'POST',
			        url: "/payments/add_bank_account",
			        data: {
			        	account_uri: bankTokenURI,
			        	amount: $('#amount').val()
			        
			        },
			        beforeSend: function(){
				        $('#processing').show();
				      },
				      complete: function(){
				        $('#processing').hide();
				        
				      },
			        success: function(data) {
			        	show_msg(data.success);
			        	window.reload();
			        },
			        error: function(data){
			          show_msg("There is a problem while making the payment, please try again.");
			          
			        },
		      });
		      break;
			    case 400:
	          // missing field - check response.error for details
	          //html(JSON.stringify(response, false, 4));
	          show_msg(JSON.stringify(response.error));
	          $('#ba-submit').show();
	         break;
			    case 402:
		       // check response.error for details
		       show_msg(JSON.stringify(response.error));
		        $('#ba-submit').show();
		       break
			    case 404:
			      // your marketplace URI is incorrect
			      show_msg(JSON.stringify(response.error));
			       $('#ba-submit').show();
			      break;
			    case 500:
			      show_msg("Something went wrong, please retry the request");
			      $('#ba-submit').show();
			      break;
			   }   
		    });
      }

	  });
    

    ////check if credit card American Express selected then show zip code text box
    //default it should be hidden
    $('#zip_code_required').hide();
    $('#cc-type').change(function(){
    	if($(this).val() == "American Express"){
    	  $('#zip_code_required').show();
    	}else{
    		$('#zip_code_required').hide();
    	}
    })
	  ///////credit card clicked
	  $('#cc-submit').click(function (e) {
	    e.preventDefault();

	    name =  $('#cc-name').val();
      card_number =  $('#cc-number').val();
      expiration_month = $('#cc-em').val();
      expiration_year = $('#cc-ey').val();
      security_code = $('#cc-csc').val();
      card_type = $('#cc-type').val();
      postal_code = $('#cc-zip-code').val();
      amount  = $('#amount').val();
      

      if (amount == "" || amount < 0.5){
		    show_msg("Amount could not be less than $ 0.05");
		  }else if(/^[0-9.]+$/.test(amount) == false){
		  	 show_msg("Amount could not be less than $ 0.05 ");
      }else if(name == ""){
	      show_msg("Name could not be blank");
	    }else if(card_number == ""){
	      show_msg("Please provide valid card number");
	    }else if(expiration_month == ""){
	      show_msg("Please provide expiration month");
		  }else if(expiration_year == ""){
		  	show_msg("Please provide expiration year");
		  }else if(card_type == ""){
        show_msg("Please select a card type");
		  }else if(security_code == ""){
          show_msg("Please enter security code");
		  }else if(card_type == "American Express" && postal_code == ""){
         show_msg("For american express card it is mandatory to enter the zip code");
		  }
		  else{

		    var payload = {
		        name:  name,
		        card_number: card_number,
		        expiration_month: expiration_month,
		        expiration_year: expiration_year,
		        security_code: security_code,
		        card_type: card_type,
		        postal_code: postal_code
		    };
           
	        ////check all fiesds should be present
		      // Tokenize credit card
		      balanced.card.create(payload, function (response) {
		        switch (response.status) {
					    case 201:
			         // the uri is an opaque token referencing the tokenized card
			         var cardTokenURI = response.data['uri'];
		           proposal_token = $('#proposal_token').val();
		           amount  = $('#proposal_amount').val();
		           one_time_payment = $('#one_time_payment').val();
			         ///if success then send a ajax request to the controller  with return token
			         $.ajax({
					        type: 'POST',
					        url: "/payments/add_credit_card",
					        data: {
					        	card_uri: cardTokenURI,
					        	amount: $('#amount').val()
					        
					        },
					        beforeSend: function(){
						        $('#processing').show();
						      },
						      complete: function(){
						        $('#processing').hide();
						       
						      },
					        success: function(data) {
					        	show_msg(data.success);
					        	window.reload();
					        	 
					        },
					        error: function(data){
					          show_msg("There is a problem while making the payment, please try again.");
					        },
			       });

					     break;
				       case 400:
				         // missing field - check response.error for details
				         show_msg(JSON.stringify(response.error));
		             $('#cc-submit').show();
				        break;
					    case 402:
			          show_msg(JSON.stringify(response.error));
		            $('#cc-submit').show();
			          break
					    case 404:
					      show_msg(JSON.stringify(response.error));
		            $('#cc-submit').show();
					      break;
					    case 500:
					      show_msg("Something went wrong, please retry the request");
			          $('#cc-submit').show();
					    break;
		        }
		      });
       }
    });

}); 


function show_msg(msg){
	alert(msg)


}