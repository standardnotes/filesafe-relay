Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "integrations/link" => "integrations#link"
  get "integrations/oauth-redirect" => "integrations#oauth_redirect"
  get "integrations/integration_complete" => "integrations#integration_complete"
  post "integrations/submit_form"

  post "integrations/save-item" => "integrations#save_item"
  post "integrations/download-item" => "integrations#download_item"
  post "integrations/delete-item" => "integrations#delete_item"

  root "application#index"

end
