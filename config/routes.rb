Rails.application.routes.draw do
  get "/near_me", to: "establishments#near_me"
end
