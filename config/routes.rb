VaeAccounts::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'users/registrations'} do
    get 'users/enable', :to => "users/registrations#enable", :as => "enable_user"
    get 'users', :to => "users/registrations#index", :as => "users"
    put 'users/:id/modify', :to => "users/registrations#admin_update", :as => "admin_update"
    get 'users/edit/admin', :to => "users/registrations#admin_edit", :as => "admin_edit"
  end

  match 'users', :to => 'users/registrations#index', :as => 'users'
  match 'return_to', :to => 'application#set_return_to'
  match 'passkey/validate', :to => 'application#validate_passkey'
  match 'departments/remote', :to => 'departments#remote_request'

  resources :departments, :only => [:new, :index, :edit, :update, :destroy]
  root :to => 'departments#index'
end
