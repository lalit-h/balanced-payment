class PaymentsController < ApplicationController

  require 'balanced'



  def initiate_payment

   
  end


  #process the Bank Account transaction
  def add_bank_account

    get_balanced_key

    account_uri = params[:account_uri]


    business_name = "Lalit Test Firm"
    
    ##You can set your customer business name here
    customer = Balanced::Customer.new({name: business_name}).save
    customer_uri = customer.href
    get_customer = Balanced::Customer.fetch(customer_uri)
   
    bank_account = Balanced::BankAccount.fetch(account_uri)
    bank_account.associate_to_customer(customer_uri)
    
    ##befor debiting your customer you need to verify thier bank account
    #verify a bank account
    bank_account = Balanced::BankAccount.fetch(account_uri)
    verify_bank_account = bank_account.verify
    verification = Balanced::BankAccountVerification.fetch(verify_bank_account.href)
    verification.confirm(
      amount_1 = 1,
      amount_2 = 1
    )
    
    amount_in_dollars = params[:amount]
    #amount_in_dollars * 100 convert into cents
    debit = bank_account.debit(:amount => amount_in_dollars * 100)
      
    

    #deb_transaction = DebitiorTransaction.create(proposal_id: proposal_id, settlement_delivery_report_id: settlement_delivery_report_id, client_id: client.id, transaction_number: debit.transaction_number, transaction_amount: (debit.amount / 100), transaction_status: debit.status, transaction_created_at: debit.created_at, transaction_type: 'Bank Account', tenant_id: @current_tenant.try(:id))
    
    #get your balanced marketplace
    marketplace = Balanced::Marketplace.my_marketplace
    
    get_marketplace_bank_account.credit(:amount => debit.amount)

    
    return render json: {success: "You have successfully made the payment, Transaction ID is #{debit.transaction_number}"}

  end
  

  #process the credit card transaction
  def add_credit_card

    get_balanced_key
    card_uri = params[:card_uri]
    business_name = "Lalit Test Firm"
    customer = Balanced::Customer.new({name: business_name}).save
    customer_uri = customer.href
    get_customer = Balanced::Customer.fetch(customer_uri)
    card = Balanced::Card.fetch(card_uri)
    card.associate_to_customer(customer_uri)
   

    amount_in_dollars = params[:amount]
    #amount_in_dollars * 100 convert into cents

    debit = card.debit(:amount => amount_in_dollars * 100)
   
    #create the client card info info in debitor table
    #DebitiorCreditCard.create(client_id: client.id, customer_uri: customer_uri, card_uri: card_uri, tenant_id: @current_tenant.try(:id))

  
    #get the balanced market place
    marketplace = Balanced::Marketplace.my_marketplace
    
    get_marketplace_bank_account.credit(:amount => debit.amount)

    return render json: {success: "You have successfully made the payment, Transaction ID is #{debit.transaction_number}"}

  end


  private
  
  ##here is the demo bank account uri on which you need to credit the amount
  def get_marketplace_bank_account
    Balanced::BankAccount.find("/v1/bank_accounts/BAmKzgSgEvXsVlx9S8qgPkD")
  end
  
  ##get the balanced marketplace key
  def get_balanced_key
    config = YAML.load_file("#{Rails.root.to_s}/config/balanced.yml")[Rails.env]
    Balanced.configure(config['BALANCED_KEY'])

  end


end