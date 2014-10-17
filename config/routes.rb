Rails.application.routes.draw do

  post '/payments/add_bank_account' => 'payments#add_bank_account', :as => :add_bank_account
  post '/payments/add_credit_card' => 'payments#add_credit_card', :as => :add_credit_card
  get 'initiate_payment' => 'payments#initiate_payment', :as => :initiate_payment

  root 'home#index'

end
