require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, ->(u) {u.has_role?(:super_admin)} do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, class_name: "Usr::User"

  scope '/api' do
    post '/bookkeeping', to: 'api/bookkeeping#create'
    post '/shipping', to: 'api/shipping#ship'

    get '/encounters', to: "api/encounters#filter"
    get '/encounters/certs', to: "api/encounters#certs"
    get '/encounters/can_manage', to: "api/encounters#can_manage"
    get '/encounters/diagnoses', to: "api/encounters#diagnoses"
    get '/encounters/facility_pos_codes', to: "api/encounters#facility_pos_codes"
    get '/encounters/md_names', to: "api/encounters#md_names"

    resources :patients, except: [:new, :edit], controller: 'api/patients' do
      resources :encounters, except: [:new, :edit], controller: 'api/encounters' do
        collection do
          get ':enc_type' => 'api/encounters#index', enc_type: /(unsigned|signed|treatment)/
        end
        member do
          patch 'service_timestamp'
          patch 'ship_claim_md'
        end
      end
      member do
        get 'treatment_plan'
        get 'encounter_dates'
        get 'check_service_date'
      end
      member do
        post 'notes'
      end
      collection do
        get 'filter'
        get 'match' => 'api/patients#match'
      end
    end
    resources :providers, except: [:new, :edit], controller: 'api/providers' do
      resources :patients, except: [:new, :edit, :update], controller: 'api/providers/patients'
      collection do
        get :incident_to_providers
      end
      member do
        get :testings
      end
    end
    resources :admins, except: [:new, :edit], controller: 'api/admins'
    resources :reviewers, except: [:new, :edit], controller: 'api/reviewers'
    resources :practices, except: [:new, :edit], controller: 'api/practices' do
      resources :providers, except: [:new, :edit, :update], controller: 'api/practices/providers'
      resources :facilities, except: [:new, :edit, :update], controller: 'api/practices/facilities'
    end
    resources :facilities, except: [:new, :edit], controller: 'api/facilities' do
      resources :contacts, only: [:create, :update, :destroy], controller: 'api/facility_contacts'
    end
    resources :abilities, only: [:index], controller: 'api/abilities'
    resources :ref_lookups, only: [:index], controller: 'api/ref_lookups'
    resources :ref_icds, only: [:index], controller: 'api/ref_icds'
    resources :users, only: [:update], controller: 'api/users'
    resources :insurances, except: [:new, :edit], controller: 'api/insurances'
    resources :prices, except: [:new, :edit], controller: 'api/prices'
    resources :groups, only: [:index, :show, :update, :create], controller: 'api/groups' do
      resources :encounters, only: [:index, :show, :create, :update], controller: 'api/group_encounters' do
        member do
          get 'check_date'
          patch 'addendumize'
        end
      end
      resources :patient_notes, only: [:create, :show, :update, :destroy], controller: 'api/patient_notes'
    end

    resources :remits, controller: 'api/remits' do
      collection do
        post 'import'
      end
    end
  end

  match "*path", to: "application#index", via: :all

  root 'application#index'
end
