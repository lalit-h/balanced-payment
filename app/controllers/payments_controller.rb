class PaymentsController < ApplicationController

  require 'balanced'

  
  ##initiate payment
  def initiate_payment
  end


  #process the Bank Account transaction
  def add_bank_account

    get_balanced_key

    account_uri = params[:account_uri]
    company_name = "Mindfire Solutions"

    ##You can set your customer business / company name here 
    customer = Balanced::Customer.new({name: company_name}).save
    customer_uri = customer.href
    get_customer = Balanced::Customer.fetch(customer_uri)
   
    bank_account = Balanced::BankAccount.fetch(account_uri)
    bank_account.associate_to_customer(customer_uri)
    
    ##befor debiting your customer you need to verify their bank account as per balanced payment
    bank_account = Balanced::BankAccount.fetch(account_uri)
    verify_bank_account = bank_account.verify
    verification = Balanced::BankAccountVerification.fetch(verify_bank_account.href)
    verification.confirm(
      amount_1 = 1,
      amount_2 = 1
    )
    
    amount_in_dollars = params[:amount].to_i
    #amount_in_dollars * 100 convert into cents
    debit = bank_account.debit(:amount => amount_in_dollars * 100, appears_on_statement_as: "Debit Amount")
    
    ##You can save the response in your db for future use
    #debit.transaction_number
    #debit.amount
    #debit.statusdebit.created_at
    
    #get your balanced marketplace
    marketplace = Balanced::Marketplace.my_marketplace
    
    credit = get_marketplace_bank_account.credit(:amount => debit.amount, appears_on_statement_as: "Credit Amount")

    
    return render json: {success: ["Debit Transaction:: #{debit.attributes}", "Credit Transaction:: #{credit.attributes}"] }

  end
  

  #process the credit card transaction
  def add_credit_card

    get_balanced_key
    card_uri = params[:card_uri]

    company_name = "Mindfire Solutions"
    customer = Balanced::Customer.new({name: company_name}).save
    customer_uri = customer.href
    get_customer = Balanced::Customer.fetch(customer_uri)
    card = Balanced::Card.fetch(card_uri)
    card.associate_to_customer(customer_uri)
   

    amount_in_dollars = params[:amount].to_i
    #amount_in_dollars * 100 convert into cents

    debit = card.debit(:amount => amount_in_dollars * 100, appears_on_statement_as: "Debit Amount")
    
    ##You can save the response in your db for future use
    #debit.transaction_number
    #debit.amount
    #debit.statusdebit.created_at
  
    #get the balanced market place
    marketplace = Balanced::Marketplace.my_marketplace
    
    credit = get_marketplace_bank_account.credit(:amount => debit.amount, appears_on_statement_as: "Credit Amount")


    return render json: {success: ["Debit Transaction:: #{debit.attributes}", "Credit Transaction:: #{credit.attributes}"] }

  end


  private
  
  ##here is the demo bank account uri on which you need to credit the amount
  def get_marketplace_bank_account
    Balanced::BankAccount.find("/v1/bank_accounts/BAj6sNNBdMp5WmY6PJ7sAu3")
  end
  
  ##get the balanced marketplace key
  def get_balanced_key
    config = YAML.load_file("#{Rails.root.to_s}/config/balanced.yml")[Rails.env]
    Balanced.configure(config['BALANCED_KEY'])

  end


end