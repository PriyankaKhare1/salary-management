Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :employees, only: [:index, :show, :create, :update] do
        resource :salary, only: [:create, :update], module: :employees
      end

      namespace :analytics do
        get :summary
        get :by_department
        get :by_country
        get :by_designation
      end
    end
  end
end
